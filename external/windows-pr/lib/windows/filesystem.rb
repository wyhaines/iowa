require 'Win32API'

module Windows
   module FileSystem
      GetDiskFreeSpace   = Win32API.new('kernel32', 'GetDiskFreeSpace', 'PPPPP', 'I')
      GetDiskFreeSpaceEx = Win32API.new('kernel32', 'GetDiskFreeSpaceEx', 'PPPP', 'I')

      def GetDiskFreeSpace(path, sectors, bytes, free, total)
         GetDiskFreeSpace.call(path, sectors, bytes, free, total) > 0
      end

      def GetDiskFreeSpaceEx(path, free_bytes, total_bytes, total_free)
         GetDiskFreeSpaceEx.call(path, free_bytes, total_bytes, total_free) > 0
      end
   end
end
