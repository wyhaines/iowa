require 'iowa/binding_of_caller'
require 'irb'
require 'drb'

module Breakpoint
  extend self

  # This will pop up an interactive ruby session at a
  # pre-defined break point in a Ruby application. In
  # this session you can examine the environment of
  # the break point.
  #
  # You can get a list of variables in the context using
  # local_variables via +local_variables+. You can then
  # examine their values by typing their names.
  #
  # You can have a look at the call stack via +caller+.
  #
  # breakpoints can also return a value. They will execute
  # a supplied block for getting a default return value.
  # A custom value can be returned from the session by doing
  # +throw(:debug_return, value)+.
  #
  # You can also give names to break points which will be
  # used in the message that is displayed upon execution 
  # of them.
  #
  # Here's a sample of how breakpoints should be placed:
  #
  #   class Person
  #     def initialize(name, age)
  #       @name, @age = name, age
  #       breakpoint("Person#initialize")
  #     end
  #
  #     attr_reader :age
  #     def name
  #       breakpoint("Person#name") { @name }
  #     end
  #   end
  #
  #   person = Person.new("Random Person", 23)
  #   puts "Name: #{person.name}"
  #
  # And here is a sample debug session:
  #
  #   Executing break point "Person#initialize" at file.rb:4 in `initialize'
  #   irb(#<Person:0x292fbe8>):001:0> local_variables
  #   => ["name", "age", "_", "__"]
  #   irb(#<Person:0x292fbe8>):002:0> [name, age]
  #   => ["Random Person", 23]
  #   irb(#<Person:0x292fbe8>):003:0> [@name, @age]
  #   => ["Random Person", 23]
  #   irb(#<Person:0x292fbe8>):004:0> self
  #   => #<Person:0x292fbe8 @age=23, @name="Random Person">
  #   irb(#<Person:0x292fbe8>):005:0> @age += 1; self
  #   => #<Person:0x292fbe8 @age=24, @name="Random Person">
  #   irb(#<Person:0x292fbe8>):006:0> exit
  #   Executing break point "Person#name" at file.rb:9 in `name'
  #   irb(#<Person:0x292fbe8>):001:0> throw(:debug_return, "Overriden name")
  #   Name: Overriden name
  def breakpoint(id = nil, context = nil, &block)
    callstack = caller
    callstack.slice!(0, 3) if callstack.first["breakpoint"]
    file, line, method = *callstack.first.match(/^(.+?):(\d+)(?::in `(.*?)')?/).captures

    message = "Executing break point " + (id ? "#{id.inspect} " : "") +
              "at #{file}:#{line}" + (method ? " in `#{method}'" : "")

    if context then
      return handle_breakpoint(context, message, &block)
    end

    Binding.of_caller do |binding_context|
      handle_breakpoint(binding_context, message, &block)
    end
  end

  def handle_breakpoint(context, message, &block) # :nodoc:
    catch(:debug_return) do |value|
      if not use_drb? then
        puts message
        IRB.start(nil, IRB::WorkSpace.new(context))
      else
        @drb_service.add_breakpoint(context, message)
      end

      block.call if block
    end
  end
  private :handle_breakpoint

  # This asserts that the block evaluates to true.
  # If it doesn't evaluate to true a breakpoint will
  # automatically be created at that execution point.
  #
  # You can disable assert checking by setting 
  # Breakpoint.optimize_asserts to true before
  # loading the breakpoint.rb library. (It will still
  # be enabled when Ruby is run via the -d argument.)
  #
  # Example:
  #   person_name = "Foobar"
  #   assert { not person_name.nil? }
  def assert(context = nil, &condition)
    return if Breakpoint.optimize_asserts and not $DEBUG
    return if yield

    callstack = caller
    callstack.slice!(0, 3) if callstack.first["assert"]
    file, line, method = *callstack.first.match(/^(.+?):(\d+)(?::in `(.*?)')?/).captures

    message = "Assert failed at #{file}:#{line}#{" in `#{method}'" if method}. " +
              "Executing implicit breakpoint."

    if context then
      return handle_breakpoint(context, message)
    end

    Binding.of_caller do |context|
      handle_breakpoint(context, message)
    end
  end

  # Whether asserts should be ignored if not in debug mode.
  # Debug mode can be enabled by running ruby with the -d
  # switch or by setting $DEBUG to true.
  attr_accessor :optimize_asserts
  self.optimize_asserts = false

  class DRbService
    class FinishedException < Exception; end

    include DRbUndumped

    def initialize
      @breakpoint = @result = nil
      @has_breakpoint = @is_done = false
    end

    def add_breakpoint(context, message)
      workspace = IRB::WorkSpace.new(context)
      workspace.extend(DRbUndumped)

      @breakpoint = [workspace, message]
      @has_breakpoint = true

      until @is_done; end
      @is_done = false
    end

    def handle_breakpoint(&block)
      until @has_breakpoint; end
      @has_breakpoint = false

      #begin
      yield(@breakpoint)
      #rescue FinishedException
      #end

      @is_done = true
    end
  end

  # Will run Breakpoint in DRb mode. This will spawn a server
  # that can be attached to via the [ TODO: command ] command
  # whenever a breakpoint is executed. This is useful when you
  # are debugging CGI applications or other applications where
  # you can't access debug sessions via the standard input and
  # output of your application.
  #
  # You can specify an URI where the DRb server will run at.
  # This way you can specify the port the server runs on. The
  # default URI is druby://localhost:42531.
  #
  # Please note that breakpoints will be skipped silently in
  # case the DRb server can not spawned. (This can happen if
  # the port is already used by another instance of your
  # application on CGI or another application.)
  def activate_drb(uri = 'druby://localhost:42531')
    @use_drb = true
    @drb_service = DRbService.new
    DRb.start_service(uri, @drb_service)
  end

  def use_drb?
    @use_drb == true
  end
end

module IRB
  def IRB.start(ap_path = nil, main_context = nil, workspace = nil)
    $0 = File::basename(ap_path, ".rb") if ap_path

    # suppress some warnings about redefined constants
    old_verbose, $VERBOSE = $VERBOSE, nil
    IRB.setup(ap_path)
    $VERBOSE = old_verbose

    if @CONF[:SCRIPT] then
      irb = Irb.new(main_context, @CONF[:SCRIPT])
    else
      irb = Irb.new(main_context)
    end

    if workspace then
      irb.context.workspace = workspace
    end

    @CONF[:IRB_RC].call(irb.context) if @CONF[:IRB_RC]
    @CONF[:MAIN_CONTEXT] = irb.context

    trap("SIGINT") do
      irb.signal_handle
    end
    
    catch(:IRB_EXIT) do
      irb.eval_input
    end
  end

  class << self; alias :old_CurrentContext :CurrentContext; end
  def IRB.CurrentContext
    if old_CurrentContext.nil? and Breakpoint.use_drb? then
      result = Object.new
      def result.last_value; end
      return result
    else
      old_CurrentContext
    end
  end

  class Context
    alias :old_evaluate :evaluate
    def evaluate(line, line_no)
      if line.chomp == "exit" then
        exit
      else
        old_evaluate(line, line_no)
      end
    end
  end

  class WorkSpace
    alias :old_evaluate :evaluate

    def evaluate(*args)
      if Breakpoint.use_drb? then
        result = old_evaluate(*args)
        result.extend(DRbUndumped) rescue nil
        return result
      else
        old_evaluate(*args)
      end
    end
  end
end

class DRb::DRbObject
  undef :inspect
end

def breakpoint(id = nil, &block)
  Binding.of_caller do |context|
    Breakpoint.breakpoint(id, context, &block)
  end
end

def assert(&block)
  Binding.of_caller do |context|
    Breakpoint.assert(context, &block)
  end
end
