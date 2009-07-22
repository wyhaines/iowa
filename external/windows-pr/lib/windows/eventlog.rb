require 'Win32API'

module Windows
   module EventLog
      EVENTLOG_SEQUENTIAL_READ = 0x0001
      EVENTLOG_SEEK_READ       = 0x0002
      EVENTLOG_FORWARDS_READ   = 0x0004
      EVENTLOG_BACKWARDS_READ  = 0x0008

      EVENTLOG_SUCCESS          = 0x0000
      EVENTLOG_ERROR_TYPE       = 0x0001
      EVENTLOG_WARNING_TYPE     = 0x0002
      EVENTLOG_INFORMATION_TYPE = 0x0004
      EVENTLOG_AUDIT_SUCCESS    = 0x0008
      EVENTLOG_AUDIT_FAILURE    = 0x0010
      
      EVENTLOG_FULL_INFO = 0

      BackupEventLog             = Win32API.new('advapi32', 'BackupEventLog', 'LP', 'I')
      BackupEventLogW            = Win32API.new('advapi32', 'BackupEventLogW', 'LP', 'I')
      ClearEventLog              = Win32API.new('advapi32', 'ClearEventLog', 'LP', 'I')
      ClearEventLogW             = Win32API.new('advapi32', 'ClearEventLogW', 'LP', 'I')
      CloseEventLog              = Win32API.new('advapi32', 'CloseEventLog', 'L', 'I')
      DeregisterEventSource      = Win32API.new('advapi32', 'DeregisterEventSource', 'L', 'I')
      GetEventLogInformation     = Win32API.new('advapi32', 'GetEventLogInformation', 'LLPLP', 'I')
      GetNumberOfEventLogRecords = Win32API.new('advapi32', 'GetNumberOfEventLogRecords', 'LP', 'I')
      GetOldestEventLogRecord    = Win32API.new('advapi32', 'GetOldestEventLogRecord', 'LP', 'I')
      NotifyChangeEventLog       = Win32API.new('advapi32', 'NotifyChangeEventLog', 'LL', 'I')
      OpenBackupEventLog         = Win32API.new('advapi32', 'OpenBackupEventLog', 'PP', 'L')
      OpenBackupEventLogW        = Win32API.new('advapi32', 'OpenBackupEventLogW', 'PP', 'L')
      OpenEventLog               = Win32API.new('advapi32', 'OpenEventLog', 'PP', 'L')
      OpenEventLogW              = Win32API.new('advapi32', 'OpenEventLogW', 'PP', 'L')
      ReadEventLog               = Win32API.new('advapi32', 'ReadEventLog', 'LLLPLPP', 'I')
      ReadEventLogW              = Win32API.new('advapi32', 'ReadEventLogW', 'LLLPLPP', 'I')
      RegisterEventSource        = Win32API.new('advapi32', 'RegisterEventSource', 'PP', 'L')
      RegisterEventSourceW       = Win32API.new('advapi32', 'RegisterEventSourceW', 'PP', 'L')
      ReportEvent                = Win32API.new('advapi32', 'ReportEvent', 'LIILPILPP', 'I')
      ReportEventW               = Win32API.new('advapi32', 'ReportEventW', 'LIILPILPP', 'I')

      def BackupEventLog(handle, file)
         BackupEventLog.call(handle, file) != 0
      end

      def BackupEventLogW(handle, file)
         BackupEventLogW.call(handle, file) != 0
      end

      def ClearEventLog(handle, file = 0)
         ClearEventLog.call(handle, file) != 0
      end

      def ClearEventLogW(handle, file = 0)
         ClearEventLogW.call(handle, file) != 0
      end

      def CloseEventLog(handle)
         CloseEventLog.call(handle) != 0
      end

      def DeregisterEventSource(handle)
         DeregisterEventSource.call(handle) != 0
      end

      def GetEventLogInformation(handle, level, buf, buf_size, bytes)
         GetEventLogInformation.call(handle, level, buf, buf_size, bytes) != 0
      end

      def GetNumberOfEventLogRecords(handle, num)
         GetNumberOfEventLogRecords.call(handle, num) != 0
      end
      
      def GetOldestEventLogRecord(handle, rec)
         GetOldestEventLogRecord.call(handle, rec) != 0
      end

      def NotifyChangeEventLog(handle, event)
         NotifyChangeEventLog.call(handle, event) != 0
      end

      def OpenBackupEventLog(server, file)
         OpenBackupEventLog.call(server, file)
      end

      def OpenBackupEventLogW(server, file)
         OpenBackupEventLogW.call(server, file)
      end

      def OpenEventLog(server, source)
         OpenEventLog.call(server, source)
      end

      def OpenEventLogW(server, source)
         OpenEventLogW.call(server, source)
      end

      def ReadEventLog(handle, flags, offset, buf, bytes, bytes_read, min_bytes)
         ReadEventLog.call(handle, flags, offset, buf, bytes, bytes_read, min_bytes) != 0
      end

      def ReadEventLogW(handle, flags, offset, buf, bytes, bytes_read, min_bytes)
         ReadEventLogW.call(handle, flags, offset, buf, bytes, bytes_read, min_bytes) != 0
      end

      def RegisterEventSource(server, source)
         RegisterEventSource.call(server, source)
      end

      def RegisterEventSourceW(server, source)
         RegisterEventSourceW.call(server, source)
      end

      def ReportEvent(handle, type, cat, id, sid, num, size, strings, raw)
         ReportEvent.call(handle, type, cat, id, sid, num, size, strings, raw) != 0
      end

      def ReportEventW(handle, type, cat, id, sid, num, size, strings, raw)
         ReportEventW.call(handle, type, cat, id, sid, num, size, strings, raw) != 0
      end
   end
end
