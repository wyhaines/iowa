require 'pathname'

class Pathname
  def length
    n = 0
    self.each_filename {n += 1}
    n
  end
end

module Iowa
  class DataTable < Hash

    alias :old_get :[]
    def [](idx)
      if old_get(idx).instance_of? Array
        old_get(idx)[0]
      else
        old_get(idx)
      end
    end

    def >>(idx)
      old_get(idx)
    end

    #alias :set :[]=
    def set(k,v)
      if old_get(k).instance_of? Array
        old_get(k) << v
      else
        self[k] = [v]
      end
    end

    def <<(hv)
      if hv.instance_of? Hash
        hv.each {|k,v| set(k,v)}
      elsif hv.instance_of? Array
        hv.each {|k| set(k,true)}
      else
        set(hv,true)
      end
    end

    alias :old_each :each
    def each
      old_each do |key,ary|
        if ary.instance_of? Array
          ary.each do |val|
            yield key,val
          end
        else
          yield key,ary
        end
      end
    end
  end

  module R
    Table = Iowa::DataTable
  end

  module Util
    def Util.hash_from_array(arr)
      h = {}; arr.each {|x| h[x] = true}; h
    end

    def Util.escapeHTML(string)
      string.gsub(/&/n, '&amp;').gsub(/\"/n, '&quot;').gsub(/>/n, '&gt;').gsub(/</n, '&lt;')
    end

    def Util.unescapeHTML(string)
      string.gsub(/&(.*?);/n) do
        match = $1.dup
        case match
        when /\Aamp\z/ni           then '&'
        when /\Aquot\z/ni          then '"'
        when /\Agt\z/ni            then '>'
        when /\Alt\z/ni            then '<'
        when /\A#0*(\d+)\z/n       then
          if Integer($1) < 256
            Integer($1).chr
          else
            if Integer($1) < 65536 and ($KCODE[0] == ?u or $KCODE[0] == ?U)
              [Integer($1)].pack("U")
            else
              "&##{$1};"
            end
          end
        when /\A#x([0-9a-f]+)\z/ni then
          if $1.hex < 256
            $1.hex.chr
          else
            if $1.hex < 65536 and ($KCODE[0] == ?u or $KCODE[0] == ?U)
              [$1.hex].pack("U")
            else
              "&#x#{$1};"
            end
          end
        else
          "&#{match};"
        end
      end
    end

    def Util.escape(string)
      string.to_s.gsub(/([^ a-zA-Z0-9_.-]+)/n) do
        '%' + $1.unpack('H2' * $1.size).join('%').upcase
      end.tr(' ', '+')
    end

    def Util.unescape(string)
      string.to_s.tr('+', ' ').gsub(/((?:%[0-9a-fA-F]{2})+)/n) do
        [$1.delete('%')].pack('H*')
      end
    end

    def wrap(txt,  prefix='', linelen=76)
      return unless txt && !txt.empty?
      work = txt
      textLen = linelen - prefix.length
      patt = Regexp.new("^(.{0,#{textLen}})[ \n]")
      next_prefix = prefix.tr("^ ", " ")

      res = []

      while work.length > textLen
        if work =~ patt
          res << $1
          work.slice!(0, $&.length)
        else
          res << work.slice!(0, textLen)
        end
      end
      res << work if work.length.nonzero?
      (prefix +  res.join("\r\n" + next_prefix))
    end

    def Util.get__set_args(args)
      if args.kind_of?(Array)
        val = args.shift
        args = args.shift
      else
        val = args
        args = nil
      end
      return [val,args]
    end

    def Util.get_cache(args = nil, extraconf = nil, conf = Iowa.config[Capplication], conf_item = Csessioncache,tools_only = false)
      val,args = get__set_args(args)

      val = conf[conf_item][Cclass] unless val
      args = conf[conf_item].dup || {} unless args.respond_to?(:empty?) and !args.empty?
      args.delete(Cclass)
      args.merge!(extraconf) if extraconf
      args = [{:maxsize => conf[conf_item][Cmaxsize], :ttl => conf[conf_item][Cttl]}] if (args.respond_to?(:length) and args.length == 0) or !args
      if val.class.name == CClass
        val.new(args)
      elsif val.respond_to?(:include?) and val.respond_to?(:[]) and val.respond_to?(:[]=) and !val.respond_to?(:capitalize)
        val
      else
        # Turn it into a string and figure things out.
        klass = find_class(val,'iowa/caches',[Iowa.config[Capplication][Croot_path], iowa_inc_paths('iowa/caches'),$:].flatten)
        if klass
          if tools_only
            [klass,args]
          else
            klass.new(args)
          end
        else
          raise Iowa::NoCacheFound
        end
      end
    end

    def Util.get_dispatcher(args = nil)
      conf = Iowa.config[Capplication]
      val,args = get__set_args(args)

      val = conf[Cdispatcher][Cclass] unless val
      args = conf[Cdispatcher] unless args.respond_to?(:empty?) and !args.empty?

      if val.class.name == CClass
        val.new(args)
      elsif val.respond_to?(:handleRequest?) and val.respond_to?(:dispatch)
        val
      else
        klass = Util.find_class(val,'iowa/dispatchers',[conf[Croot_path], iowa_inc_paths('iowa/dispatchers'),$:].flatten)
        if klass
          klass.new(args)
        else
          raise Iowa::NoDispatcherFound
        end
      end
    end

    def Util.get_policy(args = nil)
      conf = Iowa.config[Capplication]
      val,args = get__set_args(args)

      val = conf[Cpolicy][Cclass] unless val
      args = conf[Cpolicy] unless args.respond_to?(:empty?) and !args.empty?

      if val.class.name == CClass
        val.new(args)
      elsif val.respond_to?(:new_session_key) and val.respond_to?(:validate_session)
        val
      else
        klass = Util.find_class(val,'iowa/policies',[conf[Croot_path], iowa_inc_paths('iowa/policies'),$:].flatten)
        if klass
          klass.new(args)
        else
          raise Iowa::NoPolicyFound
        end
      end
    end

    def Util.get_logger(args = nil)
      conf = Iowa.config
      val,args = get__set_args(args)

      val = conf[Clogger][Cclass] unless val
      #args = conf[Clogger][Cargs] unless args.respond_to?(:empty?) and !args.empty?

      if val.class.name == CClass
        val.new(args)
      elsif val.respond_to?(:warn) and val.respond_to?(:info)
        val
      else
        klass = Util.find_class(val,'iowa/loggers',[conf[Capplication][Croot_path], iowa_inc_paths('iowa/loggers'),$:].flatten)
        if klass
          #klass.new(*args)
          klass.new
        else
          raise Iowa::NoLoggerFound
        end
      end
    end

    def Util.iowa_inc_paths(suffix)
      $:.map do |p|
        File.join(p,suffix)
      end.select do |p|
        FileTest.exist? p
      end
    end
    
    def Util.path_combinations_worker(destination,items,path)
      if items.length > 0
        j = items.shift
        j.each {|x| path_combinations_worker(destination,items.dup,"#{path}#{File::SEPARATOR}#{x}")}
      else
        destination.push path
      end
    end

    def Util.path_combinations(items,path = '')
      r = []
      path_combinations_worker(r,items,path)
      r
    end

    def Util.find_class__match_path(match,paths)
      match_without_suffix = match.sub(/\.\w+$/,'')
      klass_name_paths = paths.select {|p| match.index(p) == 0}.
                               sort_by {|p| Pathname.new(p).length}
      klass_name_path = klass_name_paths.last
      if klass_name_path
        match_without_suffix[klass_name_path.length..-1]
      else
        nil
      end
    end

    def Util.find_class(val,classpath_prefix,places)
      thing = Iowa::String.new(val.to_s)
      pieces = thing.split(/::|#{File::SEPARATOR}/)
      parts = []
      pieces.each do |piece|
        x = [piece]
        x.push piece.snake_case if piece != piece.snake_case
        x.push piece.constant_case if piece != piece.constant_case
        x.push piece.snake_case.constant_case if piece != piece.constant_case
        parts.push x
      end
      klass = nil
      places.each do |place|
        has_suffix = parts.last.first =~ /\.\w+$/
        paths = path_combinations(parts.dup,Iowa::String.new(place))
        unless has_suffix
          paths.collect! {|x| x = x + '.rb'}
        end
        match = paths.select do |path|
           FileTest.exists? path
        end
        if match.first
          require match.first
          klass_name = find_class__match_path(match.first,places).sub(/^#{File::SEPARATOR}/,'')
          klass_name = "#{classpath_prefix}#{File::SEPARATOR}#{klass_name}" if klass_name and klass_name !~ /^iowa/i
          if klass_name
            klass = klass_name.split(File::SEPARATOR).collect do |x|
              Iowa::String.new(x).constant_case
            end.inject(Object) { |o,n| o.const_get n }
            break
          end
        end
      end
      klass
    end

  end
end
