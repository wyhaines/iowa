require 'windows/error'
require 'windows/process'
require 'windows/synchronize'
require 'windows/handle'
require 'windows/library'
require 'windows/console'
require 'windows/window'

class ProcessError < RuntimeError; end

module Process
   WIN32_PROCESS_VERSION = '0.5.0'
   
   include Windows::Process
   include Windows::Error
   include Windows::Library
   include Windows::Console
   include Windows::Handle
   include Windows::Synchronize
   include Windows::Window
   extend Windows::Error
   extend Windows::Process
   extend Windows::Synchronize
   extend Windows::Handle
   extend Windows::Library
   extend Windows::Console
   
   # Used by Process.create
   ProcessInfo = Struct.new("ProcessInfo",
      :process_handle,
      :thread_handle,
      :process_id,
      :thread_id
   )
   
   @child_pids = []  # Static variable used for Process.fork
   @i = -1           # Static variable used for Process.fork

   # Waits for the given child process to exit and returns that pid.
   # 
   # Note that the $? (Process::Status) global variable is NOT set.  This
   # may be addressed in a future release.
   # 
   def waitpid(pid)
      exit_code = [0].pack('L')
      handle = OpenProcess(PROCESS_ALL_ACCESS, 0, pid)
      
      if handle == INVALID_HANDLE_VALUE
         raise ProcessError, get_last_error
      end
      
      # TODO: update the $? global variable (if/when possible)
      status = WaitForSingleObject(handle, INFINITE)
      
      unless GetExitCodeProcess(handle, exit_code)
         raise ProcessError, get_last_error
      end
      
      CloseHandle(handle)
      @child_pids.delete(pid)
      
      # TODO: update the $? global variable (if/when possible)
      exit_code = exit_code.unpack('L').first
      
      pid
   end
   
   # Waits for the given child process to exit and returns an array containing
   # the process id and the exit status.
   # 
   # Note that the $? (Process::Status) global variable is NOT set.  This
   # may be addressed in a future release.
   # 
   def waitpid2(pid)
      exit_code = [0].pack('L')
      handle    = OpenProcess(PROCESS_ALL_ACCESS, 0, pid)
      
      if handle == INVALID_HANDLE_VALUE
         raise ProcessError, get_last_error
      end
      
      # TODO: update the $? global variable (if/when possible)
      status = WaitForSingleObject(handle, INFINITE)
      
      unless GetExitCodeProcess(handle, exit_code)
         raise ProcessError, get_last_error
      end
      
      CloseHandle(handle)
      @child_pids.delete(pid)
      
      # TODO: update the $? global variable (if/when possible)
      exit_code = exit_code.unpack('L').first
      
      [pid, status]
   end
   
   # Sends the given +signal+ to an array of process id's.  The +signal+ may
   # be any value from 0 to 9, or the special strings 'SIGINT' (or 'INT'),
   # 'SIGBRK' (or 'BRK') and 'SIGKILL' (or 'KILL').  An array of successfully
   # killed pids is returned.
   # 
   # Signal 0 merely tests if the process is running without killing it.
   # Signal 2 sends a CTRL_C_EVENT to the process.
   # Signal 3 sends a CTRL_BRK_EVENT to the process.
   # Signal 9 kills the process in a harsh manner.
   # Signals 1 and 4-8 kill the process in a nice manner.
   # 
   # SIGINT/INT corresponds to signal 2
   # SIGBRK/BRK corresponds to signal 3
   # SIGKILL/KILL corresponds to signal 9
   # 
   # Signals 2 and 3 only affect console processes, and then only if the
   # process was created with the CREATE_NEW_PROCESS_GROUP flag.
   # 
   def kill(signal, *pids)
      case signal
         when 'SIGINT', 'INT'
            signal = 2
         when 'SIGBRK', 'BRK'
            signal = 3
         when 'SIGKILL', 'KILL'
            signal = 9
         when 0..9
            # Do nothing
         else
            raise ProcessError, "Invalid signal '#{signal}'"
      end
      
      killed_pids = []
      
      pids.each{ |pid|
         # Send the signal to the current process if the pid is zero
         if pid == 0
            pid = Process.pid
         end
       
         # No need for full access if the signal is zero
         if signal == 0
            access = PROCESS_QUERY_INFORMATION|PROCESS_VM_READ
            handle = OpenProcess(access, 0 , pid)
         else
            handle = OpenProcess(PROCESS_ALL_ACCESS, 0, pid)
         end
         
         case signal
            when 0   
               if handle != 0
                  killed_pids.push(pid)
                  CloseHandle(handle)
               else
                  # If ERROR_ACCESS_DENIED is returned, we know it's running
                  if GetLastError() == ERROR_ACCESS_DENIED
                     killed_pids.push(pid)
                  else
                     raise ProcessError, get_last_error
                  end
               end
            when 2
               if GenerateConsoleCtrlEvent(CTRL_C_EVENT, pid)
                  killed_pids.push(pid)
               end
            when 3
               if GenerateConsoleCtrlEvent(CTRL_BREAK_EVENT, pid)
                  killed_pids.push(pid)
               end
            when 9
               if TerminateProcess(handle, pid)
                  CloseHandle(handle)
                  killed_pids.push(pid)
                  @child_pids.delete(pid)           
               else
                  raise ProcessError, get_last_error
               end
            else
               if handle != 0
                  thread_id = [0].pack('L')
                  dll       = 'kernel32'
                  proc      = 'ExitProcess'
                  
                  thread = CreateRemoteThread(
                     handle,
                     0,
                     0,
                     GetProcAddress(GetModuleHandle(dll), proc),
                     0,
                     0,
                     thread_id
                  )
                  
                  if thread
                     WaitForSingleObject(thread, 5)
                     CloseHandle(handle)
                     killed_pids.push(pid)
                     @child_pids.delete(pid)
                  else
                     CloseHandle(handle)
                     raise ProcessError, get_last_error
                  end
               else
                  raise ProcessError, get_last_error
               end
               @child_pids.delete(pid)
         end
      }
      
      killed_pids
   end
   
   # Process.create(key => value, ...) => ProcessInfo
   # 
   # This is a wrapper for the CreateProcess() function.  It executes a process,
   # returning a ProcessInfo struct.  It accepts a hash as an argument.
   # There are six primary keys:
	#
   # * app_name         (mandatory)
   # * inherit          (default: false)
   # * process_inherit  (default: false)
   # * thread_inherit   (default: false)
   # * creation_flags   (default: 0)
   # * cwd              (default: Dir.pwd)
   # * startup_info     (default: nil)
   # * environment      (default: nil)
	#
   # Of these, the 'app_name' must be specified or an error is raised.
	#
   # The startup_info key takes a hash.  Its keys are attributes that are
   # part of the StartupInfo struct, and are generally only meaningful for
   # GUI or console processes.  See the documentation on CreateProcess()
   # and the StartupInfo struct on MSDN for more information.
	# 	
   # * desktop
   # * title
   # * x
   # * y
   # * x_size
   # * y_size
   # * x_count_chars
   # * y_count_chars
   # * fill_attribute
   # * sw_flags
   # * startf_flags
   # 
   # The relevant constants for 'creation_flags', 'sw_flags' and 'startf_flags'
   # are included in the Windows::Process, Windows::Console and Windows::Window
   # modules.  These come with the windows-pr package, a prerequisite of this
   # package.
   # 
   # The ProcessInfo struct contains the following members:
   # 
   # * process_handle - The handle to the newly created process
   # * thread_handle  - The handle to the primary thread of the newly created
   #                    process.
   # * process_id     - Process ID.
   # * thread_id      - Thread ID.
   #
   def create(args)
      raise TypeError unless args.kind_of?(Hash)
      
      valid_keys = %w/
         app_name inherit creation_flags cwd environment startup_info
         thread_inherit process_inherit
      /

      valid_si_keys = %/
         startf_flags desktop title x y x_size y_size x_count_chars
         y_count_chars fill_attribute sw_flags stdin stdout stderr
      /

      # Set some default values
      hash = {
         'inherit'          => 0,
         'process_inherit'  => 0,
         'thread_inherit'   => 0,
         'creation_flags'   => 0,
         'cwd'              => 0
      }
      env = 0
      
      # Validate the keys, and convert symbols and case to lowercase strings.     
      args.each{ |key, val|
         key = key.to_s.downcase
         unless valid_keys.include?(key)
            raise ProcessError, "invalid key '#{key}'"
         end
         
         # Convert true to 1 and nil/false to 0.
         case val
            when true, false
               hash[key] = val == false ? 0 : 1
            when nil
               hash[key] = 0 # Win32API no likey nil
            else
               hash[key] = val
         end
      }
      
      si_hash = {}
      
      # If the startup_info key is present, validate its subkeys
      if hash['startup_info']
         hash['startup_info'].each{ |key, val|
            key = key.to_s.downcase
            unless valid_si_keys.include?(key)
               raise ProcessError, "invalid startup_info key '#{key}'"
            end
            si_hash[key] = val
         }
      end
      
      # The +app_name+ key is mandatory
      unless hash['app_name']
         raise ProcessError, 'app_name must be specified'
      end
      
      # The environment string should be passed as a string of ';' separated
      # paths.
      if hash['environment'] 
         env = hash['environment'].split(File::PATH_SEPARATOR) << 0.chr
         env = [env.join("\0")].pack('p*').unpack('L').first
      end
 
      startinfo = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
      startinfo = startinfo.pack('LLLLLLLLLLLLSSLLLL')
      procinfo  = [0,0,0,0].pack('LLLL')

      # Process SECURITY_ATTRIBUTE structure
      process_security = 0
      if hash['process_inherit?']
         process_security = [0,0,0].pack('LLL')
         process_security[0,4] = [12].pack('L') # sizeof(SECURITY_ATTRIBUTE)
         process_security[8,4] = [hash['process_inherit?']].pack('L')
      end

      # Thread SECURITY_ATTRIBUTE structure
      thread_security = 0
      if hash['thread_security?']
         thread_security = [0,0,0].pack('LLL')
         thread_security[0,4] = [12].pack('L') # sizeof(SECURITY_ATTRIBUTE)
         thread_security[8,4] = [hash['thread_inherit?']].pack('L')
      end
      
      # The bytes not covered here are reserved (null)
      unless si_hash.empty?
         startinfo[0,4]  = [startinfo.size].pack('L')
         startinfo[8,4]  = [si_hash['desktop']].pack('p*') if si_hash['desktop']
         startinfo[12,4] = [si_hash['title']].pack('p*') if si_hash['title']
         startinfo[16,4] = [si_hash['x']].pack('L') if si_hash['x']
         startinfo[20,4] = [si_hash['y']].pack('L') if si_hash['y']
         startinfo[24,4] = [si_hash['x_size']].pack('L') if si_hash['x_size']
         startinfo[28,4] = [si_hash['y_size']].pack('L') if si_hash['y_size']
         startinfo[32,4] = [si_hash['x_count_chars']].pack('L') if si_hash['x_count_chars']
         startinfo[36,4] = [si_hash['y_count_chars']].pack('L') if si_hash['y_count_chars']
         startinfo[40,4] = [si_hash['fill_attribute']].pack('L') if si_hash['fill_attribute']
         startinfo[44,4] = [si_hash['startf_flags']].pack('L') if si_hash['startf_flags']
         startinfo[48,2] = [si_hash['sw_flags']].pack('S') if si_hash['sw_flags']
         startinfo[56,4] = [si_hash['stdin']].pack('L') if si_hash['stdin']
         startinfo[60,4] = [si_hash['stdout']].pack('L') if si_hash['stdout']
         startinfo[64,4] = [si_hash['stderr']].pack('L') if si_hash['stderr']        
      end

      rv = CreateProcess(
         0,                      # App name
         hash['app_name'],       # Command line
         process_security,       # Process attributes
         thread_security,        # Thread attributes
         hash['inherit'],        # Inherit handles?
         hash['creation_flags'], # Creation flags
         env,                    # Environment
         hash['cwd'],            # Working directory
         startinfo,              # Startup Info
         procinfo                # Process Info
      )
      
      if rv == 0
         raise ProcessError, "CreateProcess() failed: %", get_last_error
      end
      
      ProcessInfo.new(
         procinfo[0,4].unpack('L').first, # hProcess
         procinfo[4,4].unpack('L').first, # hThread
         procinfo[8,4].unpack('L').first, # hProcessId
         procinfo[12,4].unpack('L').first # hThreadId
      )
   end
   
   # Waits for any child process to exit and returns the process id of that
   # child.
   # 
   # Note that the $? (Process::Status) global variable is NOT set.  This
   # may be addressed in a future release.
   #--
   # The GetProcessId() function is not defined in Windows 2000 or earlier
   # so we have to do some extra work for those platforms.
   #   
   def wait
      handles = []
      
      # Windows 2000 or earlier
      unless defined? GetProcessId
         pids = []
      end
      
      @child_pids.each_with_index{ |pid, i|
         handles[i] = OpenProcess(PROCESS_ALL_ACCESS, 0, pid)
         
         if handles[i] == INVALID_HANDLE_VALUE
            err = "unable to get HANDLE on process associated with pid #{pid}"
            raise ProcessError, err
         end
         
         unless defined? GetProcessId
            pids[i] = pid
         end      
      }
    
      wait = WaitForMultipleObjects(
         handles.size,
         handles.pack('L*'),
         0,
         INFINITE
      )
      
      if wait >= WAIT_OBJECT_0 && wait <= WAIT_OBJECT_0 + @child_pids.size - 1
         index = wait - WAIT_OBJECT_0         
         handle = handles[index]
         
         if defined? GetProcessId
            pid = GetProcessId(handle)
         else
            pid = pids[index]
         end
         
         @child_pids.delete(pid)
         handles.each{ |handle| CloseHandle(handle) }
         return pid
      end
      
      nil
   end
   
   # Waits for any child process to exit and returns an array containing the
   # process id and the exit status of that child.
   # 
   # Note that the $? (Process::Status) global variable is NOT set.  This
   # may be addressed in a future release.
   #--
   # The GetProcessId() function is not defined in Windows 2000 or earlier
   # so we have to do some extra work for those platforms.
   # 
   def wait2
      handles = []
      
      # Windows 2000 or earlier
      unless defined? GetProcessId
         pids = []
      end
      
      @child_pids.each_with_index{ |pid, i|
         handles[i] = OpenProcess(PROCESS_ALL_ACCESS, 0, pid)
         
         if handles[i] == INVALID_HANDLE_VALUE
            err = "unable to get HANDLE on process associated with pid #{pid}"
            raise ProcessError, err
         end
         
         unless defined? GetProcessId
            pids[i] = pid
         end      
      }
    
      wait = WaitForMultipleObjects(
         handles.size,
         handles.pack('L*'),
         0,
         INFINITE
      )
      
      if wait >= WAIT_OBJECT_0 && wait <= WAIT_OBJECT_0 + @child_pids.size - 1
         index = wait - WAIT_OBJECT_0         
         handle = handles[index]
         
         if defined? GetProcessId
            pid = GetProcessId(handle)
         else
            pid = pids[index]
         end
         
         exit_code = [0].pack('l')
         unless GetExitCodeProcess(handle, exit_code)
            raise get_last_error
         end
         
         @child_pids.delete(pid)
         
         handles.each{ |handle| CloseHandle(handle) }
         return [pid, exit_code.unpack('l').first]
      end
      
      nil
   end

   # Creates the equivalent of a subshell via the CreateProcess() function.
   # This behaves in a manner that is similar, but not identical to, the
   # Kernel.fork method for Unix.
   # 
   def fork
      last_arg = ARGV.last
      
      # Look for the 'child#xxx' tag
      if last_arg =~ /child#\d+/
         @i += 1
         num = last_arg.split('#').last.to_i
         if num == @i
            if block_given?
               status = 0
               begin
                  yield
               rescue Exception
                  status = -1 # Any non-zero result is failure
               ensure
                  return status
               end
            end
            return nil
         else
            return false
         end
      end
   
      # Tag the command with the word 'child#xxx' to distinguish it
      # from the calling process.
      cmd = 'ruby -I "' + $LOAD_PATH.join(File::PATH_SEPARATOR) << '" "'
      cmd << File.expand_path($PROGRAM_NAME) << '" ' << ARGV.join(' ')
      cmd << ' child#' << @child_pids.length.to_s
      
      startinfo = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
      startinfo = startinfo.pack('LLLLLLLLLLLLSSLLLL')
      procinfo  = [0,0,0,0].pack('LLLL')
      
      rv = CreateProcess(0, cmd, 0, 0, 1, 0, 0, 0, startinfo, procinfo)
      
      if rv == 0
         raise ProcessError, get_last_error
      end
      
      pid = procinfo[8,4].unpack('L').first
      @child_pids.push(pid)
      
      pid 
   end
   
   module_function :kill, :wait, :wait2, :waitpid, :waitpid2, :create, :fork
end

# Create a global fork method
module Kernel
   def fork(&block)
      Process.fork(&block)
   end
end
