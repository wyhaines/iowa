require 'Win32API'

module Windows
   module MSVCRT
      module String
         Strcpy = Win32API.new('msvcrt', 'strcpy', 'PL', 'l')
         Strrev = Win32API.new('msvcrt', '_strrev', 'P', 'P')
         
         Mbscpy = Win32API.new('msvcrt', '_mbscpy', 'PL', 'L')
         Mbsrev = Win32API.new('msvcrt', '_mbsrev', 'P', 'P')
         
         Wcscpy = Win32API.new('msvcrt', 'wcscpy', 'PL', 'l')
         Wcsrev = Win32API.new('msvcrt', '_wcsrev', 'P', 'P')       

         def strcpy(dest, src)
            return nil if src == 0
            Strcpy.call(dest, src)
         end
         
         def strrev(str)
            return nil if str == 0
            Strrev.call(str)
         end
         
         def mbscpy(dest, src)
            return nil if src == 0
            Mbscpy.call(dest, src)
         end
         
         def mbsrev(str)
            return nil if str == 0
            Mbsrev.call(str)
         end

         def wcscpy(dest, src)
            return nil if src == 0
            Wcscpy.call(dest, src)
         end
         
         def wcsrev(str)
            return nil if str == 0
            Wcsrev.call(str)
         end  
      end
   end
end