require 'Win32API'

module Windows
   module Memory
      GHND           = 0x0042
      GMEM_FIXED     = 0x0000
      GMEM_MOVABLE   = 0002
      GMEM_ZEROINIT  = 0x0040
      GPTR           = 0x0040

      GlobalAlloc          = Win32API.new('kernel32', 'GlobalAlloc', 'II', 'I')
      GlobalFlags          = Win32API.new('kernel32', 'GlobalFlags', 'I', 'I')
      GlobalFree           = Win32API.new('kernel32', 'GlobalFree', 'I', 'I')
      GlobalHandle         = Win32API.new('kernel32', 'GlobalHandle', 'P', 'I')
      GlobalLock           = Win32API.new('kernel32', 'GlobalLock', 'L', 'L')
      GlobalMemoryStatus   = Win32API.new('kernel32', 'GlobalMemoryStatus', 'P', 'V')
      GlobalMemoryStatusEx = Win32API.new('kernel32', 'GlobalMemoryStatusEx', 'P', 'V')
      GlobalReAlloc        = Win32API.new('kernel32', 'GlobalReAlloc', 'III', 'I')
      GlobalSize           = Win32API.new('kernel32', 'GlobalSize', 'I', 'I')
      GlobalUnlock         = Win32API.new('kernel32', 'GlobalUnlock', 'I', 'I')
      VirtualAlloc         = Win32API.new('kernel32', 'VirtualAlloc', 'PLLL', 'P')
      VirtualAllocEx       = Win32API.new('kernel32', 'VirtualAllocEx', 'LPLLL', 'P')
      VirtualFree          = Win32API.new('kernel32', 'VirtualFree', 'PLL', 'I')
      VirtualFreeEx        = Win32API.new('kernel32', 'VirtualFreeEx', 'LPLL', 'I')
      VirtualLock          = Win32API.new('kernel32', 'VirtualLock', 'PL', 'I')
      VirtualProtect       = Win32API.new('kernel32', 'VirtualProtect', 'PLLP', 'I')
      VirtualProtectEx     = Win32API.new('kernel32', 'VirtualProtectEx', 'LPLLP', 'I')
      VirtualQuery         = Win32API.new('kernel32', 'VirtualQuery', 'PPL', 'L')
      VirtualQueryEx       = Win32API.new('kernel32', 'VirtualQueryEx', 'LPPL', 'L')
      VirtualUnlock        = Win32API.new('kernel32', 'VirtualUnlock', 'PL', 'I')
      ZeroMemory           = Win32API.new('kernel32', 'RtlZeroMemory', 'PL', 'I')

      def GlobalAlloc(flags, bytes)
         GlobalAlloc.call(flags, bytes)
      end

      def GlobalFlags(handle)
         GlobalFlags.call(handle)
      end

      def GlobalFree(handle)
         GlobalFree.call(handle)
      end

      def GlobalHandle(handle)
         GlobalHandle.call(handle)
      end

      def GlobalLock(handle)
         GlobalLock.call(handle)
      end

      def GlobalMemoryStatus(buf)
         GlobalMemoryStatus.call(buf)
      end

      def GlobalMemoryStatusEx(buf)
         GlobalMemoryStatusEx.call(buf)
      end

      def GlobalReAlloc(handle, bytes, flags)
         GlobalReAlloc.call(handle, bytes, flags)
      end

      def GlobalSize(handle)
         GlobalSize.call(handle)
      end

      def GlobalUnlock(handle)
         GlobalUnlock.call(handle)
      end

      def VirtualAlloc(address, size, alloc_type, protect)
         VirtualAlloc.call(address, size, alloc_type, protect)
      end

      def VirtualAllocEx(handle, address, size, alloc_type, protect)
         VirtualAllocEx.call(handle, address, size, alloc_type, protect)
      end

      def VirtualFree(address, size, free_type)
         VirtualFree.call(address, size, free_type) != 0
      end

      def VirtualFreeEx(handle, address, size, free_type)
         VirtualFreeEx.call(handle, address, size, free_type) != 0
      end

      def VirtualLock(address, size)
         VirtualLock.call(address, size) != 0
      end

      def VirtualProtect(address, size, new_protect, old_protect)
         VirtualProtect.call(address, size, new_protect, old_protect) != 0
      end

      def VirtualProtectEx(handle, address, size, new_protect, old_protect)
         VirtualProtect.call(handle, address, size, new_protect, old_protect) != 0
      end

      def VirtualQuery(address, buffer, length)
         VirtualQuery.call(address, buffer, length)
      end
      
      def VirtualQueryEx(handle, address, buffer, length)
         VirtualQueryEx.call(handle, address, buffer, length)
      end

      def VirtualUnlock(address, size)
         VirtualUnlock.call(address, size) != 0
      end

      def ZeroMemory(dest, length)
         ZeroMemory.call(dest, length)
      end
   end
end
