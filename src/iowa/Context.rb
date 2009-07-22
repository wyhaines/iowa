require 'iowa/Request'

module Iowa

	class Context

		attr_accessor :request, :response, :response_buffer, :do_not_render
		attr_accessor :actionID, :requestID, :sessionID, :urlRoot, :phase
		attr_accessor :session, :radio_box_id, :prior_exception
		attr_accessor :notes, :changes, :commit_callbacks, :cookies, :bound_tag
	
		def initialize(request = Iowa::Request.new_request, response = Iowa::Response.new)
			@notes = {}
			@cookies = {}
			@request = request
			request.context = self
			@headers = request.headers #Yuck.  Can I change this?
			setup_cookies if @headers.has_key?(CCOOKIE) or @headers.has_key?(CCookie)
			if rc = @request.params[Crequest_cacheable]
				if rc == C0 or rc == Cfalse or rc == CFALSE
					self[:request_cacheable] = false
				elsif rc == C1 or rc == Ctrue or rc == CTRUE
					self[:request_cacheable] = true
				end
			end
			@urlRoot,@sessionID,@requestID,@actionID = Iowa.app.class.Policy.getIDs(request.uri)
			@response = response
			@response_buffer = response.body
			@radio_box_id = {}
			@do_not_render = false
			self.element_attributes = {}
			reset!
		end

		def element_attributes
			@element_attributes
		end
	
		def setup_cookies
			rh = request.headers[CCOOKIE] || request.headers[CCookie]
			rh.split(C_semicolon).each do |cookie|
				k,v = cookie.split(C_equal)
				k.strip!
				v.strip! unless v.nil?
				@cookies[k] = v
			end
		end

		def element_attributes=(attribute)
			@element_attributes = attribute
		end
	
		def baseURL
			Iowa.app.policy.baseURL(self)
		end
	
		def sessionURL
			Iowa.app.policy.sessionURL(self)
		end

		def actionURL
			Iowa.app.policy.actionURL(self)
		end

		def locationFlag
			Iowa.app.policy.locationFlag(self)
		end

		def reset!
			@elementID = []
			pushElement
		
			@commit_callbacks = {}

			@changes = []
			@actionContext = []
        
			@rootStack = []
		
			@action = nil
		
			@state = {:urlForID => {}, :componentForID => {}, :requestNotes => {}, :responseNotes => {}, :skip_pagecache => true}
			@lastBinding = nil
			@lastRoot = nil
		end
	
		def statesafe_reset!
			@elementID = []
			pushElement
			@commit_callbacks = {}
			@changes = []
			@actionContext = []
			@rootStack = []
			@action = nil
			@lastBinding = nil
			@lastRoot = nil
		end

		def url_for_id
			@state[:urlForID]
		end

		def component_for_id
			@state[:componentForID]
		end
		
		def pushElement
			@elementID.push "1"
		end
	
		def popElement
			@elementID.pop
		end
	
		def nextElement!
			@elementID.last.next!
		end
	
		def elementID
			@elementID.join(C_dot)
		end
	
		def elementID=(val)
			@elementID[-1] = val
		end
	
		def setBindingNow(binding, value, notification = nil)
			binding.set(@rootStack.last, value)
			setBinding(binding, value, notification)
		end
    
		def setBinding(binding, value, notification = nil)
			@changes.pop if(@lastBinding == binding && @lastRoot == root)

			if notification and @commit_callbacks.has_key?(binding.association) and @commit_callbacks[binding.association].has_key?(root)
				tmp = @commit_callbacks[binding.association][root]
				cb = tmp[0]
				cbp = tmp[1]
			else
				cb = cbp = nil
			end
			@changes.push [root, binding, value, cb, cbp]
			@lastBinding = binding
			@lastRoot = root
		end
	
		def getBinding(binding, cache = nil, stack_key = C_empty)
			cache ||= @phase == :handleRequest ? true : false
			binding.get(root,cache,stack_key) if binding
		end

		def testBinding(binding)
			binding.test(root)
		end

		def createAccessor(binding)
			unless root.class.method_defined?(binding.association.to_sym)
				root.class.__send__(:attr_accessor, binding.association.to_sym)
			end
			rescue Exception
		end
	
		# TODO: Change this to take multiple args so that a single call can do multiple commits
		def commit(changes)
			changes.each do |target, binding, value, notification, notification_param|
				binding.set(target, value)
				notification.call(value,notification_param) if notification
			end
		end
	
		def setAction(binding)
			@action = [root, binding.get(root)]
			@actionContext = @changes
			@changes = []
		end

		def invokeAction(page = nil, method = nil, args = [])
			raise NoAction unless (method && page) || (@action && !page)
		
			if method and page
				verb_specific_method = "#{method}_#{request.request_method.downcase}"
				method = verb_specific_method if page.respond_to?(verb_specific_method)
			end
			nextPage = nil
			page, method = @action unless page and method
 	  	#commit @changes
			commit @actionContext
			page.invokeAction(method,args) do |newPage|
				nextPage = newPage
			end
 	  	commit @changes
			statesafe_reset!
		
			nextPage
		end

		def pushRoot(root)
			@rootStack.push root
		end
	
		def popRoot
			@rootStack.pop
		end
	
		def root
			@rootStack.last
		end
	
		def [](key)
			@state[key]
		end
	
		def []=(key, val)
			@state[key] = val
		end
	end

end
