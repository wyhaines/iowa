require 'Win32API'

module Windows
   module Pipe
      NMPWAIT_NOWAIT           = 0x00000001
      NMPWAIT_WAIT_FOREVER     = 0xffffffff
      NMPWAIT_USE_DEFAULT_WAIT = 0x00000000

      PIPE_WAIT             = 0x00000000
      PIPE_NOWAIT           = 0x00000001
      PIPE_ACCESS_INBOUND   = 0x00000001
      PIPE_ACCESS_OUTBOUND  = 0x00000002
      PIPE_ACCESS_DUPLEX    = 0x00000003
      PIPE_TYPE_BYTE        = 0x00000000
      PIPE_TYPE_MESSAGE     = 0x00000004
      PIPE_READMODE_BYTE    = 0x00000000
      PIPE_READMODE_MESSAGE = 0x00000002
      PIPE_CLIENT_END       = 0x00000000
      PIPE_SERVER_END       = 0x00000001

      CallNamedPipe           = Win32API.new('kernel32', 'CallNamedPipe', 'PPLPLPL', 'I')
      ConnectNamedPipe        = Win32API.new('kernel32', 'ConnectNamedPipe', 'LP', 'I')
      CreateNamedPipe         = Win32API.new('kernel32', 'CreateNamedPipe', 'PLLLLLLL', 'L')
      CreatePipe              = Win32API.new('kernel32', 'CreatePipe', 'PPPL', 'I')
      DisconnectNamedPipe     = Win32API.new('kernel32', 'DisconnectNamedPipe', 'L', 'I')
      GetNamedPipeHandleState = Win32API.new('kernel32', 'GetNamedPipeHandleState', 'LPPPPPL', 'I')
      GetNamedPipeInfo        = Win32API.new('kernel32', 'GetNamedPipeInfo', 'LPPPP', 'I')
      PeekNamedPipe           = Win32API.new('kernel32', 'PeekNamedPipe', 'LPLPPP', 'I')
      SetNamedPipeHandleState = Win32API.new('kernel32', 'SetNamedPipeHandleState', 'LPPP', 'I')
      TransactNamedPipe       = Win32API.new('kernel32', 'TransactNamedPipe', 'LPLPLPP', 'I')
      WaitNamedPipe           = Win32API.new('kernel32', 'WaitNamedPipe', 'PL', 'I')

      def CallNamedPipe(name, buf, buf_size, out, out_size, read, timeout)
         CallNamedPipe.call(name, buf, buf_size, out, out_size, read, timeout) != 0
      end

      def ConnectNamedPipe(pipe, overlapped = 0)
         ConnectNamedPipe.call(pipe, overlapped) != 0
      end

      def CreateNamedPipe(name, open_mode, pipe_mode, max, out_size, in_size, timeout, sec_attr)
         CreateNamedPipe.call(name, open_mode, pipe_mode, max, out_size, in_size, timeout, sec_attr)
      end

      def CreatePipe(read_pipe, write_pipe, pipe_attr, size)
         CreatePipe.call(read_pipe, write_pipe, pipe_attr, size) != 0
      end

      def DisconnectNamedPipe(name)
         DisconnectNamedPipe.call(name) != 0
      end

      def GetNamedPipeHandleState(name, state, instances, count, timeout, user, size)
         GetNamedPipeHandleState.call(name, state, instances, count, timeout, user, size) != 0
      end

      def GetNamedPipeInfo(name, flags, out_size, in_size, max)
         GetNamedPipeInfo.call(name, flags, out_size, in_size, max) != 0
      end

      def PeekNamedPipe(name, buf, buf_size, bytes_read, bytes_avail, bytes_left)
         PeekNamedPipe.call(name, buf, buf_size, bytes_read, bytes_avail, bytes_left) != 0
      end

      def SetNamedPipeHandleState(name, mode, max, timeout)
         SetNamedPipeHandleState.call(name, mode, max, timeout) != 0
      end

      def TransactNamedPipe(name, in_buf, in_buf_size, out_buf, out_buf_size, read, overlapped)
         TransactNamedPipe.call(name, in_buf, in_buf_size, out_buf, out_buf_size, read, overlapped) != 0
      end

      def WaitNamedPipe(name, timeout)
         WaitNamedPipe.call(name, timeout) != 0
      end
   end
end
