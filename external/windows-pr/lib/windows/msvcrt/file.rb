require 'Win32API'

module Windows
   module MSVCRT
      module File
         Stat   = Win32API.new('msvcrt', '_stat', 'PP', 'I')
         Stat64 = Win32API.new('msvcrt', '_stat64', 'PP', 'I')
         
         def stat(path, buffer)
            Stat.call(path, buffer)
         end
      
         def stat64(path, buffer)
            Stat64.call(path, buffer)
         end
      end
   end
end