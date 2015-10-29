require 'thread'
require 'iowa/Hash'
require 'iowa/Request'
require 'iowa/KeyValueCoding'
require 'iowa/caches/LRUCache'

module Iowa
	module Dispatchers
		class StandardDispatcher
			attr_accessor :mapfile
			
			class NoMapFile < Exception; end

			# {:mapfile => 'FILENAME', :poll_interval => 30, :map => {'/foo/bar.html' => 'Bar'}, :rewrites => [], :secondary_rewrites => []}
			def initialize(*args)
				@mutex = Mutex.new
				@mapfileMTime = Time.at(1)
				@next_check = Time.at(1)
				if args[0].respond_to?(:[])
					if args[0].kind_of?(::Hash)
						oargs = args[0]
						args = Iowa::Hash.new
						args.step_merge!(oargs)
					end
					args.stringify_keys! if args.respond_to? :stringify_keys!
					@mapfile = args[Cmapfile]
					@poll_interval = args['poll_interval'] ? args['poll_interval'].to_i : 30
					@path_map = args['map'] || {}
					@rewrites = RuleSet.new(args['rewrites'] || [])
					@secondary_rewrites = RuleSet.new(args['secondary_rewrites'] || [])
				else
					@mapfile = args[0]
					@poll_interval = args[1] ? args[1].to_i : 30
					@path_map = args[2] || {}
					@rewrites = RuleSet.new(args[3] || [])
					@secondary_rewrites = RuleSet.new(args[4] || [])
				end

				raise(NoMapFile, "The mapfile (#{@mapfile}) does not appear to exist.") if !FileTest.exist?(@mapfile.to_s) if @mapfile
				@mapfile ||= 'mapfile.map' if FileTest.exist?('mapfile.map')
				check_mapfile
				@mapfile
			end

			# Checks to see if the mapfile needs to be reloaded.  To avoid
			# a deluge of stat() calls, it will only check once every
			# @poll_interval seconds (set during initialization; defaults to
			# 30 seconds).
			
			def check_mapfile
				if @mapfile and @next_check < Time.now
					@mutex.synchronize do
						@next_check = Time.at(Time.now + @poll_interval)
						if File.stat(@mapfile).mtime != @mapfileMTime
							load_mapfile
						end
					end
				end
			end

			# Loads @mapfile.
			
			def load_mapfile
				raw_data = {}
				File.open(@mapfile) do |mf|
					rd = YAML::load(mf)
					break unless rd.respond_to?(:has_key?)
					raw_data = Iowa::Hash.new
					raw_data.step_merge!(rd)
					raw_data.symbolify_keys!
					rs = raw_data.has_key?(:rewrites) ? raw_data[:rewrites] : []
					@rewrites = RuleSet.new(rs)
					rs = (raw_data.respond_to?(:[]) and raw_data.has_key?(:secondary_rewrites)) ? raw_data[:secondary_rewrites] : []
					@secondary_rewrites = RuleSet.new(rs)
					@path_map = (raw_data.respond_to?(:[]) and raw_data.has_key?(:map)) ? raw_data[:map] : {}
					if raw_data.respond_to?(:delete)
						raw_data.delete(:rewrites)
						raw_data.delete(:secondary_rewrites)
						raw_data.delete(:map)
					end
					raw_data.each {|k,v| @path_map[k] = v if (k.class.is_a?(String) and v.class.is_a?(String))}
					@mapfileMTime = mf.mtime
					end
			end

			# Returns true if the dispatcher is willing to handle this request.
	
			def handleRequest?(request)
				check_mapfile
				if !Iowa.app.policy.getIDs(request.uri)[1].nil?
					true
				else
					process(request)
				end
			end
		
			# Dispatches the request.
		 
			def dispatch(session,context,dispatch_destination = nil)
				unless dispatch_destination or context.actionID
					request = context.request
					check_mapfile
					dispatch_destination = process(request)
				end
				session.handleRequest(context,dispatch_destination)
			end

			def process(request)
				dd = @rewrites.process(request)
				return dd if dd.is_a?(Iowa::DispatchDestination)
				if c = @path_map[request.uri]
					return Iowa::DispatchDestination.new(c)
				else
					dd = @secondary_rewrites.process(request)
					return dd if dd.is_a?(Iowa::DispatchDestination)

					# At this point, the easy checks are done.  If we are still here, there was no
					# match in the mapfile, and no rule provided a specific dispatch destination.
					# So, use a set of heuristics, assuming a RESTfully structured URI, to figure
					# out what should be done.
					#
					# The basic pattern that is expected is /component/method/arg1/arg2/argn
					#
					# On top of this basic pattern, there are some specific exceptions, based on
					# the HTTP verb the request is using (GET, PUT, POST, DELETE), that
					# deviate from that basic pattern.  These provide shortcuts for RESTful URLs,
					# and are based in part on the RESTful Rails work.
					#
					# Method dispatch also supports the notion of dispatching to verb specific
					# methods.  This is ultimately carried out in the Context object when an
					# action is being invoked, however, as the target object must be interrogated
					# to determine whether it has a method specific to the verb.
					# 

					dd = nil
					request_uri = request.uri.sub(/\.\w+$/,C_empty)
					#/component/method/arg1/arg2/argn
					if request_uri =~ /^\/(\w+)\/(?:(\w+)((?:\/\w+)+)|([a-zA-Z]\w*)((?:\/\w+)*))$/
						c = $1
						m = $2 || $4
						args = $3 || $5
						args = args ? args[1..-1].to_s.split(C_slash) : []
						dd = Iowa::DispatchDestination.new(c,m,args)
					#/component/arg1/arg2/argn;method
					#elsif request_uri =~ /^\/(\w+)((?:\/[\d\-a-f]+)+);(\w+)$/
					elsif request_uri =~ /^\/(\w+)((?:\/[\w%]+)+);(\w+)$/
						c = $1
						m = $3
						args = $2[1..-1].to_s.split(C_slash)
						dd = Iowa::DispatchDestination.new(c,m,args)
					else
						request.request_method = request.params[C_method] if request.params[C_method]
						rmeth = request.params[C_method] ? request.params[C_method].upcase : request.request_method.upcase
						if rmeth == CGET or rmeth == CHEAD
							if request_uri =~ /^\/(\w+)$/
								dd = Iowa::DispatchDestination.new($1)
							#elsif request_uri =~ /^\/(\w+)((?:\/[\d\-a-f]+)+)$/
							elsif request_uri =~ /^\/(\w+)((?:\/[\w%]+)+)$/
								c = $1
								args = $2[1..-1].to_s.split(C_slash)
								dd = Iowa::DispatchDestination.new(c,Cshow,args)
							end
						elsif rmeth == CPOST
							if request_uri =~ /^\/(\w+)$/
								dd = Iowa::DispatchDestination.new($1,Ccreate)
							end
						elsif rmeth == CPUT
							#if request_uri =~ /^\/(\w+)((?:\/[\d\-a-f]+)+)$/
							if request_uri =~ /^\/(\w+)((?:\/[\w%]+)+)$/
								c = $1
								args = $2[1..-1].to_s.split(C_slash)
								dd = Iowa::DispatchDestination.new(c,Cupdate,args)
							end
						elsif rmeth == CDELETE
							#if request_uri =~ /^\/(\w+)((?:\/[\d\-a-f]+)+)$/
							if request_uri =~ /^\/(\w+)((?:\/[\w%]+)+)$/
								c = $1
								args = $2[1..-1].to_s.split(C_slash)
								dd = Iowa::DispatchDestination.new(c,Cdestroy,args)
							end
						end
					end
					dd
				end
			end
			
