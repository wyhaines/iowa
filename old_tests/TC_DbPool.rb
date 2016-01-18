require 'test/unit'
require 'external/test_support'
IWATestSupport.set_src_dir
require 'iowa/DbPool'

class TC_DbPool < Test::Unit::TestCase
  @dbpool

	@@testdir = IWATestSupport.test_dir(__FILE__)
	def setup
		Dir.chdir(@@testdir)
		IWATestSupport.announce(:deprecated_dbpool,"Iowa::DbPool -- this is deprecated; don't use this.  Use Iowa::Pools::DbConnectionPool.")

  	@params = Hash.new
		begin
			IO.foreach('tests.conf') do |line|
				next unless (line =~ /^\s*(\w+)\s*=\s*(.*)$/)
				@params[$1.downcase] = $2
			end
		rescue Exception
			raise "There was an error opening tests.conf.  Please verify that it exists and is readable, and then run the tests again."
		end

		unless @params['vendor']
			raise "Database vendor not found; please specify the database vendor in tests.conf."
		end

		unless @params['host']
			raise "Database host not found; please specify the database host in tests.conf."
		end

		unless @params['name']
			raise "Database name not found; please specify the database name in tests.conf."
		end

	end

	def testPool
		assert_nothing_raised("Failed to create an Iowa::DbPool object.") do
			@dbpool = Iowa::DbPool.new(@params['vendor'],@params['host'],@params['name'],@params['user'],@params['password'])
		end

		assert_kind_of(Iowa::DbPool,@dbpool,"The created object is not an Iowa::DbPool or subclass thereof.") 

		assert_raises(Iowa::ReInitException,"Did not raise an exception when an attempt to reinitialize the DbPool was made.") do
			@dbpool2 = Iowa::DbPool.new(@params['vendor'],@params['host'],@params['name'],@params['user'],@params['password'])
		end

		assert_nothing_raised("Failed to get a single DB connection.") do
			@connection = @dbpool.getConnection
			assert_kind_of(DBI::DatabaseHandle,@connection,"The connection returned is not an instance of DBI::DatabaseHandle; it is a #{@connection.type.to_s}.")
		end

		assert_nothing_raised("Failed to free a single DB connection.") do
			assert_equal("IDLE",status = @dbpool.freeConnection(@connection).to_s,"Freeing the connection failed to return a status of IDLE; instead got #{status}.")
		end

		dbh = []
		assert_nothing_raised("Failed while trying to acquire all connections in the connection pool.") do
			1.upto(5) do |idx|
				dbh[idx] = @dbpool.getConnection
			end
		end

		assert_nothing_raised("Failed while performing simple query on each handle in the DbPool.") do
			1.upto(5) do |idx|
				sth = dbh[idx].prepare("select now()")
				sth.execute()
			end
		end

		assert_nothing_raised("Failed while trying to create table for testing.") do
			begin
				dbh[1].do("drop table TC_DbPool")
			rescue Exception
				# NOOP -- don't do anything
			end
			dbh[1].do("create table TC_DbPool (idx varchar(200),val varchar(200))")
		end

		assert_nothing_raised("Failed while freeing all connections in the connection pool.") do
			1.upto(5) do |idx|
				@dbpool.freeConnection dbh[idx]
			end
		end

		trucks = [nil,'Unimog','Ram 3500','Sierra 1500 HD','Mercedes 1113','Ford F-250']
		assert_nothing_raised("Failure while hammering the pool in a stress test.") do
			mutex = Mutex.new
			threads = []
			1.upto(5) do |idx|
				threads << Thread.new(idx) do |myIdx|
					1.upto(1000) do |ni|
						begin
						pv_dbh = nil
						mutex.synchronize do
							pv_dbh = @dbpool.getConnection
						end
						pv_dbh.prepare('insert into TC_DbPool (idx,val) values (?,?)').execute(idx,trucks[idx])
						pv_dbh.prepare('delete from TC_DbPool where idx = ?').execute(idx)
						mutex.synchronize do
							@dbpool.freeConnection pv_dbh
						end
						rescue Exception
							puts "Dying in #{idx} with #{$!}; pv_dbh was #{pv_dbh}\n"
							raise
						end
					end
				end
			end
			count = 0
			while (count < threads.length) do
				count = 0
				threads.each do |aThread|
					count += 1 unless aThread.alive?
				end
				sleep 1
			end
		end

		assert_nothing_raised("Failed while trying to drop testing table.") do
			dbh = @dbpool.getConnection
			dbh.do("drop table TC_DbPool")
		end
	end

end
