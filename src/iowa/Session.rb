require 'thread'
#require 'log4r'
#include Log4r
require 'iowa/SessionStats'

module Iowa

	# Container for an inline generated resource.
	
	class Resource

		attr_accessor :body, :content_type, :headers
		
		def initialize(body,content_type=Capplication_data,headers=nil)
			@body = body
			@content_type = content_type
			@headers = headers
		end
	end
	
	# Custom exception which is thrown if a request does not have a request ID.
	
	class IgnoreRequest < Exception; end

	class NoAction < Exception; end
	
	# Custom exception which is thrown if a request asks for a page which has
	# expired from the cache.
	
	class PageExpired < Exception; end
	
	# Represents a session between the application and the user.
	
	class Session
		
		# Default delay between the presentation of the page expired message
		# (see this below) and the redirect to the top of the application.
	
	
		# Class variable which holds the class of a session.
	
	
		# Define an accessor to make the context object accessible to the
		# application's code.
	
		attr_accessor :context, :application, :currentPage, :requestCount, :pages,
			:resourceCount, :notes, :access_time, :lock
	
		@sessionClass = self

		def Session.cachedPages
			@cachedPages
		end

		def Session.cachedPages=(val)
			@cachedPages = val
		end

		def Session.cacheTTL
			@cacheTTL
		end

		def Session.cacheTTL=(val)
			@cacheTTL = val
		end
	
		# Constructor to return a new instance of @sessionClass.
	
		def Session.newSession(*args)
			@sessionClass.new(*args)
		end
	
		def Session.inherited(subclass)
			@sessionClass = subclass
		end
	
		def self.PageCache
			@page_cache_class ? @page_cache_class.new(@page_class_args) : nil
		end

		def self.PageCache=(args)
			@page_cache_class, @page_class_args = Util.get_cache(args,nil,Iowa.config[Csession],Cpagecache,true)
		end

		FCM = Iowa::Component.methods.inject({}) {|h,k| h[k] = true; h} unless const_defined?(:FCM)

		# Initialize the state of the session.
	
		def initialize
			@cachedPages ||= 10
			@cacheTTL ||= nil
			@expiryDelay ||= 1
			reset
			#@lock = Iowa::Mutex.new
			@lock = Mutex.new
			@creation_time = Time.now
			#@statistics = Iowa::SessionStats.new(@pages)
		end
	
		def statistics
			@statistics
		end
	
		# Handles the current request from the browser.  Essentially all that
		# is happening is thread synchronizations along with some tests to make
		# sure that all the data necessary to handle the request exists.
		# Then the call to handleRequest gets passed on to the object representing
		# the current page.
	
		def handleRequest(context,dispatch_destination = nil)
			dispatch_destination = Iowa::DispatchDestination.new(dispatch_destination) if dispatch_destination.is_a?(::String)
			@fragment = nil
			#@statistics.hit
			@access_time = Time.now
			mylog = Logger[Ciowa_log]
			if @lock.locked?
				mylog.info("Session collision.  Waiting.")
			end
			#mylog.debug("Handle Session for #{dispatch_destination.inspect}")
#			@lock.synchronize do
			@lock.lock
#				begin
					context.session = self
					requestPage = @currentPage
					@context = context
					unless !context.requestID || dispatch_destination
						#begin
							# If the request is for a resource, handle that.
							return handle_resource(context) if @resources.has_key?("#{context.requestID}.#{context.actionID}")
							# Bail out if that page is not in the cache.  Remember that a request
							# runs on the current page; it's the response that generates a new page.
							raise PageExpired unless @pages.include?(context.requestID)
							requestPage = @pages[context.requestID]

							if @requestCount != context.requestID and !requestPage.replaceable?
								requestPage.handleBacktrack
							end

							@currentPage = requestPage.replaceable? ? requestPage : requestPage.dup

							# TODO: Make it a runtime option to reload modified or not.
							@application.reloadModified(@currentPage.class.name)

							context.phase = :handleRequest
							@currentPage.session = self
							@currentPage.handleRequest(context)
							nextPage = context.invokeAction
							if nextPage and nextPage.fragment
								@fragment = nextPage
							else
								@currentPage = nextPage if nextPage
							end

							@requestCount = @requestCount.next
						#end
					else
						@currentPage = requestPage
					end
					handleResponse(context, dispatch_destination)
				rescue PageExpired => e
					expired(@pages.queue.last,context)
				rescue NoAction => e
					mylog.info "Render last page seen because there is no action -- something is probably not right, here."
					#expired(@pages.queue.last,context)
					@currentPage = @pages[@pages.queue.last]
					@currentPage.session = self
					handleResponse(context)
				ensure
					@lock.unlock
