module Iowa

# Parse through binding declarations to resolve bindings.
# Resolved bindings are stored within an object variable,
# @bindings.

  class BindingsParser

    MainPattern = /([\w.]+)\s*(:\s*(\w+)\s*)?[{](.*?)^\s*[}]/m

    BodyPattern = /(\w+)\s*=\s*(.+)/

    TrimPattern = /\s*$/
    
    # Apply the MainPattern to the binding data, passing matched
    # information to processMatch().

    def initialize(data, namespace_class = nil)
      @bindings = {}
      @namespace_class = namespace_class
      while data.sub!(MainPattern, "")
        processMatch($1, $3, $4)
      end
    end

    # Create the defined binding.	

    def processMatch(id, klass, data)
      bindingHash = {}
      
      if klass
        bindingHash[Cklass] = klass
      end
    
      while data.sub!(BodyPattern, C_empty)
        key, value = $1, $2
        value.sub!(TrimPattern,C_empty)
        # Just to make sure it is clear, if the binding value either
        # starts with a digit, a quote character, or a colon, then
        # it is assumed to be literal binding.  The value will be
        # ran through eval, and whatever is returned will be used
        # as the value of the binding.
        if /^[a-zA-Z]/.match(value)
          bindingHash[key] = PathAssociation.new(value)
        else
          value.sub!(/^\{/,C_empty)
          value.sub!(/\}\s*$/,C_empty)
          bindingHash[key] = LiteralAssociation.new(Proc.new {|*ns| ns = ns[0] || binding ; eval(value,ns)})
        end
      end

      @bindings[id] = bindingHash
    end

    # Return the Hash of bindings.	

    def bindings
      @bindings
    end
  end

end
