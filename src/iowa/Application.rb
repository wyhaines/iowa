require 'weakref'
require 'thread'
#require 'log4r'
#include Log4r
require 'iowa/Config'
require 'iowa/String'
#require 'iowa/ISAAC'
require 'iowa/ApplicationStats'
require 'iowa/IowaComponentMixins'
require 'iowa/Request'

module Iowa

  class NoDispatcherFound < LoadError; end
  class NoCacheFound < LoadError; end
  class NoPolicyFound < LoadError; end
  class NoLoggerFound < LoadError; end

  # Application sits at the top of everything.  This class represents an
  # entire Iowa application and handles the things relevant to the application
  # as a whole.
  #
  # TODO: Move the configuration object into the Application and lay the
  # groundwork for allowing more than one application in a process.
  class Application

    DocRootNames = [nil,'docs','doc','htdocs','htdoc'].freeze
    CGIRootNames = [nil,'cgi','cgi-bin'].freeze
    LogRootNames = [nil,'log','logs'].freeze

    module ContentClasses; end
    Content_Classes = ContentClasses

    attr_accessor :location, :serial_number, :policy
  
    unless Object.const_defined?(:BindingCommentsRegexp)
      BindingCommentsRegexp = /^\s*#.*$/
    end

    @applicationClass = self

    def self.root_directory
      File.dirname( File.expand_path( Process.argv0 ) )
    end

    def self.applicationClass
      @applicationClass
    end

    def self.applicationClass=(val)
      @applicationClass = val
    end

    # Returns a new instance of Application

    def self.newApplication(*args)
      @applicationClass.new(*args)
    end

    # Allows one to specify a subclass to be used when creating new
    # objects with newApplication().

    def self.inherited(subclass)
      @applicationClass = subclass
    end

    # Deprecated.  Set/use in the config file/config object.
    def self.cachedSessions
      Iowa.config[Capplication][Csessioncache][Cmaxsize] ||= 300
      Iowa.config[Capplication][Csessioncache][Cmaxsize]
    end
  
    def self.cachedSessions=(val)
      Iowa.config[Capplication][Csessioncache][Cmaxsize] = val
    end

    # Deprecated.  Set/use in the config file/config object.
    def self.cacheTTL
      Iowa.config[Capplication][Csessioncache][Cttl]
    end
  
    def self.cacheTTL=(val)
      Iowa.config[Capplication][Csessioncache][Cttl] = val
    end

    def self.iowa_path
      ic = Iowa.config[Capplication]
      if ic[Ciowa_path].nil? or ic[Ciowa_path].empty?
        ic[Ciowa_path] = [iowa_root]
      end
      ic[Ciowa_path]
    end

    def self.iowa_path=(val)
      Iowa.config[Capplication][Ciowa_path] = val.is_a?(Array) ? 
        val :
        [val.to_s]
    end

    def iowa_path
      self.class.iowa_path
    end

    def iowa_path=(val)
      self.class.iowa_path = val
    end

    def self.iowa_root
      ic = Iowa.config[Capplication]
      if (ic[Croot_path].nil? or ic[Croot_path].empty?) and (ic[Ciowa_root].nil? or ic[Ciowa_root].empty?)
        ic[Croot_path] = ic[Ciowa_root] = Application.root_directory
      elsif ic[Ciowa_root].nil? or ic[Ciowa_root].empty?
        ic[Ciowa_root] = ic[Croot_path]
      elsif ic[Croot_path].nil? or ic[Croot_path].empty?
        ic[Croot_path] = ic[Ciowa_root]
      end
      Iowa.config[Capplication][Ciowa_root]
    end

    def self.iowa_root=(val)
      Iowa.config[Capplication][Croot_path] = Iowa.config[Capplication][Ciowa_root] = val
    end

    def iowa_root
      self.class.iowa_root
    end

    def iowa_root=(val)
      self.class.iowa_root = val
    end

    def self.root_path
      iowa_root
    end

    def self.root_path=(val)
      iowa_root = val
    end

    def root_path
      self.class.root_path
    end

    def root_path=(val)
      self.class.root_path = val
    end

    private
    def self.find_app_root_dir(names,item)
      ic = Iowa.config[Capplication]
      if ic[item].nil? or ic[item].empty?
        iwabd = File.dirname(iowa_root)
        iwadr = names.inject(nil) {|dr,n| FileTest.exist?(File.join([iwabd,n].select {|x|x})) ? (dr = n) : dr}
        ic[item] = iwadr ? File.join(iwabd,iwadr) : nil
        ic[item]
      else
        ic[item]
      end
    end
    public

    def self.doc_root
      dr = Iowa.config[Capplication][Cdoc_root]
      (dr.nil? or dr.empty?) ? find_app_root_dir(DocRootNames,Cdoc_root) : dr
    end

    def self.doc_root=(val)
      Iowa.config[Capplication][Cdoc_root] = val
    end

    def doc_root
      self.class.doc_root
    end

    def doc_root=(val)
      self.class.doc_root = val
    end

    def self.cgi_root
      find_app_root_dir(CGIRootNames,Ccgi_root)
    end

    def self.cgi_root=(val)
      Iowa.config[Capplication][Ccgi_root] = val
    end

    def cgi_root
      self.class.cgi_root
    end

    def cgi_root=(val)
      self.class.cgi_root = val
    end

    def self.log_root
      find_app_root_dir(LogRootNames,Clog_root)
    end

    def self.log_root=(val)
      Iowa.config[Capplication][Clog_root] = val
    end

    def log_root
      self.class.log_root
    end

    def log_root=(val)
      self.class.log_root = val
    end

    class << self
      alias_method :iowaroot, :iowa_root
      alias_method :iowaroot=, :iowa_root=
      alias_method :rootpath, :root_path
      alias_method :rootpath=, :root_path=
      alias_method :docroot, :doc_root
      alias_method :docroot=, :doc_root=
      alias_method :cgiroot, :cgi_root
      alias_method :cgiroot=, :cgi_root=
      alias_method :logroot, :log_root
      alias_method :logroot=, :log_root=
    end
    alias_method :iowaroot, :iowa_root
    alias_method :iowaroot=, :iowa_root=
    alias_method :rootpath, :root_path
    alias_method :rootpath=, :root_path=
    alias_method :docroot, :doc_root
    alias_method :docroot=, :doc_root=
    alias_method :cgiroot, :cgi_root
    alias_method :cgiroot=, :cgi_root=
    alias_method :logroot, :log_root
    alias_method :logroot=, :log_root=

    def self.ViewFileSuffixes
      @view_suffix_src ||= nil
    end

    def self.ViewFileSuffixes=(val)
      @view_suffix_src = val
      @@view_suffixes = val.collect {|s| ".#{s}"}
      @@view_regex = Regexp.new("\.#{val.join('$|\.')}$")
      @@search_regex = Regexp.new("\.#{val.join('$|\.')}$|\\.bnd$")
      @@view_file_regex = Regexp.new(".*\\/(.+)\\.(#{val.join('|')})")
    end

    def self.Daemonize
      Iowa.config[Capplication][Cdaemonize] = false unless Iowa.config[Capplication][Cdaemonize].is_a?(String)
      Iowa.config[Capplication][Cdaemonize]
    end

    def self.Daemonize=(args)
      Iowa.config[Capplication][Cdaemonize] = args
    end

    def self.Config
      @config ||= nil
    end

    def self.Config=(args)
      @config = args
    end

    def self.Dispatcher
      @dispatcher ||= nil
    end

    def self.Models
      Iowa.config[Capplication][Cmodel][Cfiles] ||= []
      Iowa.config[Capplication][Cmodel][Cfiles]
    end

    def self.Models=(args)
      if args.class.kind_of?(String)
        Iowa.config[Capplication][Cmodel][Cfiles] = [args]
      else
        Iowa.config[Capplication][Cmodel][Cfiles] = args
      end
    end

    def self.Dispatcher=(args)
      @dispatcher = Util.get_dispatcher(args)
    end

    def self.SessionCache
      @session_cache ||= nil
    end

    def self.SessionCache=(args)
      @session_cache = Util.get_cache(args)
    end

    def self.Policy
      @policy ||= nil
    end

    def self.Policy=(args)
      @policy = Util.get_policy(args)
    end
    
    def self.Logger
      @logger ||= nil
    end

    def self.Logger=(args)
      @logger = Util.get_logger(args)
      Logger[Ciowa_log] = @logger
      Iowa.const_set(:Log,@logger)
      @logger
    end

    def self.serializeCompiledTemplates
      Iowa.config[Capplication][Cserialize_templates]
    end

    def self.serializeCompiledTemplates=(val)
      Iowa.config[Capplication][Cserialize_templates] = val
    end

    # Performs all of the work necessary to start a new Iowa Application.

    def initialize(docroot)
      self.class.iowa_root
      self.class.log_root
      if self.class.Config && FileTest.exist?(self.class.Config)
        Iowa.readConfiguration(self.class.Config)
      else
        Iowa.checkConfiguration
      end
      self.class.Logger = nil unless self.class.Logger

