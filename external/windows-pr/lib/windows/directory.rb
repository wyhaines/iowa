require 'windows/unicode'

module Windows
   module Directory
      CreateDirectory             = Win32API.new('kernel32', 'CreateDirectory', 'PP', 'I')
      CreateDirectoryW            = Win32API.new('kernel32', 'CreateDirectoryW', 'PP', 'I')
      CreateDirectoryEx           = Win32API.new('kernel32', 'CreateDirectoryEx', 'PPP', 'I')
      CreateDirectoryExW          = Win32API.new('kernel32', 'CreateDirectoryExW', 'PPP', 'I')
      FindCloseChangeNotification = Win32API.new('kernel32', 'FindCloseChangeNotification', 'L', 'I')
      FindFirstChangeNotification = Win32API.new('kernel32', 'FindFirstChangeNotification', 'PIL', 'L')
      FindNextChangeNotification  = Win32API.new('kernel32', 'FindFirstChangeNotification', 'PIL', 'I')
      GetCurrentDirectory         = Win32API.new('kernel32', 'GetCurrentDirectory', 'LP', 'L')
      GetCurrentDirectoryW        = Win32API.new('kernel32', 'GetCurrentDirectoryW', 'LP', 'L')
      ReadDirectoryChangesW       = Win32API.new('kernel32', 'ReadDirectoryChangesW', 'LPLILPPP', 'I')
      RemoveDirectory             = Win32API.new('kernel32', 'RemoveDirectory', 'P', 'I')
      RemoveDirectoryW            = Win32API.new('kernel32', 'RemoveDirectoryW', 'P', 'I')
      SetCurrentDirectory         = Win32API.new('kernel32', 'SetCurrentDirectory', 'P', 'I')
      SetCurrentDirectoryW        = Win32API.new('kernel32', 'SetCurrentDirectoryW', 'P', 'I')

      def CreateDirectory(path, attributes = 0)
         CreateDirectory.call(path, attributes) != 0
      end
      
      def CreateDirectoryW(path, attributes)
         path = multi_to_wide(path) unless IsTextUnicode(path)
         CreateDirectoryW.call(path, attributes) != 0
      end

      def CreateDirectoryEx(template, new_dir, attributes)
         CreateDirectoryEx.call(template, new_dir, attributes) != 0
      end
      
      def CreateDirectoryExW(template, new_dir, attributes)
         new_dir = multi_to_wide(new_dir) unless IsTextUnicode(new_dir)
         CreateDirectoryExW.call(template, new_dir, attributes) != 0
      end

      def FindCloseChangeNotification(handle)
         FindCloseChangeNotification.call(handle) != 0
      end

      def FindFirstChangeNotification(path, subtree, filter)
         FindFirstChangeNotification.call(path, subtree, filter)
      end

      def FindNextChangeNotification(handle)
         FindNextChangeNotification.call(handle) != 0
      end

      def GetCurrentDirectory(buf_len, buf)
         GetCurrentDirectory.call(buf_len, buf)
      end
      
      def GetCurrentDirectoryW(buf_len, buf)
         GetCurrentDirectoryW.call(buf_len, buf)
      end

      def ReadDirectoryChangesW(handle, buf, buf_len, subtree, filter, bytes, overlapped, routine)
         ReadDirectoryChangesW.call(handle, buf, buf_len, subtree, filter, bytes, overlapped, routine) != 0
      end

      def RemoveDirectory(path)
         RemoveDirectory.call(path) != 0
      end
      
      def RemoveDirectoryW(path)
         path = multi_to_wide(path) unless IsTextUnicode(path)
         RemoveDirectoryW.call(path) != 0
      end

      def SetCurrentDirectory(path)
         SetCurrentDirectory.call(path) != 0
      end
      
      def SetCurrentDirectoryW(path)
         path = multi_to_wide(path) unless IsTextUnicode(path)
         SetCurrentDirectoryW.call(path) != 0
      end
   end
end
