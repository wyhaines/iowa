require 'Win32API'

module Windows
   module Console
      CTRL_C_EVENT        = 0
      CTRL_BREAK_EVENT    = 1
      CTRL_LOGOFF_EVENT   = 5
      CTRL_SHUTDOWN_EVENT = 6

      ENABLE_PROCESSED_INPUT    = 0x0001
      ENABLE_LINE_INPUT         = 0x0002
      ENABLE_WRAP_AT_EOL_OUTPUT = 0x0002
      ENABLE_ECHO_INPUT         = 0x0004
      ENABLE_WINDOW_INPUT       = 0x0008
      ENABLE_MOUSE_INPUT        = 0x0010
      ENABLE_INSERT_MODE        = 0x0020
      ENABLE_QUICK_EDIT_MODE    = 0x0040

      STD_INPUT_HANDLE  = -10
      STD_OUTPUT_HANDLE = -11
      STD_ERROR_HANDLE  = -12
      
      # Console window constants
      FOREGROUND_BLUE            = 0x0001
      FOREGROUND_GREEN           = 0x0002
      FOREGROUND_RED             = 0x0004
      FOREGROUND_INTENSITY       = 0x0008
      BACKGROUND_BLUE            = 0x0010
      BACKGROUND_GREEN           = 0x0020
      BACKGROUND_RED             = 0x0040
      BACKGROUND_INTENSITY       = 0x0080
      COMMON_LVB_LEADING_BYTE    = 0x0100
      COMMON_LVB_TRAILING_BYTE   = 0x0200
      COMMON_LVB_GRID_HORIZONTAL = 0x0400
      COMMON_LVB_GRID_LVERTICAL  = 0x0800
      COMMON_LVB_GRID_RVERTICAL  = 0x1000
      COMMON_LVB_REVERSE_VIDEO   = 0x4000
      COMMON_LVB_UNDERSCORE      = 0x8000
      COMMON_LVB_SBCSDBCS        = 0x0300

      CONSOLE_FULLSCREEN          = 1
      CONSOLE_OVERSTRIKE          = 1
      CONSOLE_FULLSCREEN_HARDWARE = 2
      
      AddConsoleAlias                = Win32API.new('kernel32', 'AddConsoleAlias', 'PPP', 'I')
      AllocConsole                   = Win32API.new('kernel32', 'AllocConsole', 'V', 'I')
      AttachConsole                  = Win32API.new('kernel32', 'AttachConsole', 'L', 'I')
      CreateConsoleScreenBuffer      = Win32API.new('kernel32', 'CreateConsoleScreenBuffer', 'LLPLP', 'L')
      FillConsoleOutputAttribute     = Win32API.new('kernel32', 'FillConsoleOutputAttribute', 'LILLP', 'I')
      FillConsoleOutputCharacter     = Win32API.new('kernel32', 'FillConsoleOutputCharacter', 'LILLP', 'I')
      FlushConsoleInputBuffer        = Win32API.new('kernel32', 'FlushConsoleInputBuffer', 'L', 'I')
      FreeConsole                    = Win32API.new('kernel32', 'FreeConsole', 'V', 'I')
      GenerateConsoleCtrlEvent       = Win32API.new('kernel32', 'GenerateConsoleCtrlEvent', 'LL', 'I')
      GetConsoleAlias                = Win32API.new('kernel32', 'GetConsoleAlias', 'PPLP', 'L')
      GetConsoleAliases              = Win32API.new('kernel32', 'GetConsoleAliases', 'PLP', 'L')
      GetConsoleAliasesLength        = Win32API.new('kernel32', 'GetConsoleAliasesLength', 'P', 'L')
      GetConsoleAliasExes            = Win32API.new('kernel32', 'GetConsoleAliasExes', 'PL', 'L')
      GetConsoleAliasExesLength      = Win32API.new('kernel32', 'GetConsoleAliasExesLength', 'V', 'L')
      GetConsoleCP                   = Win32API.new('kernel32', 'GetConsoleCP', 'V', 'I')
      GetConsoleCursorInfo           = Win32API.new('kernel32', 'GetConsoleCursorInfo', 'LP', 'I')
      GetConsoleDisplayMode          = Win32API.new('kernel32', 'GetConsoleDisplayMode', 'P', 'L')
      GetConsoleFontSize             = Win32API.new('kernel32', 'GetConsoleFontSize', 'LL', 'L')
      GetConsoleMode                 = Win32API.new('kernel32', 'GetConsoleMode', 'LP', 'I')
      GetConsoleOutputCP             = Win32API.new('kernel32', 'GetConsoleOutputCP', 'V', 'I')
      GetConsoleProcessList          = Win32API.new('kernel32', 'GetConsoleProcessList', 'PL', 'L')
      GetConsoleScreenBufferInfo     = Win32API.new('kernel32', 'GetConsoleScreenBufferInfo', 'LP', 'I')
      GetConsoleSelectionInfo        = Win32API.new('kernel32', 'GetConsoleSelectionInfo', 'P', 'I')
      GetConsoleTitle                = Win32API.new('kernel32', 'GetConsoleTitle', 'PL', 'L')
      GetConsoleWindow               = Win32API.new('kernel32', 'GetConsoleWindow', 'V', 'L')
      GetCurrentConsoleFont          = Win32API.new('kernel32', 'GetCurrentConsoleFont' , 'LIP', 'I')
      GetLargestConsoleWindowSize    = Win32API.new('kernel32', 'GetLargestConsoleWindowSize', 'L', 'L')
      GetNumberOfConsoleInputEvents  = Win32API.new('kernel32', 'GetNumberOfConsoleInputEvents', 'LP', 'I')
      GetNumberOfConsoleMouseButtons = Win32API.new('kernel32', 'GetNumberOfConsoleMouseButtons', 'L', 'I')
      GetStdHandle                   = Win32API.new('kernel32', 'GetStdHandle', 'L', 'L')
      PeekConsoleInput               = Win32API.new('kernel32', 'PeekConsoleInput', 'LPLP', 'I')
      ReadConsole                    = Win32API.new('kernel32', 'ReadConsole', 'LPLPP', 'I')
      ReadConsoleInput               = Win32API.new('kernel32', 'ReadConsoleInput', 'LPLP', 'I')
      ReadConsoleOutput              = Win32API.new('kernel32', 'ReadConsoleOutput', 'LPLLP', 'I')
      ReadConsoleOutputAttribute     = Win32API.new('kernel32', 'ReadConsoleOutputAttribute', 'LPLLP', 'I')
      ReadConsoleOutputCharacter     = Win32API.new('kernel32', 'ReadConsoleOutputCharacter', 'LPLLP', 'I')
      ScrollConsoleScreenBuffer      = Win32API.new('kernel32', 'ScrollConsoleScreenBuffer', 'LPPLP', 'I')
      SetConsoleActiveScreenBuffer   = Win32API.new('kernel32', 'SetConsoleActiveScreenBuffer', 'L', 'I')
      SetConsoleCommandHistoryMode   = Win32API.new('kernel32', 'SetConsoleCommandHistoryMode', 'L', 'I')
      SetConsoleCP                   = Win32API.new('kernel32', 'SetConsoleCP', 'L', 'I')
      SetConsoleCtrlHandler          = Win32API.new('kernel32', 'SetConsoleCtrlHandler', 'PI', 'I')
      SetConsoleCursorInfo           = Win32API.new('kernel32', 'SetConsoleCursorInfo', 'LP', 'I')
      SetConsoleCursorPosition       = Win32API.new('kernel32', 'SetConsoleCursorPosition', 'LP', 'I')
      SetConsoleDisplayMode          = Win32API.new('kernel32', 'SetConsoleDisplayMode', 'LLP', 'I')
      SetConsoleMode                 = Win32API.new('kernel32', 'SetConsoleMode', 'LL', 'I')
      SetConsoleOutputCP             = Win32API.new('kernel32', 'SetConsoleOutputCP', 'I', 'I')
      SetConsoleScreenBufferSize     = Win32API.new('kernel32', 'SetConsoleScreenBufferSize', 'LL', 'I')
      SetConsoleTextAttribute        = Win32API.new('kernel32', 'SetConsoleTextAttribute', 'LL', 'I')
      SetConsoleTitle                = Win32API.new('kernel32', 'SetConsoleTitle', 'P', 'I')
      SetConsoleWindowInfo           = Win32API.new('kernel32', 'SetConsoleWindowInfo', 'LIP', 'I')
      SetStdHandle                   = Win32API.new('kernel32', 'SetStdHandle', 'LL', 'I')
      WriteConsole                   = Win32API.new('kernel32', 'WriteConsole', 'LPLPP', 'I')
      WriteConsoleInput              = Win32API.new('kernel32', 'WriteConsoleInput', 'LPLP', 'I')
      WriteConsoleOutput             = Win32API.new('kernel32', 'WriteConsoleOutput', 'LPLLP', 'I')
      WriteConsoleOutputAttribute    = Win32API.new('kernel32', 'WriteConsoleOutputAttribute', 'LPLLP', 'I')
      WriteConsoleOutputCharacter    = Win32API.new('kernel32', 'WriteConsoleOutputCharacter', 'LPLLP', 'I')

      def AddConsoleAlias(source, target, exe)
         AddConsoleAlias.call(source, target, exe) != 0
      end

      def AllocConsole()
         AllocConsole.call != 0
      end

      def AttachConsole(pid)
         AttachConsole.call(pid)
      end

      def CreateConsoleScreenBuffer(access, mode, sec, flags, data)
         CreateConsoleScreenBuffer.call(access, mode, sec, flags, data)
      end

      def FillConsoleOutputAttribute(handle, attribute, length, coord, num)
         FillConsoleOutputAttribute.call(handle, attribute, length, coord, num) != 0
      end

      def FlushConsoleInputBuffer(handle)
         FlushConsoleInputBuffer.call(handle) != 0
      end

      def FreeConsole()
         FreeConsole.call != 0
      end

      def GenerateConsoleCtrlEvent(ctrl_event, process_group_id)
         GenerateConsoleCtrlEvent.call(ctrl_event, process_group_id) != 0
      end
      
      def GetConsoleAliases(buffer, buffer_length, exe_name)
         GetConsoleAliases.call(buffer, buffer_length, exe_name)
      end

      def GetConsoleAliasesLength(exe_name)
         GetConsoleAliasesLength.call(exe_name)
      end

      def GetConsoleAliasExes(buffer, buffer_length)
         GetConsoleAliasExes.call(buffer, buffer_length)
      end

      def GetConsoleAliasExesLength()
         GetConsoleAliasExesLength.call
      end

      def GetConsoleCP()
         GetConsoleCP.call
      end

      def GetConsoleCursorInfo(handle, cursor_info_ptr)
         GetConsoleCursorInfo.call(handle, cursor_info_ptr)
      end

      # The docs say this returns a BOOL, but really it's a DWORD
      def GetConsoleDisplayMode(flags)
         GetConsoleDisplayMode.call(flags)
      end

      def GetConsoleFontSize(handle, font)
         GetConsoleFontSize.call(handle, font)
      end

      def GetConsoleMode(handle, mode)
         GetConsoleMode.call(handle, mode) != 0
      end

      def GetConsoleOutputCP()
         GetConsoleOutputCP.call
      end

      def GetConsoleProcessList(proc_list, proc_count)
         GetConsoleProcessList.call(proc_list, proc_count)
      end

      def GetConsoleScreenBufferInfo(handle, buf_info)
         GetConsoleScreenBufferInfo.call(handle, buf_info) != 0
      end

      def GetConsoleSelectionInfo(info_struct)
         GetConsoleSelectionInfo.call(info_struct) != 0
      end

      def GetConsoleTitle(title, size)
         GetConsoleTitle.call(title, size)
      end

      def GetConsoleWindow()
         GetConsoleWindow.call
      end

      def GetCurrentConsoleFont(handle, max_window, current_font_struct)
         GetCurrentConsoleFont.call(handle, max_window, current_font_struct)
      end

      def GetLargestConsoleWindowSize(handle)
         GetLargestConsoleWindowSize.call(handle)
      end

      def GetNumberOfConsoleInputEvents(handle, num_events)
         GetNumberOfConsoleInputEvents.call(handle, num_events)
      end

      def GetNumberOfConsoleMouseButtons(num_mouse_buttons)
         GetNumberOfConsoleMouseButtons.call(num_mouse_buttons)
      end

      def GetStdHandle(std_handle)
         GetStdHandle.call(std_handle)
      end

      def PeekConsoleInput(handle, buffer, length, num_events)
         PeekConsoleInput.call(handle, buffer, length, num_events) != 0
      end

      def ReadConsole(handle, buffer, num_to_read, num_read, res = 0)
         ReadConsole.call(handle, buffer, num_to_read, num_read, res) != 0
      end

      def ReadConsoleInput(handle, buffer, length, num_read)
         ReadConsoleInput.call(handle, buffer, length, num_read) != 0
      end

      def ReadConsoleOutput(handle, buffer, buf_size, buf_coord, reg)
         ReadConsoleOutput.call(handle, buffer, buf_size, buf_coord, reg) != 0
      end

      def ReadConsoleOutputAttribute(handle, attrib, len, coord, num_read)
         ReadConsoleOutputAttribute.call(handle, attrib, len, coord, num_read) != 0
      end

      def ReadConsoleOutputCharacter(handle, char, length, coord, num_read)
         ReadConsoleOutputCharacter.call(handle, char, length, coord, num_read) != 0
      end
      
      def ScrollConsoleScreenBuffer(handle, scroll, clip, coord, fill)
         ScrollConsoleScreenBuffer.call(handle, scroll, clip, coord, fill) != 0
      end

      def SetConsoleActiveScreenBuffer(handle)
         SetConsoleActiveScreenBuffer.call(handle) != 0
      end

      def SetConsoleCommandHistoryMode(flags)
         SetConsoleCommandHistoryMode.call(flags) != 0
      end

      def SetConsoleCP(code_page_id)
         SetConsoleCP.call(code_page_id) != 0
      end

      def SetConsoleCtrlHandler(handler, add)
         SetConsoleCtrlHandler.call(handler, add) != 0
      end

      def SetConsoleCursorInfo(handle, cursor)
         SetConsoleCursorInfo.call(handle, cursor) != 0
      end

      def SetConsoleCursorPosition(handle, coord)
         SetConsoleCursorPosition.call(handle, coord) != 0
      end

      def SetConsoleDisplayMode(handle, flags, coord)
         SetConsoleDisplayMode.call(handle, flags, coord) != 0
      end

      def SetConsoleHistoryInfo(info)
         SetConsoleHistoryInfo.call(info) != 0
      end

      def SetConsoleMode(handle, mode)
         SetConsoleMode.call(handle, mode) != 0
      end

      def SetConsoleOutputCP(code_page_id)
         SetConsoleOutputCP.call(code_page_id) != 0
      end
      
      def SetConsoleScreenBufferSize(handle, size)
         SetConsoleScreenBufferSize.call(handle, size) != 0
      end

      def SetConsoleTextAttribute(handle, attribute)
         SetConsoleTextAttribute.call(handle, attribute) != 0
      end

      def SetConsoleTitle(title)
         SetConsoleTitle.call(title) != 0
      end

      def SetConsoleWindowInfo(handle, absolute, window)
         SetConsoleWindowInfo.call(handle, absolute, window) != 0
      end

      def SetStdHandle(std_handle, handle)
         SetStdHandle.call(std_handle, handle) != 0
      end

      def WriteConsole(handle, buffer, num_to_write, num_written, res = 0)
         WriteConsole.call(handle, buffer, num_to_write, num_written, res) != 0
      end

      def WriteConsoleInput(handle, buffer, length, num_events)
         WriteConsoleInput.call(handle, buffer, length, num_events) != 0
      end

      def WriteConsoleOutput(handle, buffer, buf_size, coord, region)
         WriteConsoleOutput.call(handle, buffer, buf_size, coord, region) != 0
      end

      def WriteConsoleOutputAttribute(handle, attrib, length, coord, num)
         WriteConsoleOutputAttribute.call(handle, attrib, length, coord, num) != 0
      end

      def WriteConsoleOutputCharacter(handle, char, length, coord, num)
         WriteConsoleOutputCharacter.call(handle, char, length, coord, num) != 0
      end
   end
end
