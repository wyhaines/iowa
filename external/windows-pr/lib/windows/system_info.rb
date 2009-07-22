require 'Win32API'

module Windows
   module SystemInfo
      # Obsolete processor info constants
      PROCESSOR_INTEL_386     = 386
      PROCESSOR_INTEL_486     = 486
      PROCESSOR_INTEL_PENTIUM = 586
      PROCESSOR_INTEL_IA64    = 2200
      PROCESSOR_AMD_X8664     = 8664

      # Enum COMPUTER_NAME_FORMAT
      ComputerNameNetBIOS                    = 0
      ComputerNameDnsHostname                = 1
      ComputerNameDnsDomain                  = 2
      ComputerNameDnsFullyQualified          = 3
      ComputerNamePhysicalNetBIOS            = 4
      ComputerNamePhysicalDnsHostname        = 5
      ComputerNamePhysicalDnsDomain          = 6 
      ComputerNamePhysicalDnsFullyQualified  = 7
      ComputerNameMax                        = 8
      
      ExpandEnvironmentStrings = Win32API.new('kernel32', 'ExpandEnvironmentStrings', 'PPL', 'L')
      
      GetComputerName     = Win32API.new('kernel32', 'GetComputerName', 'PP', 'I')
      GetComputerNameEx   = Win32API.new('kernel32', 'GetComputerNameEx', 'PPP', 'I')
      GetSystemInfo       = Win32API.new('kernel32', 'GetSystemInfo', 'P', 'V')
      GetUserName         = Win32API.new('advapi32', 'GetUserName', 'LL', 'I')
      GetUserNameEx       = Win32API.new('secur32', 'GetUserNameEx', 'LPL', 'I')
      GetVersion          = Win32API.new('kernel32', 'GetVersion', 'V', 'L')
      GetVersionEx        = Win32API.new('kernel32', 'GetVersionEx', 'P', 'I')
      GetWindowsDirectory = Win32API.new('kernel32', 'GetWindowsDirectory', 'LI', 'I')
      
      def ExpandEnvironmentStrings(src, dest, size)
         ExpandEnvironmentStrings.call(src, dest, size)
      end

      def GetComputerName(buffer, size)
         GetComputerNameEx.call(buffer, size) != 0
      end

      def GetComputerNameEx(name, buffer, size)
         GetComputerNameEx.call(name, buffer, size) != 0
      end

      def GetSystemInfo(info)
         GetSystemInfo.call(info)
      end

      def GetUserName(buf, size)
         GetUserName.call(buf, size) != 0
      end

      def GetUserNameEx(format, buf, size)
         GetUserNameEx.call(format, buf, size) != 0
      end

      def GetVersion()
         GetVersion.call
      end

      def GetVersionEx(info)
         GetVersionEx.call(info) != 0
      end

      def GetWindowsDirectory(buf, size)
         GetWindowsDirectory.call(buf, size)
      end
   end
end
