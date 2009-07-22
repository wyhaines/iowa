require 'windows/file'

module Windows
   module Registry
      include Windows::File
      
      HKEY_CLASSES_ROOT        = 0x80000000
      KEY_CURRENT_USER         = 0x80000001
      HKEY_LOCAL_MACHINE       = 0x80000002
      HKEY_USERS               = 0x80000003
      HKEY_PERFORMANCE_DATA    = 0x80000004
      HKEY_PERFORMANCE_TEXT    = 0x80000050
      HKEY_PERFORMANCE_NLSTEXT = 0x80000060
      HKEY_CURRENT_CONFIG      = 0x80000005
      HKEY_DYN_DATA            = 0x80000006

      KEY_QUERY_VALUE         = 0x0001
      KEY_SET_VALUE           = 0x0002
      KEY_CREATE_SUB_KEY      = 0x0004
      KEY_ENUMERATE_SUB_KEYS  = 0x0008
      KEY_NOTIFY              = 0x0010
      KEY_CREATE_LINK         = 0x0020
      KEY_WOW64_32KEY         = 0x0200
      KEY_WOW64_64KEY         = 0x0100
      KEY_WOW64_RES           = 0x0300

      KEY_READ = (STANDARD_RIGHTS_READ|KEY_QUERY_VALUE|KEY_ENUMERATE_SUB_KEYS|
                  KEY_NOTIFY) & (~SYNCHRONIZE)

      KEY_WRITE = (STANDARD_RIGHTS_WRITE|KEY_SET_VALUE|
                  KEY_CREATE_SUB_KEY) & (~SYNCHRONIZE)

      KEY_EXECUTE = KEY_READ & (~SYNCHRONIZE)

      KEY_ALL_ACCESS = (STANDARD_RIGHTS_ALL|KEY_QUERY_VALUE|KEY_SET_VALUE|
                  KEY_CREATE_SUB_KEY|KEY_ENUMERATE_SUB_KEYS|KEY_NOTIFY|
                  KEY_CREATE_LINK) & (~SYNCHRONIZE)
                  
      REG_OPTION_RESERVED       = 0
      REG_OPTION_NON_VOLATILE   = 0
      REG_OPTION_VOLATILE       = 1
      REG_OPTION_CREATE_LINK    = 2
      REG_OPTION_BACKUP_RESTORE = 4
      REG_OPTION_OPEN_LINK      = 8

      REG_LEGAL_OPTION = REG_OPTION_RESERVED|REG_OPTION_NON_VOLATILE|
         REG_OPTION_VOLATILE|REG_OPTION_CREATE_LINK|REG_OPTION_BACKUP_RESTORE|
         REG_OPTION_OPEN_LINK

      REG_CREATED_NEW_KEY     = 1
      REG_OPENED_EXISTING_KEY = 2

      REG_STANDARD_FORMAT = 1
      REG_LATEST_FORMAT   = 2
      REG_NO_COMPRESSION  = 4

      REG_WHOLE_HIVE_VOLATILE = 1
      REG_REFRESH_HIVE        = 2
      REG_NO_LAZY_FLUSH       = 4
      REG_FORCE_RESTORE       = 8

      REG_FORCE_UNLOAD = 1

      REG_NOTIFY_CHANGE_NAME        = 1
      REG_NOTIFY_CHANGE_ATTRIBUTES  = 2
      REG_NOTIFY_CHANGE_LAST_SET    = 4
      REG_NOTIFY_CHANGE_SECURITY    = 8

      REG_LEGAL_CHANGE_FILTER = REG_NOTIFY_CHANGE_NAME|
         REG_NOTIFY_CHANGE_ATTRIBUTES|REG_NOTIFY_CHANGE_LAST_SET|
         REG_NOTIFY_CHANGE_SECURITY

      REG_NONE                       = 0
      REG_SZ                         = 1
      REG_EXPAND_SZ                  = 2    
      REG_BINARY                     = 3
      REG_DWORD                      = 4
      REG_DWORD_LITTLE_ENDIAN        = 4
      REG_DWORD_BIG_ENDIAN           = 5
      REG_LINK                       = 6
      REG_MULTI_SZ                   = 7
      REG_RESOURCE_LIST              = 8 
      REG_FULL_RESOURCE_DESCRIPTOR   = 9
      REG_RESOURCE_REQUIREMENTS_LIST = 10 
      REG_QWORD                      = 11 
      REG_QWORD_LITTLE_ENDIAN        = 11

      RegCloseKey               = Win32API.new('advapi32', 'RegCloseKey', 'L', 'L')
      RegConnectRegistry        = Win32API.new('advapi32', 'RegConnectRegistry', 'PLP', 'L')
      RegCreateKey              = Win32API.new('advapi32', 'RegCreateKey', 'LPP', 'L')
      RegCreateKeyEx            = Win32API.new('advapi32', 'RegCreateKeyEx', 'LPLPLLPPP', 'L')
      RegDeleteKey              = Win32API.new('advapi32', 'RegDeleteKey', 'LP', 'L')
      RegDeleteValue            = Win32API.new('advapi32', 'RegDeleteValue', 'LP', 'L')
      RegDisablePredefinedCache = Win32API.new('advapi32', 'RegDisablePredefinedCache', 'V', 'L')
      RegEnumKey                = Win32API.new('advapi32', 'RegEnumKey', 'LLPL', 'L')
      RegEnumKeyEx              = Win32API.new('advapi32', 'RegEnumKeyEx', 'LLPPPPP', 'L')
      RegEnumValue              = Win32API.new('advapi32', 'RegEnumValue', 'LLPPPPPP', 'L')
      RegFlushKey               = Win32API.new('advapi32', 'RegFlushKey', 'L', 'L')
      RegLoadKey                = Win32API.new('advapi32', 'RegLoadKey', 'LPP', 'L')
      RegNotifyChangeKeyValue   = Win32API.new('advapi32', 'RegNotifyChangeKeyValue', 'LILLI', 'L')
      RegOpenCurrentUser        = Win32API.new('advapi32', 'RegOpenCurrentUser', 'LP', 'L')
      RegOpenKey                = Win32API.new('advapi32', 'RegOpenKey', 'LPP', 'L')
      RegOpenKeyEx              = Win32API.new('advapi32', 'RegOpenKeyEx', 'LPLLP', 'L')
      RegOpenUserClassesRoot    = Win32API.new('advapi32', 'RegOpenUserClassesRoot', 'LLLP', 'L')
      RegOverridePredefKey      = Win32API.new('advapi32', 'RegOverridePredefKey', 'LL', 'L')
      RegQueryInfoKey           = Win32API.new('advapi32', 'RegQueryInfoKey', 'LPPPPPPPPPPP', 'L')
      RegQueryMultipleValues    = Win32API.new('advapi32', 'RegQueryMultipleValues', 'LPLPP', 'L')
      RegQueryValueEx           = Win32API.new('advapi32', 'RegQueryValueEx', 'LPPPPP', 'L')
      RegReplaceKey             = Win32API.new('advapi32', 'RegReplaceKey', 'LPPP', 'L')
      RegRestoreKey             = Win32API.new('advapi32', 'RegRestoreKey', 'LPL', 'L')
      RegSaveKey                = Win32API.new('advapi32', 'RegSaveKey', 'LPP', 'L')      
      RegSetValueEx             = Win32API.new('advapi32', 'RegSetValueEx', 'LPLLPL', 'L')
      RegUnLoadKey              = Win32API.new('advapi32', 'RegUnLoadKey', 'LP', 'L')
      
      # Windows XP or later
      begin
         RegSaveKeyEx = Win32API.new('advapi32', 'RegSaveKeyEx', 'LPPL', 'L')
      rescue Exception
         # Do nothing - not supported on current platform.  It's up to you to
         # check for the existence of the constant in your code.
      end

      def RegCloseKey(key)
         RegCloseKey.call(key)
      end

      def RegConnectRegistry(machine, key, result)
         RegConnectRegistry.call(machine, key, result)
      end

      def RegCreateKey(key, subkey, result)
         RegCreateKey.call(key, subkey, result)
      end

      def RegCreateKeyEx(key, subkey, res, klass, opt, sam, sec, result, disp)
         RegCreateKeyEx.call(key, subkey, res, klass, opt, sam, sec, result, disp)
      end

      def RegDeleteKey(key, subkey)
         RegDeleteKey.call(key, subkey)
      end

      def RegDeleteValue(key, value)
         RegDeleteValue.call(key, value)
      end

      def RegDisablePredefinedCache()
         RegDisablePredefinedCache.call()
      end

      def RegEnumKey(key, index, name, size)
         RegEnumKey.call(key, index, name, size)
      end

      def RegEnumKeyEx(key, index, name, size, res, klass, ksize, time)
         RegEnumKeyEx.call(key, index, name, size, res, klass, ksize, time)
      end

      def RegEnumValue(key, index, value, size, res, type, data, dsize)
         RegEnumValue.call(key, index, value, size, res, type, data, dsize)
      end

      def RegOpenKeyEx(key, subkey, options, sam, result)
         RegOpenKeyEx.call(key, subkey, options, sam, result)
      end

      def RegFlushKey(key)
         RegFlushKey.call(key)
      end

      def RegLoadKey(key, subkey, file)
         RegLoadKey.call(key, subkey, file)
      end

      def RegNotifyChangeKeyValue(key, subtree, filter, event, async)
         RegNotifyChangeKeyValue.call(key, subtree, filter, event, async)
      end

      def RegOpenCurrentUser(sam, result)
         RegOpenCurrentUser.call(sam, result)
      end

      def RegOpenKeyEx(key, subkey, options, sam, result)
         RegOpenKeyEx.call(key, subkey, options, sam, result)
      end

      def RegOpenUserClassesRoot(token, options, sam, result)
         RegOpenUserClassesRoot.call(token, options, sam, result)
      end

      def RegOverridePredefKey(key, new_key)
         RegOverridePredefKey.call(key, new_key)
      end

      def RegQueryInfoKey(key, klass, ksize, res, subkeys, maxkey, maxklass,
         values, maxname, maxvalue, sec, time)
         RegQueryInfoKey.call(key, klass, ksize, res, subkeys, maxkey, maxklass,
            values, maxname, maxvalue, sec, time)
      end

      def RegQueryMultipleValues(key, val_list, num_vals, buf, size)
         RegQueryMultipleValues.call(key, val_list, num_vals, buf, size)
      end

      def RegQueryValueEx(key, value, res, type, data, cbdata)
         RegQueryValueEx.call(key, value, res, type, data, cbdata)
      end

      def RegReplaceKey(key, subkey, newfile, oldfile)
         RegReplaceKey.call(key, subkey, newfile, oldfile)
      end

      def RegRestoreKey(key, file, flags)
         RegRestoreKey.call(key, file, flags)
      end

      def RegSaveKey(key, file, sec)
         RegSaveKey.call(key, file, sec)
      end

      def RegSetValueEx(key, value, res, type, data, size)
         RegSetValueEx.call(key, value, res, type, data, size)
      end

      def RegUnLoadKey(key, subkey)
         RegUnLoadKey.call(key, subkey)
      end
      
      # Windows XP or later
      begin
         def RegSaveKeyEx(key, file, sec, flags)
            RegSaveKeyEx.call(key, file, sec, flags)
         end
      rescue Exception
         # Do nothing - not supported on current platform
      end
   end
end
