require 'windows/unicode'

module Windows
   module File
      # File Attributes
      FILE_ATTRIBUTE_READONLY      = 0x00000001  
      FILE_ATTRIBUTE_HIDDEN        = 0x00000002  
      FILE_ATTRIBUTE_SYSTEM        = 0x00000004  
      FILE_ATTRIBUTE_DIRECTORY     = 0x00000010  
      FILE_ATTRIBUTE_ARCHIVE       = 0x00000020  
      FILE_ATTRIBUTE_ENCRYPTED     = 0x00000040  
      FILE_ATTRIBUTE_NORMAL        = 0x00000080   
      FILE_ATTRIBUTE_TEMPORARY     = 0x00000100  
      FILE_ATTRIBUTE_SPARSE_FILE   = 0x00000200  
      FILE_ATTRIBUTE_REPARSE_POINT = 0x00000400  
      FILE_ATTRIBUTE_COMPRESSED    = 0x00000800  
      FILE_ATTRIBUTE_OFFLINE       = 0x00001000  
      FILE_ATTRIBUTE_NOT_CONTENT_INDEXED = 0x00002000
      
      # File types
      FILE_TYPE_UNKNOWN = 0x0000
      FILE_TYPE_DISK    = 0x0001
      FILE_TYPE_CHAR    = 0x0002
      FILE_TYPE_PIPE    = 0x0003
      FILE_TYPE_REMOTE  = 0x8000
      
      # File security and access rights
      APPLICATION_ERROR_MASK       = 0x20000000
      ERROR_SEVERITY_SUCCESS       = 0x00000000
      ERROR_SEVERITY_INFORMATIONAL = 0x40000000
      ERROR_SEVERITY_WARNING       = 0x80000000
      ERROR_SEVERITY_ERROR         = 0xc0000000
      COMPRESSION_FORMAT_NONE      = 0
      COMPRESSION_FORMAT_DEFAULT   = 1
      COMPRESSION_FORMAT_LZNT1     = 2
      COMPRESSION_ENGINE_STANDARD  = 0
      COMPRESSION_ENGINE_MAXIMUM   = 256
      ACCESS_ALLOWED_ACE_TYPE      = 0
      ACCESS_DENIED_ACE_TYPE       = 1
      ANYSIZE_ARRAY                = 1
      SYSTEM_AUDIT_ACE_TYPE        = 2
      SYSTEM_ALARM_ACE_TYPE        = 3
      OBJECT_INHERIT_ACE           = 1
      CONTAINER_INHERIT_ACE        = 2
      NO_PROPAGATE_INHERIT_ACE     = 4
      INHERIT_ONLY_ACE             = 8
      VALID_INHERIT_FLAGS          = 16
      SUCCESSFUL_ACCESS_ACE_FLAG   = 64
      FAILED_ACCESS_ACE_FLAG       = 128
      DELETE                       = 0x00010000
      READ_CONTROL                 = 0x20000
      WRITE_DAC                    = 0x40000
      WRITE_OWNER                  = 0x80000
      SYNCHRONIZE                  = 0x100000
      STANDARD_RIGHTS_REQUIRED     = 0xf0000
      STANDARD_RIGHTS_READ         = 0x20000
      STANDARD_RIGHTS_WRITE        = 0x20000
      STANDARD_RIGHTS_EXECUTE      = 0x20000
      STANDARD_RIGHTS_ALL          = 0x1f0000
      SPECIFIC_RIGHTS_ALL          = 0xffff
      ACCESS_SYSTEM_SECURITY       = 0x1000000
      MAXIMUM_ALLOWED              = 0x2000000
      GENERIC_READ                 = 0x80000000
      GENERIC_WRITE                = 0x40000000
      GENERIC_EXECUTE              = 0x20000000
      GENERIC_ALL                  = 0x10000000
      FILE_READ_DATA               = 1
      FILE_LIST_DIRECTORY          = 1
      FILE_WRITE_DATA              = 2
      FILE_ADD_FILE                = 2
      FILE_APPEND_DATA             = 4
      FILE_ADD_SUBDIRECTORY        = 4
      FILE_CREATE_PIPE_INSTANCE    = 4
      FILE_READ_EA                 = 8
      FILE_READ_PROPERTIES         = 8
      FILE_WRITE_EA                = 16
      FILE_WRITE_PROPERTIES        = 16
      FILE_EXECUTE                 = 32
      FILE_TRAVERSE                = 32
      FILE_DELETE_CHILD            = 64
      FILE_READ_ATTRIBUTES         = 128
      FILE_WRITE_ATTRIBUTES        = 256
	
      FILE_ALL_ACCESS = (STANDARD_RIGHTS_REQUIRED|SYNCHRONIZE|0x1ff)
	
      FILE_GENERIC_READ = (STANDARD_RIGHTS_READ|FILE_READ_DATA|
         FILE_READ_ATTRIBUTES|FILE_READ_EA|SYNCHRONIZE)
	                               
      FILE_GENERIC_WRITE = (STANDARD_RIGHTS_WRITE|FILE_WRITE_DATA|
         FILE_WRITE_ATTRIBUTES|FILE_WRITE_EA|FILE_APPEND_DATA|SYNCHRONIZE)
	           
      FILE_GENERIC_EXECUTE = (STANDARD_RIGHTS_EXECUTE|FILE_READ_ATTRIBUTES|
         FILE_EXECUTE|SYNCHRONIZE)
	         
      FILE_SHARE_READ                = 1
      FILE_SHARE_WRITE               = 2
      FILE_SHARE_DELETE              = 4
      FILE_NOTIFY_CHANGE_FILE_NAME   = 1
      FILE_NOTIFY_CHANGE_DIR_NAME    = 2
      FILE_NOTIFY_CHANGE_ATTRIBUTES  = 4
      FILE_NOTIFY_CHANGE_SIZE        = 8
      FILE_NOTIFY_CHANGE_LAST_WRITE  = 16
      FILE_NOTIFY_CHANGE_LAST_ACCESS = 32
      FILE_NOTIFY_CHANGE_CREATION    = 64
      FILE_NOTIFY_CHANGE_SECURITY    = 256
      MAILSLOT_NO_MESSAGE            = -1
      MAILSLOT_WAIT_FOREVER          = -1
      FILE_CASE_SENSITIVE_SEARCH     = 1
      FILE_CASE_PRESERVED_NAMES      = 2
      FILE_UNICODE_ON_DISK           = 4
      FILE_PERSISTENT_ACLS           = 8
      FILE_FILE_COMPRESSION          = 16
      FILE_VOLUME_QUOTAS             = 32
      FILE_SUPPORTS_SPARSE_FILES     = 64
      FILE_SUPPORTS_REPARSE_POINTS   = 128
      FILE_SUPPORTS_REMOTE_STORAGE   = 256
      FILE_VOLUME_IS_COMPRESSED      = 0x8000
      FILE_SUPPORTS_OBJECT_IDS       = 0x10000  
      FILE_SUPPORTS_ENCRYPTION       = 0x20000
      
      # File flags
      FILE_FLAG_WRITE_THROUGH       = 0x80000000
      FILE_FLAG_OVERLAPPED          = 0x40000000
      FILE_FLAG_NO_BUFFERING        = 0x20000000
      FILE_FLAG_RANDOM_ACCESS       = 0x10000000
      FILE_FLAG_SEQUENTIAL_SCAN     = 0x08000000
      FILE_FLAG_DELETE_ON_CLOSE     = 0x04000000
      FILE_FLAG_BACKUP_SEMANTICS    = 0x02000000
      FILE_FLAG_POSIX_SEMANTICS     = 0x01000000
      FILE_FLAG_OPEN_REPARSE_POINT  = 0x00200000
      FILE_FLAG_OPEN_NO_RECALL      = 0x00100000
      FILE_FLAG_FIRST_PIPE_INSTANCE = 0x00080000
      
      # File creation disposition
      CREATE_NEW        = 1
      CREATE_ALWAYS     = 2
      OPEN_EXISTING     = 3
      OPEN_ALWAYS       = 4
      TRUNCATE_EXISTING = 5

      # Page file access
      PAGE_NOACCESS          = 0x01     
      PAGE_READONLY          = 0x02     
      PAGE_READWRITE         = 0x04     
      PAGE_WRITECOPY         = 0x08     
      PAGE_EXECUTE           = 0x10     
      PAGE_EXECUTE_READ      = 0x20     
      PAGE_EXECUTE_READWRITE = 0x40     
      PAGE_EXECUTE_WRITECOPY = 0x80     
      PAGE_GUARD             = 0x100     
      PAGE_NOCACHE           = 0x200     
      PAGE_WRITECOMBINE      = 0x400
      SEC_FILE               = 0x800000     
      SEC_IMAGE              = 0x1000000     
      SEC_VLM                = 0x2000000     
      SEC_RESERVE            = 0x4000000     
      SEC_COMMIT             = 0x8000000     
      SEC_NOCACHE            = 0x10000000
      
      SECTION_QUERY       = 0x0001
      SECTION_MAP_WRITE   = 0x0002
      SECTION_MAP_READ    = 0x0004
      SECTION_MAP_EXECUTE = 0x0008
      SECTION_EXTEND_SIZE = 0x0010

      SECTION_ALL_ACCESS = STANDARD_RIGHTS_REQUIRED | SECTION_QUERY |
         SECTION_MAP_WRITE | SECTION_MAP_READ | SECTION_MAP_EXECUTE |
         SECTION_EXTEND_SIZE
      
      FILE_MAP_COPY       = SECTION_QUERY
      FILE_MAP_WRITE      = SECTION_MAP_WRITE
      FILE_MAP_READ       = SECTION_MAP_READ
      FILE_MAP_ALL_ACCESS = SECTION_ALL_ACCESS
      
      # Errors
      INVALID_FILE_ATTRIBUTES   = -1
      INVALID_HANDLE_VALUE      = -1
      INVALID_FILE_SIZE         = 0xFFFFFFFF
     
      CopyFile       = Win32API.new('kernel32', 'CopyFile', 'PPI', 'I')
      CopyFileEx     = Win32API.new('kernel32', 'CopyFileEx', 'PPPPPL', 'I')
      CreateFile     = Win32API.new('kernel32', 'CreateFile', 'PLLPLLL', 'L')
      CreateFileW    = Win32API.new('kernel32', 'CreateFileW', 'PLLPLLL', 'L')

      CreateFileMapping = Win32API.new('kernel32', 'CreateFileMapping', 'LPLLLP', 'L')

      CreateHardLink = Win32API.new('kernel32', 'CreateHardLink', 'PPP', 'I')
      DecryptFile    = Win32API.new('advapi32', 'DecryptFile', 'PL', 'I')
      DeleteFile     = Win32API.new('kernel32', 'DeleteFile', 'P', 'I')
      EncryptFile    = Win32API.new('advapi32', 'EncryptFile', 'P', 'I')
      
      FlushViewOfFile = Win32API.new('kernel32', 'FlushViewOfFile', 'PL', 'I')

      GetBinaryType       = Win32API.new('kernel32', 'GetBinaryType', 'PP', 'I')
      GetFileAttributes   = Win32API.new('kernel32', 'GetFileAttributes', 'P', 'L')
      GetFileAttributesEx = Win32API.new('kernel32', 'GetFileAttributesEx', 'PPP', 'I')
      GetFileSize         = Win32API.new('kernel32', 'GetFileSize', 'LP', 'L')
      GetFileSizeEx       = Win32API.new('kernel32', 'GetFileSizeEx', 'LP', 'L')
      GetFileType         = Win32API.new('kernel32', 'GetFileType', 'L', 'L')
      GetFullPathName     = Win32API.new('kernel32', 'GetFullPathName', 'PLPP', 'L')
      GetFullPathNameW    = Win32API.new('kernel32', 'GetFullPathNameW', 'PLPP', 'L')
      GetLongPathName     = Win32API.new('kernel32', 'GetLongPathName', 'PPL', 'L')
      GetShortPathName    = Win32API.new('kernel32', 'GetShortPathName', 'PPL', 'L')

      LockFile   = Win32API.new('kernel32', 'LockFile', 'LLLLL', 'I')
      LockFileEx = Win32API.new('kernel32', 'LockFileEx', 'LLLLLL', 'I')

      MapViewOfFile   = Win32API.new('kernel32', 'MapViewOfFile', 'LLLLL', 'L')
      MapViewOfFileEx = Win32API.new('kernel32', 'MapViewOfFileEx', 'LLLLLL', 'L')
      OpenFileMapping = Win32API.new('kernel32', 'OpenFileMapping', 'LIP', 'L')

      ReadFile   = Win32API.new('kernel32', 'ReadFile', 'LPLPP', 'I')
      ReadFileEx = Win32API.new('kernel32', 'ReadFileEx', 'LPLPP', 'I')

      SetFileAttributes = Win32API.new('kernel32', 'SetFileAttributes', 'PL', 'I')

      UnlockFile   = Win32API.new('kernel32', 'UnlockFile', 'LLLLL', 'I')
      UnlockFileEx = Win32API.new('kernel32', 'UnlockFileEx', 'LLLLL', 'I')

      UnmapViewOfFile = Win32API.new('kernel32', 'UnmapViewOfFile', 'P', 'I')

      WriteFile    = Win32API.new('kernel32', 'WriteFile', 'LPLPP', 'I')
      WriteFileEx  = Win32API.new('kernel32', 'WriteFileEx', 'LPLPP', 'I')

      def CopyFile(curr_file, new_file, bail)
         CopyFile.call(curr_file, new_file, bail) > 0
      end

      def CopyFileEx(curr_file, new_file, routine, data, cancel, flags)
         CopyFileEx.call(curr_file, new_file, routine, data, cancel, flags) > 0
      end

      def CreateFile(file, access, share, sec, disp, flags, template)
         CreateFile.call(file, access, share, sec, disp, flags, template)
      end

      def CreateFileMapping(handle, security, protect, high, low, name)
         CreateFileMapping.call(handle, security, protect, high, low, name)
      end

      def CreateHardLink(new_file, old_file, attributes)
         CreateHardLink.call(new_file, old_file, attributes) > 0
      end

      def DecryptFile(file, res = 0)
         DecryptFile.call(file, res)
      end

      def DeleteFile(file)
         DeleteFile.call(file) > 0
      end

      def EncryptFile(file)
         EncryptFile.call(file) > 0
      end
      
      def FlushViewOfFile(address, bytes)
         FlushViewOfFile.call(address, bytes) != 0
      end

      def GetBinaryType(file, type)
         GetBinaryType.call(file, type) > 0
      end

      def GetFileAttributes(file)
         GetFileAttributes.call(file)
      end

      def GetFileAttributesEx(file, level_id, info)
         GetFileAttributesEx.call(file, level_id, info)
      end

      def GetFileSize(handle, size)
         GetFileSize.call(handle, size)
      end

      def GetFileSizeEx(handle, size)
         GetFileSizeEx.call(handle, size) > 0
      end

      def GetFileType(handle)
         GetFileType.call(handle)
      end
      
      def GetFullPathName(file, buf, buf_size, part)
         GetFullPathName.call(file, buf, buf_size, part)
      end
      
      def GetLongPathName(short, buf, buf_size)
         GetLongPathName.call(short, buf, buf_size)
      end
      
      def GetShortPathName(long, buf, buf_size)
         GetShortPathName.call(long, buf, buf_size)
      end

      def LockFile(handle, off_low, off_high, lock_low, lock_high)
         LockFile.call(handle, off_low, off_high, lock_low, lock_high) > 0
      end

      def LockFileEx(handle, flags, res, low, high, overlapped)
         LockFileEx.call(handle, flags, res, low, high, overlapped) > 0
      end

      def MapViewOfFile(handle, access, high, low, bytes)
         MapViewOfFile.call(handle, access, high, low, bytes)
      end
      
      def MapViewOfFileEx(handle, access, high, low, bytes, address)
         MapViewOfFileEx.call(handle, access, high, low, bytes, address)
      end

      def OpenFileMapping(access, inherit, name)
         OpenFileMapping.call(access, inherit, name)
      end

      def ReadFile(file, buf, bytes, bytes_read, overlapped)
         ReadFile.call(file, buf, bytes, bytes_read, overlapped) > 0
      end

      def ReadFileEx(file, buf, bytes, overlapped, routine)
         ReadFileEx.call(file, buf, bytes, overlapped, routine) > 0
      end

      def SetFileAttributes(file, attributes)
         SetFileAttributes.call(file, attributes) > 0
      end

      def UnlockFile(handle, off_low, off_high, bytes_low, bytes_high)
         UnlockFile.call(handle, off_low, off_high, bytes_low, bytes_high) > 0
      end

      def UnlockFileEx(handle, res, low, high, overlapped)
         UnlockFileEx.call(handle, res, low, high, overlapped) > 0
      end

      def UnmapViewOfFile(address)
         UnmapViewOfFile.call(address) != 0
      end

      def WriteFile(handle, buf, bytes, overlapped)
         WriteFileEx.call(handle, buf, bytes, overlapped) > 0
      end

      def WriteFileEx(handle, buf, bytes, overlapped, routine)
         WriteFileEx.call(handle, buf, bytes, overlapped, routine) > 0
      end
   end
end
