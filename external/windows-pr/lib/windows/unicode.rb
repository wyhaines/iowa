require 'Win32API'

module Windows
   module Unicode
      CP_ACP         = 0
      CP_OEMCP       = 1
      CP_MACCP       = 2
      CP_THREAD_ACP  = 3
      CP_SYMBOL      = 42
      CP_UTF7        = 65000
      CP_UTF8        = 65001

      MB_PRECOMPOSED       = 0x00000001
      MB_COMPOSITE         = 0x00000002
      MB_USEGLYPHCHARS     = 0x00000004
      MB_ERR_INVALID_CHARS = 0x00000008

      WC_COMPOSITECHECK    = 0x00000200 
      WC_DISCARDNS         = 0x00000010
      WC_SEPCHARS          = 0x00000020
      WC_DEFAULTCHAR       = 0x00000040
      WC_NO_BEST_FIT_CHARS = 0x00000400

      ANSI_CHARSET        = 0
      DEFAULT_CHARSET     = 1
      SYMBOL_CHARSET      = 2
      SHIFTJIS_CHARSET    = 128
      HANGEUL_CHARSET     = 129
      HANGUL_CHARSET      = 129
      GB2312_CHARSET      = 134
      CHINESEBIG5_CHARSET = 136
      OEM_CHARSET         = 255
      JOHAB_CHARSET       = 130
      HEBREW_CHARSET      = 177
      ARABIC_CHARSET      = 178
      GREEK_CHARSET       = 161
      TURKISH_CHARSET     = 162
      VIETNAMESE_CHARSET  = 163
      THAI_CHARSET        = 222
      EASTEUROPE_CHARSET  = 238
      RUSSIAN_CHARSET     = 204

      IS_TEXT_UNICODE_ASCII16            = 0x0001
      IS_TEXT_UNICODE_REVERSE_ASCII16    = 0x0010
      IS_TEXT_UNICODE_STATISTICS         = 0x0002
      IS_TEXT_UNICODE_REVERSE_STATISTICS = 0x0020
      IS_TEXT_UNICODE_CONTROLS           = 0x0004
      IS_TEXT_UNICODE_REVERSE_CONTROLS   = 0x0040
      IS_TEXT_UNICODE_SIGNATURE          = 0x0008
      IS_TEXT_UNICODE_REVERSE_SIGNATURE  = 0x0080
      IS_TEXT_UNICODE_ILLEGAL_CHARS      = 0x0100
      IS_TEXT_UNICODE_ODD_LENGTH         = 0x0200
      IS_TEXT_UNICODE_DBCS_LEADBYTE      = 0x0400
      IS_TEXT_UNICODE_NULL_BYTES         = 0x1000
      IS_TEXT_UNICODE_UNICODE_MASK       = 0x000F
      IS_TEXT_UNICODE_REVERSE_MASK       = 0x00F0
      IS_TEXT_UNICODE_NOT_UNICODE_MASK   = 0x0F00
      IS_TEXT_UNICODE_NOT_ASCII_MASK     = 0xF000

      TCI_SRCCHARSET  = 1
      TCI_SRCCODEPAGE = 2
      TCI_SRCFONTSIG  = 3
      TCI_SRCLOCALE   = 0x100

      GetTextCharset       = Win32API.new('gdi32', 'GetTextCharset', 'L', 'I')
      GetTextCharsetInfo   = Win32API.new('gdi32', 'GetTextCharsetInfo', 'LPL', 'I')
      IsDBCSLeadByte       = Win32API.new('kernel32', 'IsDBCSLeadByte', 'P', 'I')
      IsDBCSLeadByteEx     = Win32API.new('kernel32', 'IsDBCSLeadByteEx', 'IP', 'I')
      IsTextUnicode        = Win32API.new('advapi32', 'IsTextUnicode', 'PIP', 'I')
      MultiByteToWideChar  = Win32API.new('kernel32', 'MultiByteToWideChar', 'ILPIPI', 'I')
      TranslateCharsetInfo = Win32API.new('gdi32', 'TranslateCharsetInfo', 'PPL', 'I')
      WideCharToMultiByte  = Win32API.new('kernel32', 'WideCharToMultiByte', 'ILPIPIPP', 'I')

      def GetTextCharset(hdc)
         GetTextCharset.call(hdc)
      end

      def GetTextCharsetInfo(hdc, sig, flags)
         GetTextCharsetInfo.call(hdc, sig, flags)
      end

      def IsDBCSLeadByte(char)
         IsDBCSLeadByte.call(char) != 0
      end

      def IsDBCSLeadByteEx(code_page, char)
         IsDBCSLeadByteEx.call(code_pag, char) != 0
      end

      def IsTextUnicode(buf, size = buf.size, options = 0)
         IsTextUnicode.call(buf, size, options) != 0
      end

      def MultiByteToWideChar(page, flags, str, str_size, buf, buf_size)
         MultiByteToWideChar.call(page, flags, str, str_size, buf, buf_size)
      end

      def TranslateCharsetInfo(src, cs, flags)
         TranslateCharsetInfo.call(src, cs, flags) != 0
      end

      def WideCharToMultiByte(page, flags, str, str_size, buf, buf_size, defchar, used_def)
         WideCharToMultiByte.call(page, flags, str, str_size, buf, buf_size, defchar, used_def)
      end
      
      # Convenient wrapper methods
      
      # Maps a string to a wide (unicode) string using UTF8.  If the function
      # fails it just returns the string as is.
      # 
      def multi_to_wide(str)
         cp  = ($KCODE == 'UTF8') ? CP_UTF8 : CP_ACP
         buf = 0.chr * str.size * 2 # sizeof(WCHAR)
         int = MultiByteToWideChar(cp, 0, str, str.size, buf, buf.size)
         
         if int > 0
            buf[0, int*2]
         else
            str
         end
      end
      
      # Maps a wide character string to a new character string.  If the
      # function fails it just returns the string as is.
      # 
      def wide_to_multi(str)
         cp  = ($KCODE == 'UTF8') ? CP_UTF8 : CP_ACP
         buf = 0.chr * str.size
         int = WideCharToMultiByte(cp, 0, str, str.size/2, buf, buf.size, 0, 0)

         if int > 0
            buf[0, int]
         else
            str
         end
      end
   end
end