# --------------------
			
			class RuleSet
				def initialize(rule_struct)
					@rules = []
					if rule_struct.respond_to?(:[])
						if rule_struct.respond_to?(:has_key?)
							@rules << RewriteRule.new(rule_struct)
						else
							rule_struct.each {|rule| @rules << RewriteRule.new(rule)}
						end
					end
				end

				def process(request)
					catch(:final) do
						@rules.each {|rule| rule.process(request)}
					end
				end

			end

			class RewriteRule
				def initialize(prearg = {:match => '',
					:sub => nil,
					:target => nil,
					:gsub => nil,
					:call => nil,
					:eval => nil,
					:branch => nil,
					:dispatch => nil,
					:final => false,
					:cache => nil})
					arg = Iowa::Hash.new
					arg.step_merge!(prearg)
					arg.symbolify_keys!

					if arg[:cache]
						@cache_size = arg[:cache].to_i > 0 ? arg[:cache].to_i : 100
						self.cacheable = true
					else
						@cache_size = 100
						self.cacheable = false
					end

					@final = arg[:final] ? true : false
					if !arg[:match].is_a?(Regexp) and arg[:match] =~ /^\s*(\{|do).*(\}|end)\s*/m
						instance_eval("@match = Proc.new #{arg[:match]}")
					else
						@match = arg[:match].is_a?(Regexp) ? arg[:match] : Regexp.new(arg[:match])
					end

					if arg[:target] =~ /^\s*(\{|do).*(\}|end)\s*/m
						instance_eval("@target = Proc.new #{arg[:target]}")
					else
						@target = arg[:target]
					end

					@subtype = (arg[:gsub] && :gsub) || (arg[:sub] && :sub) || nil
					rawsub = arg[:gsub] || arg[:sub]
					if rawsub =~ /^\s*(\{|do).*(\}|end)\s*/m
						instance_eval("@subproc = Proc.new #{rawsub}")
						@subsub = nil
					else
						@subsub = rawsub
						@subproc = nil
					end

					if arg[:eval]
						ep = arg[:eval]
						if ep !~ /^\s*(\{|do).*(\}|end)\s*/m
							ep = "{|request| #{ep}}"
						end
						instance_eval("@evalproc = Proc.new #{ep}")
					else
						@evalproc = nil
					end

					@call = arg[:call]
					@branch = arg[:branch] ? RuleSet.new(arg[:branch]) : nil
					if arg[:dispatch] =~ /^\s*(\{|do).*(\}|end)\s*/m
						instance_eval("@dispatch = Proc.new #{arg[:dispatch]}")
						@final = true
					elsif arg[:dispatch]
						@dispatch = Iowa::DispatchDestination.new(arg[:dispatch])
						@final = true
					else
						@dispatch = nil
					end
				end

				def cacheable?
					@cacheable
				end

				def cacheable=(val)
					if val
						@cache = Iowa::Caches::LRUCache(@cache_size)
						@cacheable = true
					else
						@cache = nil
						@cacheable = false
					end
				end

				def component=(c)
					if @destination
						@destination.component = c
					else
						@destination = Iowa::DispatchDestination.new(c)
					end
				end

				def component
					@destination ? @destination.component : nil
				end

				def method=(m)
					if @destination
						@destination.method = m
					else
						@destination = Iowa::DispatchDestination.new(m)
					end
				end

				def method
					@destination ? @destination.method : nil
				end

				def args=(a)
					if @destination
						@destination.args = a
					else
						@destination = Iowa::DispatchDestination.new(a)
					end
				end

				def args
					@destination ? @destination.args : nil
				end

				def process(request)
					do_branch = @branch
					original_uri = request.uri
					request.uri = ::String.new(request.uri) if request.uri.frozen?
					@destination = nil
					if @cacheable and @cache.include?(request.uri)
						request.uri = @cache[request.uri]
						do_branch = false
					elsif (@match.is_a?(::Proc) ? @match.call(request) : @match.match(request.uri))
						if @subtype
							if @subsub
								if @subtype == :sub
									request.uri.sub!(@match,@subsub)
								elsif @subtype == :gsub
									request.uri.gsub!(@match,@subsub)
								end
							elsif @subproc
								if @subtype == :sub
									request.uri.sub!(@match) {|*args| @subproc.call(request,*args)}
								elsif @subtype == :gsub
									request.uri.gsub!(@match) {|*args| @subproc.call(request,*args)}
								end
							end
						elsif @call
							call_completed = false
							if @call =~ /(?:::|^[A-Z][\w\d]*\.)/
								@call.sub!(/^::/,'')
								if @call =~ /::/
									parts = @call.split(/::/).reject {|p| p == ''}
								else
									parts = @call.split('.',2)
								end
								meth = parts.pop
								catch(:bad_const) do
									klass = parts.inject(Object) do |o,n|
										if o.const_defined? n
											o.const_get n
										else
											throw :bad_const
										end
									end
									throw :bad_const unless klass.existsKeyPath?(meth)
									klass.valueForKeyPathWithArgs(meth,request)
									call_completed = true
								end
							end
							unless call_completed
								::TOPLEVEL_BINDING.send(:valueForKeyPathWithArgs,@call,request)
							end
						elsif @evalproc
							@evalproc.call(request)
						end
					
						if do_branch and !@final
							@branch.process(request)
						end

						@destination = @dispatch
						@cache[original_uri] = request.uri if @cacheable

						throw(:final,@destination) if @final
					end

					@destination
				end
			end
		end
	end
end
