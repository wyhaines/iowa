module Iowa

	# Iowa::Mutex is a slight modification of the standard Ruby Mutex class.
	# This class changes the array operations used to manage the queue of
	# threads waiting for a lock in order to get better memory management
	# behavior from the array.  This mutex will also not block if the thread
	# holding a lock on a mutex calls lock on that mutex again.  If nested
	# locking occurs, the locks must be matched by an equal number of unlocks
	# before the mutex will actually be unlocked.

	class Mutex
		
		# Creates a new Mutex.
		
		def initialize
			@waiting = []
			@locked = false;
			@nested_locks = 0
			@waiting.taint		# enable tainted comunication
			self.taint
		end

		
		# Returns the thread that holds the lock or +false+ if the mutex is not locked.
		
		def locked?
			@locked
		end

		
		# Attempts to obtain the lock and returns immediately. Returns +true+ if the
		# lock was granted.
		
		def try_lock
			@nested_locks += 1 and return true if @locked == Thread.current
			result = false
			Thread.critical = true
			unless @locked
				@locked = Thread.current
				result = true
			end
			Thread.critical = false
			result
		end


		# Attempts to obtain a lock on the mutex.  Block if a lock can not be
		# obtained immediately and waits until the lock can be obtained.
		# If this thread already holds this lock, returns immediately.
		# Returns the mutex.

		def lock
			if @locked == Thread.current
				@nested_locks += 1
			else
				while (Thread.critical = true; @locked)
					@waiting.unshift Thread.current
					Thread.stop
				end
				@locked = Thread.current
				Thread.critical = false
			end
			self
		end


		# Releases this thread's lock on the mutex and wakes the next thread
		# waiting for the lock, if any.
		
		def unlock
			return unless @locked
			if @nested_locks > 0
				@nested_locks -= 1
			else
				Thread.critical = true
				@locked = false
				begin
					t = @waiting.pop
					t.wakeup if t
				rescue ThreadError
					retry
				end
				Thread.critical = false
				begin
					t.run if t
				rescue ThreadError
				end
			end
			self
		end

		
		# If the mutex is locked, unlocks the mutex, wakes one waiting thread, and
		# yields in a critical section.
		
		def exclusive_unlock
			return unless @locked
			if @nested_locks > 0
				@nested_locks -= 1
			else
				Thread.exclusive do
					@locked = false
					begin
						t = @waiting.pop
						t.wakeup if t
					rescue ThreadError
						retry
					end
					yield
				end
			end
			self
		end

  
		# Obtains a lock, runs the block, and releases the lock when the block
		# completes.  See the example under Mutex.
  
		def synchronize
			lock
			begin
				yield
			ensure
				unlock
			end
 		end

	end
end