#				end
#			end
		end
	
		# Specify a starting page name.
		def startingPageName; 'Main'; end
		
		# Return a component for the starting page; should use startingPageName.
		def startingPage
			Component.pageNamed(startingPageName,self)
		rescue Exception => e
			Logger[Ciowa_log].error "Starting page selection failed with #{e}\n#{e.backtrace.join("\n")}"
			raise e
		end
		
		# Invokes the handleResponse() method on the object representing the page
		# and updates the page cache.
	
		def handleResponse(context, dispatch_destination = nil)
			context.phase = :handleResponse
			return if context.do_not_render
			@currentPage = Component.pageNamed(dispatch_destination.component,self,nil,nil,nil) if dispatch_destination and dispatch_destination.component
			@currentPage = startingPage unless @currentPage
			if !dispatch_destination.nil? and (ddm = dispatch_destination.method) and !FCM.has_key?(ddm)
				context.phase = :handleRequest
				verb_specific_method = "#{ddm}_#{context.request.request_method.upcase}"
				ddm = verb_specific_method if @currentPage.respond_to?(verb_specific_method)
				if @currentPage.respond_to?(ddm)
					@application.reloadModified(@currentPage.class.name)
					@currentPage = context.invokeAction(@currentPage,ddm,dispatch_destination.args) || @currentPage
				else
					@currentPage = startingPage
				end
				context.phase = :handleResponse
			end
				
			fp = @currentPage.fingerprint
			if fp and @application.rendered_content.has_key?(fp)
				rc = @application.rendered_content[fp]
				context.response_buffer << rc[0]
				context.response.content_type = rc[1]
				rc[2].each do |k,v|
					context.response.headers[k] = v
				end
			else
				context.requestID = @requestCount unless @currentPage.replaceable? or (@fragment and @fragment.replaceable?)
				unless @fragment
					@currentPage.handleResponse(context)
				else
					@fragment.handleResponse(context)
				end
	
				# The Session delays creating the pagecache until it is needed.
				# This is a performance boost for the most common case, which is
				# a page with some dynamic content, but no form elements or
				# dynamic urls that depend on a cached page for meaning.
			
				context[:allow_docroot_caching] = @currentPage.allow_docroot_caching?

				unless context[:skip_pagecache]
					initialize_pagecache if !@pages
					@pages[context.requestID] = @currentPage if @currentPage.cacheable?
					@pages[context.requestID].session = nil if @pages[context.requestID].respond_to?(:session) and @currentPage.cacheable?
				else
					@application.rendered_content[fp] = [context.response_buffer,context.response.content_type,context.response.headers] if fp
				end
			end
		rescue Exception => e
			Logger[Ciowa_log].error "Application#handleResponse exception: #{e}\n#{e.backtrace.join("\n")}"
			raise e
		end

		# If one passes into resource_url content of some sort plus an optional
		# content type (default is application/data if not specified), it will
		# return a URL that can be used to access that content.  If, on the
		# other hand, one passes an arbitrary set of arguments and a block,
		# a url will be returned that, when accesed, will cause the block to
		# be executed.  If the block returns an instance of Iowa::Resource,
		# the content in the resource will be returned as a result of calling
		# that URL, with the content type specified in the resource object.
		# Any other return value will have that value returned as the result
		# of calling the URL, with a content type of 'application/data'.
		# The resources are tied to the page that created them, so they are
		# available until the page expires.  Once the page expires, the
		# resource is deleted as well.
		def resource_url(*args,&block)
			if block_given?
				resource = [block,args]
			else
				resource = Iowa::Resource.new(args[0], args[1], args[2])
			end
			resourceID = "r_#{@requestCount}.#{@resourceCount}"
			@resources[resourceID] = resource
			@resources_by_component[@context.requestID] ||= []
			@resources_by_component[@context.requestID].push resourceID
			@resourceCount = @resourceCount.next
			return "#{@context.sessionURL}.#{resourceID}#{@context.locationFlag}"
		end
		alias :resourceUrl :resource_url
		
		def handle_resource(context)			
			r = @resources["#{context.requestID}.#{context.actionID}"]
			resource = r.kind_of?(Array) ? r[0].call(*r[1]) : r
			if resource.kind_of? Iowa::Resource
				context.response_buffer << resource.body
				context.response.content_type = resource.content_type
				if resource.headers
					resource.headers.each do |k,v|
						context.response.headers[k] = v
					end
				end
			else
				context.response << resource.to_s
				context.response.content_type = Capplication_data
			end
		end
		
		# Redirects the browser to the given URL.  Second optional param is a true/false
		# flag to indicate whether the redirect should be presented as permanent (301) or
		# not (302).
		def redirect(url,permanent = false)
			context.response.headers[CLocation] = url
			context.response.status = permanent ? 301 : 302
		end
		
		# Resets the session.  Useful as part of logging someone out of an application.
		# Once the page cache is cleared, they can not backtrack.
		
		def reset
			@currentPage = nil
			@requestCount = 'a'
			@resourceCount = 'a'
			@resources = {}
			@resources_by_component = {}
			@notes = {C__keystack => []}
			unless Iowa.config[Csession][Cpagecache][Cclass]
				Iowa.config[Csession][Cpagecache][Cclass] = 'iowa/caches/LRUCache'
				Iowa.config[Csession][Cpagecache][Cmaxsize] = @cachedPages
				Iowa.config[Csession][Cpagecache][Cttl] = @cacheTTL
			end
			self.class.PageCache = nil unless self.class.PageCache
		end

		# Clears the page cache.  Takes one optional argument.  The
		# first optional argument specifies how many entries to leave in the
		# page cache; it defaults to 0.
		def clear_history(leave = 0)
			ps = @pages.size
			@pages.size = leave
			@pages.size = ps
			GC.start
		end
		
		def [](v)
			@notes[v]
		end

		def []=(k,v)
			@notes[k] = v
		end

		private
	
		def initialize_pagecache
			@pages = self.class.PageCache
			@pages.add_finalizer(@resources,@resources_by_component) do |key,obj,resources,resources_by_component|
				if resources_by_component.has_key? key
					resources_by_component[key].each do |res_id|
						resources.delete res_id
					end
					resources_by_component.delete key
				end
			end
		end

		# Returns an explanation that the page being requested has expired, then
		# issues a redirect to the head of the app.  It'd be neat if there were
		# some easy way to configure the contents of this page for an app.

		def expired(most_recent_page,context)
			context.response << "<html><head><meta http-equiv=REFRESH content='#{@expiryDelay}; URL=#{context.sessionURL}.#{most_recent_page}.0#{context.locationFlag}'></head><body><b>That page has expired.<p>You are being forwarded to your <a href='#{context.sessionURL}.#{most_recent_page}.0#{context.locationFlag}'>current point</a> in the session.  Please continue from there.</b></body></html>"
		end
	end

end
