require 'Win32API'

module Windows
   module Library
      DLL_PROCESS_DETACH = 0
      DLL_PROCESS_ATTACH = 1
      DLL_THREAD_ATTACH  = 2
      DLL_THREAD_DETACH  = 3
          
      GET_MODULE_HANDLE_EX_FLAG_PIN                = 1
      GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT = 2
      GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS       = 4
      
      DONT_RESOLVE_DLL_REFERENCES   = 0x00000001
      LOAD_LIBRARY_AS_DATAFILE      = 0x00000002
      LOAD_WITH_ALTERED_SEARCH_PATH = 0x00000008
      LOAD_IGNORE_CODE_AUTHZ_LEVEL  = 0x00000010
            
      DisableThreadLibraryCalls = Win32API.new('kernel32', 'DisableThreadLibraryCalls', 'L', 'I')
      FreeLibrary               = Win32API.new('kernel32', 'FreeLibrary', 'L', 'I')
      FreeLibraryAndExitThread  = Win32API.new('kernel32', 'FreeLibraryAndExitThread', 'LL', 'V')
      GetDllDirectory           = Win32API.new('kernel32', 'GetDllDirectory', 'LP', 'L')
      GetModuleFileName         = Win32API.new('kernel32', 'GetModuleFileName', 'LPL', 'L')
      GetModuleHandle           = Win32API.new('kernel32', 'GetModuleHandle', 'P', 'L')
      GetModuleHandleEx         = Win32API.new('kernel32', 'GetModuleHandleEx', 'LPP', 'I')
      GetProcAddress            = Win32API.new('kernel32', 'GetProcAddress', 'LP', 'L')
      LoadLibrary               = Win32API.new('kernel32', 'LoadLibrary', 'P', 'L')
      LoadLibraryEx             = Win32API.new('kernel32', 'LoadLibraryEx', 'PLL', 'L')
      LoadModule                = Win32API.new('kernel32', 'LoadModule', 'PP', 'L')
      SetDllDirectory           = Win32API.new('kernel32', 'SetDllDirectory', 'P', 'I')
      
      def DisableThreadLibraryCalls(hmodule)
         DisableThreadLibraryCalls.call(hmodule) != 0
      end
      
      def FreeLibrary(hmodule)
         FreeLibrary.call(hmodule) != 0
      end
      
      def GetDllDirectory(length, buffer)
         GetDllDirectory.call(length, buffer)
      end
      
      def GetModuleFileName(hmodule, file, size)
         GetModuleFileName.call(hmodule, file, size)
      end
      
      def GetModuleHandle(module_name)
         GetModuleHandle.call(module_name)
      end
      
      def GetModuleHandleEx(flags, module_name, hmodule)
         GetModuleHandleEx.call(flags, module_name, hmodule)
      end
      
      def GetProcAddress(hmodule, proc_name)
         GetProcAddress.call(hmodule, proc_name)
      end
      
      def LoadLibrary(library)
         LoadLibrary.call(library)
      end
      
      def LoadLibraryEx(library, file, flags)
         LoadLibraryEx.call(library, file, flags)
      end
      
      def LoadModule(hmodule, param_block)
         LoadModule.call(hmodule, param_block)
      end
      
      def SetDllDirectory(path)
         SetDllDirectory.call(path)
      end
   end
end