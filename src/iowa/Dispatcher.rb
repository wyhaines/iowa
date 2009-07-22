module Iowa
	class Dispatcher

		class CantHandleRequest < Exception; end

		def initialize(*args)
		end

		# Returns true if the dispatcher is willing to handle this request.
	
		def handleRequest?(path)
			true
		end
		
		# Dispatches the request.
		 
		def dispatch(session,context,dispatch_destination = nil)
			if handleRequest?(context.request.uri)
				dispatch_destination = Iowa::DispatchDestination.new(CMain) unless context.requestID || dispatch_destination
			else
				raise CantHandleRequest, "This dispatcher doesn't know how to handle the request for #{context.request.uri}."
			end
			session.handleRequest(context,dispatch_destination)
		end

	end
end
