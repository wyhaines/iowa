require 'dbi'
require 'thread'

######################
##### DEPRECATED #####
######################
#
# This database connection pool has been deprecated.
# Take a look at the Iowa::Pool and Iowa::Pool::DBConnectionPool
# classes for a look at the way it will be in the future.
#
module Iowa

	class ReInitException < Exception; end
	class MissingConnectionException < Exception; end
  
	CBEGIN = "BEGIN"
	CCOMMIT = "COMMIT"
	CROLLBACK = "ROLLBACK"

	class DbPool
		@monitorThread
		@pool
		@poolSize
 
		attr_reader :host, :dbName
		attr_reader :userName, :password, :monitorInterval

		def make_singleton(conn)
			class << conn
				attr_accessor :status
				attr_accessor :parent

				def freeConnection
					parent.freeConnection(self)
				end

				attr_accessor :transaction_depth

				def begin_transaction
					if @transaction_depth == 0
					self.do(CBEGIN)
				end
				@transaction_depth += 1
				end

				def commit_transaction
					if @transaction_depth == 1
						self.do(CCOMMIT)
					end
					@transaction_depth -= 1
				end

				def rollback_transaction
					if @transaction_depth == 1
						self.do(CROLLBACK)
					end
					@transaction_depth -= 1
				end

				def transaction
					raise InterfaceError, "Database connection was already closed!" if @handle.nil?
					raise InterfaceError, "No block given" unless block_given?
					begin_transaction
					begin
						yield self
						commit_transaction
					rescue Exception
						rollback_transaction
						raise
					end
				end
			end
			conn.status = :IDLE
			conn.parent = self
			conn.transaction_depth = 0
			conn
		end

		def initialize(vendor=nil, host='localhost', dbName=nil, userName=nil, password=nil, poolSize=5, monitorInterval=300, &block)
			if vendor.is_a?(Fixnum)
				poolSize=vendor
				monitorInterval = host if host.is_a?(Fixnum)
				vendor = nil
				host = nil
			end
			@classMutex = Mutex.new
			@connectionFreed = ConditionVariable.new
			@instance = nil
			@mungeBlock = block ? block : Proc.new {|dbh| dbh}
			
			raise ReInitException if @instance

			@classMutex.synchronize {
				@vendor = vendor
				@host = host
				@dbName = dbName
				@userName = userName
				@password = password
				@poolSize = poolSize
				@monitorInterval = monitorInterval
				@pool = []
				0.upto(@poolSize-1) do |i|
					conn = @pool[i] = connect
					make_singleton(conn)
				end
				@monitorThread = Thread.new do
					while(true)
						sleep(monitorInterval)
						@classMutex.synchronize {
							@pool.each_index do |idx|
								conn = @pool[idx]
								begin
									ping = conn.respond_to?(:ping) ? conn.ping : true
									unless ping
										conn.disconnect
										@pool[idx] = make_singleton(connect)
									end
								rescue Exception
									@pool[idx] = make_singleton(connect)
								end
							end
						}
					end
				end
				@instance = self
			}
		end


		def connect
			dbh = nil
			if @vendor
				if @host.to_s != ''
					if @userName.to_s != ''
						dbh = DBI.connect("DBI:#{@vendor}:#{@dbName}:#{@host}", @userName, @password)
					else
						dbh = DBI.connect("DBI:#{@vendor}:#{@dbName}:#{@host}")
					end
				else
					if @userName.to_s != ''
						dbh = DBI.connect("DBI:#{@vendor}:#{@dbName}",@userName,@password)
					else
						dbh = DBI.connect("DBI:#{@vendor}:#{@dbName}")
					end
				end
			end
			@mungeBlock.call(dbh)
		end
 
		def instance?
			return @instance ? true : false
		end

		def finish
			@classMutex.synchronize {
				@monitorThread.stop
				@pool.each do |conn|
					conn.disconnect
				end
			}
		end


		#Get the next idle connection. If there is no idle connection, will block
		#until there is one.
		#Optionally accepts a block. If a block is given, will execute the block
		#and free up the connection afterwards.

		def getConnection
			idleConn = nil #predeclare
# Continuation use here might be sexier, but...why do it?
			@classMutex.synchronize {
#				callcc do |cont|
#					idleConn = @pool.find do |conn|
#						conn.status == :IDLE
#					end
#					if not idleConn
#						@connectionFreed.wait(@classMutex)
#						cont.call
#					end
#				end
				loop do
					idleConn = @pool.find {|c| c.status == :IDLE}
					if not idleConn
						@connectionFreed.wait(@classMutex)
						redo
					end
					break
				end
				idleConn.status = :BUSY
			}
			if block_given?
				begin
					yield idleConn
				ensure
					idleConn.freeConnection
				end
			else
				return idleConn
			end
		end
 

		def freeConnection(usedConn)
			conn = nil
			@classMutex.synchronize {
				conn = @pool.find do |conn|
					conn == usedConn
				end
			}
			if conn
				conn.status = :IDLE
				@connectionFreed.signal
			else
				raise MissingConnectionException
			end

			conn.status
		end
	end                
end