#     begin
#       mylog = Logger[Ciowa_log]
#       raise "need a default logger" unless mylog
#     rescue Exception
#       # Logger must not be defined.  Make sure a basic default exists!
#       require 'logger'
#       Iowa.const_set(:Logger, {Ciowa_log => ::Logger.new(nil)})
#       mylog = Logger[Ciowa_log]
#     end

      mylog = Iowa::Log
      @myclass = self.class
      @keep_statistics ||= false
      @docroot = docroot
      Iowa.config[Capplication][Cdocroot_caching] = false if Iowa.config[Capplication][Cdocroot_caching].nil?
      Iowa.config[Capplication][Cdispatcher][Cclass] = 'iowa/Dispatcher' unless Iowa.config[Capplication][Cdispatcher][Cclass]
      Iowa.config[Capplication][Cpolicy][Cclass] = 'iowa/Policy' unless Iowa.config[Capplication][Cpolicy][Cclass]
      unless Iowa.config[Capplication][Csessioncache][Cclass]
        Iowa.config[Capplication][Csessioncache][Cclass] = 'iowa/caches/LRUCache'
        Iowa.config[Capplication][Csessioncache][Cmaxsize] = 300
        Iowa.config[Capplication][Csessioncache][Cttl] = nil
      end
      
      Iowa.config[Capplication][Cpath_query_interval] = int_or_nil(Iowa.config[Capplication][Cpath_query_interval])
      Iowa.config[Capplication][Creload_interval] = int_or_nil(Iowa.config[Capplication][Creload_interval])
      
      self.class.Dispatcher = nil unless  self.class.Dispatcher
      self.class.SessionCache = nil unless self.class.SessionCache
      self.class.SessionCache.add_finalizer {|key, obj| obj.lock = nil}
      self.class.Policy = nil unless self.class.Policy
      @sessions = self.class.SessionCache
      @policy = self.class.Policy
      self.class.ViewFileSuffixes = %w(htm html vew view) unless self.class.ViewFileSuffixes
      Iowa.config[Capplication][Cserialize_templates] = false unless Iowa.config[Capplication][Cserialize_templates] and (Iowa.config[Capplication][Cserialize_templates] == true or !Iowa.config[Capplication][Cserialize_templates].empty?)
      @templateCache = {}
      @templateMTimes = Hash.new {|h,k| h[k] = Time.at(1)}
      @templateLTimes = {}
      @templateRTimes = Hash.new {|h,k| h[k] = Time.at(1)}
      @pathNameCache = {}
      @appLock = Mutex.new
      @statistics = Iowa::ApplicationStats.new(@sessions)
      @reload_scan_mode = Csingular
      $iowa_application = self

      Iowa.config[Capplication][Cmodel][Cinterval] ||= 300
      Iowa.config[Capplication][Cmodel][Cvariation] ||= 60
      if self.class.Models.empty?
        bn = File.basename($0)
        ['models/','model.rb',bn.sub(/\.\w+$/,'.mdl'),bn.sub(/\.\w+$/,'.model')].each do |m|
          self.class.Models << m if FileTest.exist? m
        end
      end
      model_monitor
      Thread.start {model_monitor(true)}

      self.class.doc_root
      self.class.cgi_root
      self.class.log_root

      mylog.info "  Application with docroot of #{docroot} initialized."
      mylog.info "    docroot_caching is #{Iowa.config[Capplication][Cdocroot_caching] ? 'enabled' : 'disabled'}"
    end

    private
    def int_or_nil(n)
      Integer(n)
    rescue
      nil
    end
    public
      
    def read_model(model)
      Logger[Ciowa_log].info "Loading model #{model}."
      load model
    end

    def model_mtime(path)
      mtime = File.stat(path).mtime
      Logger[Ciowa_log].info "#{path} : #{mtime} != #{@model_mtimes[path]}"
      if mtime != @model_mtimes[path]
        @model_mtimes[path] = mtime
        true
      else
        false
      end
    end

    def model_monitor(doloop = false)
      @model_mtimes = {}
      begin
        if doloop
          sleep_time Iowa.config[Capplication][Cmodel][Cinterval] + rand(Iowa.config[Capplication][Cmodel][Cvariation].to_i)
          Logger[Ciowa_log].info "model monitor sleeping for #{sleep_time} seconds"
          sleep(sleep_time)
        end
        Thread.exclusive do
          self.class.Models.each do |model|
            Logger[Ciowa_log].info "model #{model}"
            next unless FileTest.exist? model
            if FileTest.directory? model
              Logger[Ciowa_log].info "  directory"
              require 'find'
              Find.find(model) do |path|
                Logger[Ciowa_log].info "    checking #{path}"
                next if FileTest.directory? path
                read_model(path) if model_mtime(path)
              end
            else
              read_model(model) if model_mtime(model)
            end
          end
        end
      end while doloop
    end

    def rendered_content
      @rendered_content ||= Iowa::Caches::LRUCache.new({:maxsize => 100})
    end

    def rand(num)
      @policy.rand(num)
    end

    def statistics
      @statistics
    end
  
    def reload_scan_mode
      @reload_scan_mode
    end
  
    # Set the reload scanning mode.  The two current settings are 'singular'
    # and 'plural'.
    #   singular: only check the named template for loading.  This is much
    #     more efficient for large applications as it eliminates making a stat()
    #     system call on each file for every single request.  Most of the time
    #     this should be sufficient for detecting any changes that have been
    #     made and reloading them.  If, in some case, it is found not to be
    #     sufficient, one can set the mode to 'plural' which is the old
    #     normal mode of operation.  'singular' is the default mode of
    #     operation.
    #   plural: checks the mtime of every file in the iowa docroot directory
    #     every time a request is handled.  This is guaranteed to detect
    #     and reload changes in every file.  For sites that have a lot of
    #     files in their docroot, though, this is a performance hit.
    #     There really should never be a need to run in plural mode
    #     so this is deprecated and will be removed soon.
    def reload_scan_mode=(mode)
      if mode == Csingular
        @reload_scan_mode = Csingular
      else
        @reload_scan_mode = Cplural
      end
    end

    # Dispatches the request to the session.  This can be overridden in order to
    # make more complex decisions about which page to display, but the prefered
    # approach is to leave this method alone and to provide a custom dispatcher.

    def dispatcher(session,context,dispatch_destination = nil)
      @myclass.Dispatcher.dispatch(session,context,dispatch_destination)
    end
  
    # handleRequest() is called whenever a request is made to the application.
  
    def handleRequest(context,dispatch_destination = nil)
      session = exception = nil
      @statistics.hit if @keep_statistics
      # ToDo: Clean this up so that we can make it work with only
      # one begin/end block, or even better, with just rescue clauses.
      begin
        unless context.sessionID.to_s != C_empty
          context.sessionID = @policy.new_session_key
          @sessions[context.sessionID] = Session.newSession
          @sessions[context.sessionID].application = self
        end
        session = @sessions[context.sessionID] unless exception
      rescue Exception => exception
        throw :session_error,exception
      end
      if session
        dispatcher(session,context,dispatch_destination)
      else
        begin
          invalidSession(context)
        rescue Exception => exception
        end
        if exception
          throw :session_error,exception
        end
      end
    end

    def search_proc(dirpath)
      r = []
      Dir.foreach(dirpath) do |filename|
        next if filename == C_dot or filename == C_dotdot or filename =~ /^\./ or filename =~ /^[a-z]/
        fullname = "#{dirpath}/#{filename}"
        if FileTest.directory? fullname
          r << search_proc(fullname)
        elsif @@search_regex.match(filename)
          r.push fullname.gsub(/\/\//,C_slash)
        end
      end
      r
    end

    # Reload a component if it has changed.
  
    def reloadModified(component_class=nil,only_if_singular=nil,import_call=false)
      unless @templateRTimes[component_class.to_s] > Time.now
        @templateRTimes[component_class.to_s] = Time.now + reload_interval
        pathlist = nil
        classname = component_class.to_s.split(ClassSeparator).last.to_s
        if (reload_scan_mode == Csingular and !classname.nil?)
          pathlist = [pathForName(component_class)].compact
        elsif (reload_scan_mode != Csingular and !only_if_singular)
          pathlist = search_proc(@docroot)
        end
    
        if pathlist
          if import_call
            reloadLoop(pathlist)
          else
            reloadLoop(pathlist)
          end
        end
      end
    end

    # Check the modification time on the template files in order to
    # determine if the template needs to be reloaded.
    
    def checkMtime(path)
      file = File.new(path)
      fileMtime = file.mtime

      iwaPath = path.sub(@@view_regex, C_iwa)
      if File.exist?(iwaPath)
        iwaMtime = File.stat(iwaPath).mtime
        fileMtime = iwaMtime if iwaMtime > fileMtime
      end
      
      
      
      bndPath = path.sub(@@view_regex,C_bnd)
      if File.exist?(bndPath)
        bndMtime = File.stat(bndPath).mtime
        fileMtime = bndMtime if bndMtime > fileMtime
      end

      fileMtime

    rescue Exception => e
      Logger['iowa_log'].error e.to_s
      Time.at(1)
    end

    def reload_interval
      Iowa.config[Capplication][Creload_interval] || 60
    end

    def reloadLoop(pathlist)
      return unless pathlist
      mylog = Logger[Ciowa_log]
      pathlist.each do |path|
        next if @templateRTimes[path] > Time.now
        mtime = @templateMTimes[path]
        next if Time.now < (mtime + reload_interval)
        @templateRTimes[path] = Time.now + reload_interval
  
        fileMtime = checkMtime(path)
  
        unless mtime and mtime >= fileMtime
          mylog.info "Loading template #{path}"
          reload File.new(path)
          @templateMTimes[path] = fileMtime
        end
      end
    end

    def initialLoad
      mylog = Logger[Ciowa_log]
      # There really shouldn't be any reason to load all of the files
      # initially anymore, but just in case, we'll still allow it via
      # a config setting.
      unless Iowa.config[Capplication][Cdo_initial_load]
        mylog.info "Not loading any files initially."
        return
      end
      
      search_proc = proc do |dirpath|
        r = []
        Dir.foreach(dirpath) do |filename|
          next if filename == C_dot or filename == C_dotdot or /^\./.match(filename) or /^[a-z]/.match(filename)
          fullname = "#{dirpath}/#{filename}"
          if FileTest.directory? fullname
            r << search_proc.call(fullname)
          elsif @@view_regex.match(filename)
            r.push fullname
          end
        end
        r.flatten.sort
      end

      pathlist = search_proc.call(@docroot)

      reloadLoop(pathlist)
    end

    # Returns the template that implements the named component.

    def templateForComponent(name)
      template = nil
      pfn = pathForName(name)
      if @templateCache.has_key? pfn
        if @templateCache[pfn].respond_to? :weakref_alive?
          rtc = 0
          begin
            template = @templateCache[pfn].self
          rescue Exception => e
            Logger[Ciowa_log].info "Error: #{e}\n#{e.backtrace.join("\n")}"
            #reload(File.new(pathForName(name)))
            reload(File.new(pfn))
            rtc += 1
            if rtc < 3
              retry
            else
              raise e
            end
          end
        else
          template = @templateCache[pfn]
        end
      else
        
        #reload(File.new(pathForName(name)))
        reload(File.new(pfn)) if pfn
        template = @templateCache[pfn]
      end
      template
    end

    # import is used to make other templates available within the
    # context of the template where it is called.

    def import(name,namespace = nil)
      # TODO: Deal with recursion.  If A imports B and B imports A, we
      # will get stuck.
      namespace = namespace.gsub(ContentClassesNamespace,C_empty).gsub(/^::/,C_empty)
      ft = File.join(@docroot,namespace.gsub(ClassSeparator,C_slash),name)
      template_class = nil
      if namespace != C_empty
        @@view_suffixes.each do |suffix|
          if FileTest.exist?("#{ft}#{suffix}")
            template_class = "#{namespace}::#{name}"
            break
          end
        end
      end
      template_class = name unless template_class

      if reload_scan_mode == Csingular
        reloadModified(template_class,true,true)
      else
        reload File.new(pathForName(template_class))
      end
    end

    private

    def path_query_interval
      Iowa.config[Capplication][Cpath_query_interval] || 60
    end
  
    # Given a component name, finds the path to it.

    def pathForName(name)
      name.gsub!(/Iowa::Application::ContentClasses::/,C_empty)
      return @pathNameCache[name] if @templateLTimes.has_key?(name) and (@templateLTimes[name] < Time.now)
      my_docroot = @docroot
      my_docroot << C_slash unless my_docroot[-1,1] == C_slash
    
      pfn_pre = my_docroot + name.gsub(/::/,C_slash)
      pfn = nil
      @@view_suffixes.each do |sfx|
        tmp_pfn = pfn_pre + sfx
        if FileTest.exist? tmp_pfn
          pfn = tmp_pfn
          @pathNameCache[name] = pfn
          @templateLTimes[name] = Time.now + path_query_interval
          break
        end
      end
      pfn
    end

    # Extract the code and bindings from the code data.
  
    def get_code_and_bindings(codedata)
      codedata.sub!(/<\?(.*?)\?>/m, C_empty)
      bindings = ''
      bindings = $1.gsub(BindingCommentsRegexp,C_empty) if $1
      if m = /<%(.*?)%>/m.match(codedata)
        code = m[1]
      else
        code = codedata
      end
      [code,bindings]
    end

    # This method loads (or reloads) a template file.
    # To completely separate the layout (template) from the code,
    # put the HTML in a file Foo.html, and then place the code for
    # that template into another file, Foo.iwa.

    def reload(file)
      mylog = Logger[Ciowa_log]
      data = file.read
    
      code_text = ''
      bindings_text = ''
    
      # Read the codefile and check for bindings embedded into it.
      codefile_path = file.path.sub(@@view_regex,C_iwa)
      if FileTest.exist?(codefile_path) and FileTest.readable?(codefile_path)
        File.open(codefile_path) do |codefile|
          codedata = codefile.read.gsub(/\cM/,C_empty)
          code_text, bindings_text = *get_code_and_bindings(codedata)
        end
      else
        codedata = data.gsub(/\cM/,C_empty)
        unless /<%.*?%>/m.match(codedata)
          codedata,codefile_path = defaultScript(file)
          codedata.gsub!(/\cM/,C_empty)
          code_text, bindings_text = *get_code_and_bindings(codedata)
        else
          codefile_path = file.path
          codedata.sub!(/<%(.*?)%>/m, C_empty)
          code_text = $1
          codedata.sub!(/<\?(.*?)\?>/m, C_empty)
          bindings_text = $1.gsub(BindingCommentsRegexp,C_empty) if $1
          data = codedata
        end
      end
    
      # Now check for a dedicated bindings file.
      # In a dedicated bindings file, one can have multiple bindings
      # blocks with comments (lines with a first non-whitespace character
      # of #) anywhere.  This is just a feature to allow for some intelligent
      # organization of bindings and comments, if desired.
      bindingfile_path = file.path.sub(@@view_regex,C_bnd)
      if FileTest.exist?(bindingfile_path) and FileTest.readable?(bindingfile_path)
        File.open(bindingfile_path) do |bindingfile|
          bindingdata = bindingfile.read.gsub(/\cM/,C_empty)
          bindingdata = bindingdata.gsub(/<\?/,C_empty).gsub(/\?>/,C_empty).gsub(BindingCommentsRegexp,C_empty) if bindingdata
          bindings_text << bindingdata
        end
      end
    
      # There's a bit of magic that has to occur, now.  In order to
      # support the notion of the subdirectory that the script file
      # is found in relating to the namespace (using modules as
      # namespace) for the component, reload() needs to figure out
      # just what the namespace is supposed to be for the file, then
      # check to see if that namespace has a already been created,
      # create it if it has not, and finally eval the script file
      # content within the context of the namespace (module).
    
      # First, what's the namespace?  Basically, we subtract the
      # Iowa docroot from the file path and see what is left.
    
      my_docroot = @docroot
      my_docroot << C_slash unless my_docroot[-1,1] == C_slash
      script_namespace_parts = file.path.gsub(/^#{my_docroot}/,C_empty).split(C_slash).reject {|x| x == C_empty}
      script_namespace_parts.delete(C_dot)
      script_namespace_parts.delete(C_dotdot)
      class_name = script_namespace_parts.pop.split(C_dot)[0]
      script_namespace_parts.unshift(CContentClasses)
    
      script_namespace = (['Iowa::Application'] + script_namespace_parts).join(ClassSeparator)

      pre = ''
      post = ''
    
      script_namespace_parts.each do |sym|
        pre << "module #{sym}; extend IowaComponentMixins;"
        post << "end;"
      end
      
      mylog.info "Creating namespace #{script_namespace}"
      eval(pre + post)
      eval(script_namespace)
      namespace_class = script_namespace.split(ClassSeparator).inject(Object) { |o,n| o.const_get n }
  
      begin 
        # Now execute our code within the namespace.

        namespace_class.class_eval(code_text,codefile_path)
        new_class = "#{script_namespace}::#{class_name}".split(ClassSeparator).inject(Object) { |o,n| o.const_get n }

        bindings = BindingsParser.new((bindings_text ? bindings_text : C_empty),new_class).bindings

        fdn = File.dirname(file.path)
        compiled_template_file = File.join(fdn,".#{new_class.name}.iwt")
        load_precompiled = false
        if FileTest.exist?(compiled_template_file) and File.mtime(compiled_template_file) > checkMtime(file.path)
          begin
            mylog.info "Loading precompiled template: #{compiled_template_file}"
            @templateCache[file.path] = WeakRef.new(Marshal.load(File.read(compiled_template_file)))
            load_recompiled = true
          rescue Exception => e
            mylog.info "Error with precompiled template: #{e}"
          end
        end
        unless load_recompiled
          mylog.info "Parsing #{file.path} into template cache"
          if self.class.serializeCompiledTemplates && new_class.serializeCompiledTemplate
            @templateCache[file.path] = WeakRef.new(TemplateParser.new(data, bindings,new_class,fdn).root)
          else
            @templateCache[file.path] = TemplateParser.new(data, bindings,new_class,fdn).root
          end
          Logger[Ciowa_log].info("  Done parsing #{file.path}")
        end
      rescue Exception => e
        mylog.info "There was an error while processing #{file.path}:\n#{e.to_s}\n#{e.backtrace}\n"
      end
    end

    # If there is only an HTML file, without either an embedded code section
    # or a corresponding .iwa file, then we apply a basic default.
    # If a file, 'DefaultScriptFile.iwa', exists in the Iowa docroot, the
    # contents of that file will be used for the default script.  That file
    # should be written as a standard Iowa .iwa file, with one exception.
    # The exception is that the name of the class should be written as:
    #   [--CLASSNAME--]
    # This placeholder will be expanded by Iowa into the actual name of the
    # class to be created.
    
    def defaultScript(file)
      mylog = Logger[Ciowa_log]
  
      #name = /.*\/(.+)\.(view|vew|html|htm)/.match(file.path)[1]
      name = @@view_file_regex.match(file.path)[1]
      r = ''
    
      my_docroot = @docroot
      my_docroot << C_slash unless my_docroot[-1,1] == C_slash
      my_docroot_minus_slash = my_docroot.sub(/\/$/,C_empty)
      filepath = file.path
      filepath.sub!(/#{my_docroot}/,C_empty)
    
      path_parts = filepath.split(C_slash)
      # Knock the filename off of the array.
      path_parts.pop
      # And put the docroot path onto the beginning of the array.
      path_parts.unshift my_docroot_minus_slash
      df_found = nil
      search_path = ''
      while path_parts.length > 0
        search_path << "#{path_parts.shift}/"
        default_script_file = search_path + 'DefaultScriptFile.iwa'
        default_script_file.gsub(/\/\//,C_slash)
        if FileTest.exists? default_script_file
          df_found = default_script_file
        end
      end
    
      if df_found
        File.open(df_found,'r') do |fh|
          fh.each {|line| r << line}
        end
        mylog.info "Loaded #{df_found} for script file for #{file.path}"
      else
        r << "<%class [--CLASSNAME--] < Iowa::Component; end%>"
        df_found = 'INTERNAL'
        mylog.info "Used basic scriptfile for #{file.path}"
      end
    
      r.gsub!(/\[--CLASSNAME--\]/,name)
      [r,df_found]
    end


    # Make this something that can be configured.
    
    def invalidSession(context)
      context.response << "<html><head><meta http-equiv=REFRESH content='1; URL=#{context.baseURL}'></head><body><b>That session no longer exists (#{$$}:#{$$.to_s(16)}).<p>You are being forwarded to a <a href='#{context.baseURL}'>new session</a>.</b></body></html>"
    end

  end

end
