# Adapted from the Pool class in Facets, with additional smarts to enable it
# to fullfill my needs as a dbpool that will monitor connections and recover
# from failed connections (such as when the database is restarted) automatically,
# so that the application using the pool never knows about it.

require 'thread'
require 'monitor'

module Iowa
	class Pool < Array

		attr_accessor :start_size, :max_size, :min_size, :max_age, :monitor_interval, :logger, :in_use_count

		include MonitorMixin

		def self.StartSize(val = nil)
			#@start_size ||= nil
			(val or !@start_size) ? (@start_size = val || 1) : @start_size
		end
		def self.start_size(val = nil);StartSize(val);end

		def self.MaxSize(val = nil)
			#@max_size ||= nil
			(val or !@max_size) ? (@max_size = val || 4) : @max_size
		end
		def self.max_size(val = nil);MaxSize(val);end

		def self.MinSize(val = nil)
			#@min_size ||= nil
			(val or !@min_size) ? (@min_size = val || 1) : @min_size
		end
		def self.min_size(val = nil);MinSize(val);end

		def self.MaxAge(val = nil)
			#@max_age ||= nil
			(val or !@max_age) ? (@max_age = val || nil) : @max_age
		end
		def self.max_age(val = nil);MaxAge(val);end

		def self.MonitorInterval(val = nil)
			#@monitor_interval ||= nil
			(val or !@monitor_interval) ? (@monitor_interval = val || 300) : @monitor_interval
		end
		def self.monitor_interval(val = nil);MonitorInterval(val); end

		def self.DoNotMonitor(val = nil)
			#@do_not_monitor ||= nil
			(val or @do_not_monitor.nil?) ? (@do_not_monitor = val || false) : @do_not_monitor
		end
		def self.do_not_monitor(val = nil);DoNotMonitor(val); end

		def self.Logger(val = nil)
			#@logger ||= nil
			(val or @logger.nil?) ? (@logger = val || false) : @logger
		end
		def self.logger(val = nil);Logger(val); end

		def set_monitor(l)
			self.class.__send__(:define_method,:monitor,l)
		end

		def set_newobj(l)
			self.class.__send__(:define_method,:newobj,l)
		end

		def set_valid(l)
			self.class.__send__(:define_method,:valid?,l)
		end

		def initialize(params = {})
			super()
			@start_size = params[:start_size] || self.class.StartSize
			@max_size = params[:max_size] || self.class.MaxSize
			@min_size = params[:min_size] || self.class.MinSize
			@max_size = 1 if @max_size < 1
			@min_size = 0 if @min_size < 0
			@start_size = 0 if @start_size < 0
			@min_size = @max_size - 1 if @min_size > @max_size
			@start_size = @min_size if @start_size > @max_size
			@max_age = params[:max_age] || self.class.MaxAge
			@monitor_interval = params[:monitor_interval] || self.class.MonitorInterval
			@logger = params[:logger]
			set_monitor(params[:monitor]) if params[:monitor]
			set_newobj(params[:newobj]) if params[:newobj]
			set_valid(params[:valid]) if params[:valid]
			@params = params

			@cv = new_cond()
			@monitor_status = nil
			@resource_age = {}
			@in_use_count = 0
			@start_size.times {no = newobj; push(no); @resource_age[no] = Time.now.to_i}
			@in_use_count = 0
			@monitor_thread = monitor_start unless params[:do_not_monitor] or self.class.DoNotMonitor
		end

		def log(msg)
			if @logger
				log_msg = "#{self.class.name} :: #{msg}"
				if @logger.respond_to?(:info)
					@logger.info(log_msg)
				elsif @logger.respond_to?(:puts)
					@logger.puts(log_msg)
				elsif @logger.respond_to(:write)
					@logger.write(log_msg)
				end
			end
		end

		def pool_size
			length + @in_use_count
		end

		def monitor_start
			if @monitor_status
				@monitor_status = :running
			else
				@run_monitor = true
				Thread.start {run_monitor}
			end
		end

		def monitor_pause
			log("Pausing monitoring.")
			@monitor_status = :paused
		end

		def monitor_stop
			@run_monitor = false
		end

		def run_monitor
			log("Starting resource Pool monitor.  Interval is #{@monitor_interval} seconds.")
			while @run_monitor
				unless @monitor_status == :paused
					do_monitor_age unless @monitor_status == :paused
					do_monitor unless @monitor_status == :paused
					do_monitor_minsize unless @monitor_status == :paused
					#@monitor_status = :sleeping
					sleep(@monitor_interval)
				else
					while @monitor_status == :paused
						sleep 2
					end
				end
				#@monitor_status = :running unless @monitor_status == :paused
			end
		end

		def monitor_age(obj)
			(Time.now.to_i - @resource_age[obj]) > @max_age if @max_age
		end

		def do_monitor_age
			delete_list = []
			each_index do |x|
				delete_list.push(x) if monitor_age(self[x])
			end
			delete_list.each {|x| delete_at(x)}
		end

		def monitor(obj)
			valid?(obj)
		end

		def do_monitor
			each_index do |x|
				self[x] = newobj unless monitor(self[x])
			end
		end

		def do_monitor_minsize
			while length < @min_size
				push(newobj)
			end
		end

		def newobj
			true
		end

		def valid?(obj)
			if obj.respond_to?(:ping)
				obj.ping
			elsif obj.respond_to?(:connected?)
				obj.connected?
			elsif obj.respond_to?(:alive?)
				obj.alive?
			else
				obj
			end
		end

		def push(obj)
			synchronize do
				if pool_size <= @max_size
					super
					@in_use_count -= 1
					@resource_age[obj] = Time.now.to_i
					@cv.signal()
					true
				else
					false
				end
			end
		end

		def pop
			synchronize do
				obj = nil
				if empty? and (pool_size < @max_size)
					obj = newobj
					@in_use_count += 1
				else
					@cv.wait_while {empty?} if empty?
					obj = super
					@resource_age.delete(obj)					
					@in_use_count += 1
				end
				if !valid?(obj)
					@in_use_count -= 1
					sleep 1
					redo
				end
				obj
			end
		end

		def obtain
			result = nil
			begin
				obj = pop()
				result = yield(obj)
			ensure
				push(obj)
			end
			result
		end

	end

end

