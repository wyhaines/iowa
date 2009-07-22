require 'Win32API'

module Windows
   module Process
      PROCESS_ALL_ACCESS                = 0x1F0FFF
      PROCESS_CREATE_PROCESS            = 0x0080
      PROCESS_CREATE_THREAD             = 0x0002
      PROCESS_DUP_HANDLE                = 0x0040
      PROCESS_QUERY_INFORMATION         = 0x0400
      PROCESS_QUERY_LIMITED_INFORMATION = 0x1000
      PROCESS_SET_QUOTA                 = 0x0100
      PROCESS_SET_INFORMATION           = 0x0200
      PROCESS_SUSPEND_RESUME            = 0x0800
      PROCESS_TERMINATE                 = 0x0001
      PROCESS_VM_OPERATION              = 0x0008
      PROCESS_VM_READ                   = 0x0010
      PROCESS_VM_WRITE                  = 0x0020
      SYNCHRONIZE                       = 1048576
      STILL_ACTIVE                      = 259
      
      ABOVE_NORMAL_PRIORITY_CLASS = 0x00008000
      BELOW_NORMAL_PRIORITY_CLASS = 0x00004000
      HIGH_PRIORITY_CLASS         = 0x00000080
      IDLE_PRIORITY_CLASS         = 0x00000040
      NORMAL_PRIORITY_CLASS       = 0x00000020
      REALTIME_PRIORITY_CLASS     = 0x00000100
      
      # Process creation flags
      CREATE_BREAKAWAY_FROM_JOB        = 0x01000000
      CREATE_DEFAULT_ERROR_MODE        = 0x04000000
      CREATE_NEW_CONSOLE               = 0x00000010
      CREATE_NEW_PROCESS_GROUP         = 0x00000200
      CREATE_NO_WINDOW                 = 0x08000000
      CREATE_PRESERVE_CODE_AUTHZ_LEVEL = 0x02000000
      CREATE_SEPARATE_WOW_VDM          = 0x00000800
      CREATE_SHARED_WOW_VDM            = 0x00001000
      CREATE_SUSPENDED                 = 0x00000004
      CREATE_UNICODE_ENVIRONMENT       = 0x00000400
      DEBUG_ONLY_THIS_PROCESS          = 0x00000002
      DEBUG_PROCESS                    = 0x00000001
      DETACHED_PROCESS                 = 0x00000008
      
      STARTF_USESHOWWINDOW    = 0x00000001
      STARTF_USESIZE          = 0x00000002
      STARTF_USEPOSITION      = 0x00000004
      STARTF_USECOUNTCHARS    = 0x00000008
      STARTF_USEFILLATTRIBUTE = 0x00000010
      STARTF_RUNFULLSCREEN    = 0x00000020
      STARTF_FORCEONFEEDBACK  = 0x00000040
      STARTF_FORCEOFFFEEDBACK = 0x00000080
      STARTF_USESTDHANDLES    = 0x00000100
      STARTF_USEHOTKEY        = 0x00000200
      
      CreateProcess          = Win32API.new('kernel32', 'CreateProcess', 'LPLLLLLPPP', 'I')
      CreateRemoteThread     = Win32API.new('kernel32', 'CreateRemoteThread', 'LPLLPLP', 'L')
      CreateThread           = Win32API.new('kernel32', 'CreateThread', 'PLPPLP', 'L')
      ExitProcess            = Win32API.new('kernel32', 'ExitProcess', 'L', 'V')
      GetCommandLine         = Win32API.new('kernel32', 'GetCommandLine', 'V', 'P')
      GetCurrentProcess      = Win32API.new('kernel32', 'GetCurrentProcess', 'V', 'L')      
      GetCurrentProcessId    = Win32API.new('kernel32', 'GetCurrentProcessId', 'V', 'L')
      GetEnvironmentStrings  = Win32API.new('kernel32', 'GetEnvironmentStrings', 'V', 'L')
      GetEnvironmentVariable = Win32API.new('kernel32', 'GetEnvironmentVariable', 'PPL', 'L')
      GetExitCodeProcess     = Win32API.new('kernel32', 'GetExitCodeProcess', 'LP', 'I')
      GetPriorityClass       = Win32API.new('kernel32', 'GetPriorityClass', 'L', 'L')
      GetProcessTimes        = Win32API.new('kernel32', 'GetProcessTimes', 'LPPPP', 'I')
      GetStartupInfo         = Win32API.new('kernel32', 'GetStartupInfo', 'P', 'V')
      OpenProcess            = Win32API.new('kernel32', 'OpenProcess', 'LIL', 'L')
      SetEnvironmentVariable = Win32API.new('kernel32', 'SetEnvironmentVariable', 'PP', 'I')
      Sleep                  = Win32API.new('kernel32', 'Sleep', 'L', 'V')
      SleepEx                = Win32API.new('kernel32', 'SleepEx', 'LI', 'L')
      TerminateProcess       = Win32API.new('kernel32', 'TerminateProcess', 'LL', 'I')
      WaitForInputIdle       = Win32API.new('user32', 'WaitForInputIdle', 'LL', 'L')
      
      # Windows XP or later
      begin
         GetProcessId           = Win32API.new('kernel32', 'GetProcessId', 'L', 'L')
         GetProcessHandleCount  = Win32API.new('kernel32', 'GetProcessHandleCount', 'LP', 'I')
      rescue Exception
         # Do nothing - not supported on current platform.  It's up to you to
         # check for the existence of the constant in your code.
      end
           
      def CreateProcess(app, cmd, pattr, tattr, handles, flags, env, dir, sinfo, pinfo)
         CreateProcess.call(app, cmd, pattr, tattr, handles, flags, env, dir, sinfo, pinfo) != 0
      end
      
      def CreateRemoteThread(handle, tattr, size, start, param, flags, tid)
         CreateRemoteThread.call(handle, tattr, size, start, param, flags, tid)
      end
      
      def CreateThread(attr, size, addr, param, flags, id)
         CreateThread.call(attr, size, addr, param, flags, id)
      end
      
      def ExitProcess(exit_code)
         ExitProcess.call(exit_code)
      end
      
      def GetCommandLine
         GetCommandLine.call
      end
      
      def GetCurrentProcess()
         GetCurrentProcess.call
      end
      
      def GetCurrentProcessId()
         GetCurrentProcessId.call
      end
      
      def GetEnvironmentStrings()
         GetEnvironmentStrings.call
      end
      
      def GetEnvironmentVariable(name, buffer, size)
         GetEnvironmentVariable.call(name, buffer, size)
      end
      
      def GetExitCodeProcess(handle, exit_code)
         GetExitCodeProcess.call(handle, exit_code) != 0
      end
      
      def GetPriorityClass(handle)
         GetPriorityClass.call(handle)
      end
      
      def GetProcessTimes(handle, t_creation, t_exit, t_kernel, t_user)
         GetProcessTimes.call(handle, t_creation, t_exit, t_kernel, t_user) != 0
      end
      
      def GetStartupInfo(info_struct)
         GetStartupInfo.call(info_struct)
      end
      
      def OpenProcess(access, handle, pid)
         OpenProcess.call(access, handle, pid)
      end
      
      def SetEnvironmentVariable(name, value)
         SetEnvironmentVariable.call(name, value)
      end
      
      def Sleep(milliseconds)
         Sleep.call(milliseconds)
      end
      
      def SleepEx(milliseconds, alertable)
         SleepEx.call(milliseconds, alertable)
      end
      
      def TerminateProcess(handle, exit_code)
         TerminateProcess.call(handle, exit_code) != 0
      end
      
      def WaitForInputIdle(handle, milliseconds)
         WaitForInputIdle.call(handle, milliseconds)
      end

      begin
         def GetProcessId(handle)
            GetProcessId.call(handle)
         end

         def GetProcessHandleCount(handle, count)
            GetProcessHandleCount.call(handle, count) != 0
         end
      rescue Exception
         # Windows XP or later      
      end
   end
end
