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
    def get(object,cache = false,stack_key = C_empty)
      oca_key = "#{stack_key}/#{@association.hash}"
      myval = object.cached_associations[oca_key]
      if cache
        usecache = myval ? true : false
        usecache = false if myval.respond_to?(:empty?) and myval.empty? 
      end
      if cache and usecache
        myval
      else
        object.cached_associations[oca_key] = object.valueForKeyPath(@association)
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

    def get(object = nil, cache = false, stack_key = nil)
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

  class FlexibleAssociation < Association
    def FlexibleAssociation.new(association)
      if association[0] == 123
        association = association.sub(/^\{/,C_empty).sub(/\}\s*$/,C_empty)
        LiteralAssociation.new(Proc.new {|*ns| ns = ns[0] || binding ; eval(association,ns)})
      else
        PathAssociation.new(association)
      end
    end
  end
end
