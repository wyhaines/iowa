require 'Win32API'

module Windows
   module Clipboard
      CF_TEXT         = 1
      CF_BITMAP       = 2
      CF_METAFILEPICT = 3
      CF_SYLK         = 4
      CF_DIF          = 5
      CF_TIFF         = 6
      CF_OEMTEXT      = 7
      CF_DIB          = 8
      CF_PALETTE      = 9
      CF_PENDATA      = 10
      CF_RIFF         = 11
      CF_WAVE         = 12
      CF_UNICODETEXT  = 13
      CF_ENHMETAFILE  = 14

      OpenClipboard    = Win32API.new('user32', 'OpenClipboard', 'L', 'I')
      CloseClipboard   = Win32API.new('user32', 'CloseClipboard', 'V', 'I')
      GetClipboardData = Win32API.new('user32', 'GetClipboardData', 'I', 'P')
      EmptyClipboard   = Win32API.new('user32', 'EmptyClipboard', 'V', 'I')
      SetClipboardData = Win32API.new('user32', 'SetClipboardData', 'II', 'I')

      CountClipboardFormats      = Win32API.new('user32', 'CountClipboardFormats', 'V', 'I')
      IsClipboardFormatAvailable = Win32API.new('user32', 'IsClipboardFormatAvailable', 'I', 'I')
      GetClipboardFormatName     = Win32API.new('user32', 'GetClipboardFormatName', 'IPI', 'I')
      EnumClipboardFormats       = Win32API.new('user32', 'EnumClipboardFormats', 'I', 'I')
      RegisterClipboardFormat    = Win32API.new('user32', 'RegisterClipboardFormat', 'P', 'I')

      def OpenClipboard(handle)
         OpenClipboard.call(handle) > 0
      end

      def CloseClipboard
         CloseClipboard.call > 0
      end

      def GetClipboardData(format)
         GetClipboardData.call(format)
      end

      def EmptyClipboard
         EmptyClipboard.call > 0
      end

      def SetClipboardData(format, handle)
         SetClipboardData.call(format, handle)
      end

      def CountClipboardFormats
         CountClipboardFormats.call
      end

      def IsClipboardFormatAvailable(format)
         IsClipboardFormatAvailable.call(format) > 0
      end

      def GetClipboardFormatName(format, format_name, max)
         GetClipboardFormatName.call(format, format_name, max)
      end

      def EnumClipboardFormats(format)
         EnumClipboardFormats.call(format)
      end

      def RegisterClipboardFormat(format)
         RegisterClipboardFormat.call(format)
      end
   end
end
