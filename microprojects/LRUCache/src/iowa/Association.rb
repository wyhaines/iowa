module Iowa
	class Association
	
		def initialize(association)
			@association = association
		end

		def association
			@association
		end

		def test(object)
			true
		end
	end

	class PathAssociation < Association
		def get(object,cache = false)
			myval = object.cached_associations[@association]
			if cache
				usecache = true
				usecache = false unless myval
				if myval.respond_to?(:empty?)
					usecache = false if myval.empty?
				end
			end
			if cache and usecache
				myval
			else
				object.cached_associations[@association] = object.valueForKeyPath(@association)
			end
		end
	
		def set(object, val)
			object.takeValueForKeyPath(val, @association)
		end

		def test(object)
			object.existsKeyPath?(@association)
		end
	end

	class LiteralAssociation < Association

		def get(object = nil, cache = false)
			unless @association.is_a?(Proc)
				@association
			else
				@association.call(object.send(:binding))
			end
		end
	
		def set(object, val)
			@association = val
		end
	end
end
