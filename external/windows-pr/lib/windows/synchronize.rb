#######################################################################
# synchronize.rb
#
# Defines the following functions:
#
# CreateEvent()
# CreateMutex()
# CreateSemaphore()
# MsgWaitForMultipleObjects()
# MsgWaitForMultipleObjectsEx()
# OpenEvent()
# OpenMutex()
# OpenSemaphore()
# WaitForDebugEvent()
# WaitForSingleObject()
# WaitForSingleObjectEx()
# WaitForMultipleObjects()
# WaitForMultipleObjectsEx()
#
# Defines the the following constants:
#
# WAIT_ABANDONED
# WAIT_OBJECT_0
# WAIT_TIMEOUT
# WAIT_FAILED
# INFINITE
#
# TODO:
#
# Add the rest of the synchronization functions.
#######################################################################
require 'Win32API'

module Windows
   module Synchronize
      INFINITE       = 0xFFFFFFFF
      WAIT_OBJECT_0  = 0
      WAIT_TIMEOUT   = 0x102
      WAIT_ABANDONED = 128
      WAIT_FAILED    = 0xFFFFFFFF
      
      # Wake mask constants
      QS_ALLEVENTS      = 0x04BF
      QS_ALLINPUT       = 0x04FF
      QS_ALLPOSTMESSAGE = 0x0100
      QS_HOTKEY         = 0x0080
      QS_INPUT          = 0x407
      QS_KEY            = 0x0001
      QS_MOUSE          = 0x0006
      QS_MOUSEBUTTON    = 0x0004
      QS_MOUSEMOVE      = 0x0002
      QS_PAINT          = 0x0020
      QS_POSTMESSAGE    = 0x0008
      QS_RAWINPUT       = 0x0400
      QS_SENDMESSAGE    = 0x0040
      QS_TIMER          = 0x0010
      
      # Wait type constants
      MWMO_ALERTABLE      = 0x0002
      MWMO_INPUTAVAILABLE = 0x0004
      MWMO_WAITALL        = 0x0001
      
      # Access rights
      EVENT_ALL_ACCESS       = 0x1F0003
      EVENT_MODIFY_STATE     = 0x0002
      MUTEX_ALL_ACCESS       = 0x1F0001
      MUTEX_MODIFY_STATE     = 0x0001
      SEMAPHORE_ALL_ACCESS   = 0x1F0003
      SEMAPHORE_MODIFY_STATE = 0x0002

      CreateEvent     = Win32API.new('kernel32', 'CreateEvent', 'PIIP', 'L')
      CreateMutex     = Win32API.new('kernel32', 'CreateMutex', 'PIP', 'L')
      CreateSemaphore = Win32API.new('kernel32', 'CreateSemaphore', 'PLLP', 'L')

      GetOverlappedResult = Win32API.new('kernel32', 'GetOverlappedResult', 'LPPI', 'I')
      
      MsgWaitForMultipleObjects   = Win32API.new('user32', 'MsgWaitForMultipleObjects', 'LPILL', 'L')
      MsgWaitForMultipleObjectsEx = Win32API.new('user32', 'MsgWaitForMultipleObjectsEx', 'LPLLL', 'L')

      OpenEvent        = Win32API.new('kernel32', 'OpenEvent', 'LIP', 'L')
      OpenMutex        = Win32API.new('kernel32', 'OpenMutex', 'LIP', 'L')
      OpenSemaphore    = Win32API.new('kernel32', 'OpenSemaphore', 'LIP', 'L')
      ReleaseMutex     = Win32API.new('kernel32', 'ReleaseMutex', 'L', 'I')
      ReleaseSemaphore = Win32API.new('kernel32', 'ReleaseSemaphore', 'LLP', 'I')
      ResetEvent       = Win32API.new('kernel32', 'ResetEvent', 'L', 'I')
      SetEvent         = Win32API.new('kernel32', 'SetEvent', 'L', 'I')

      WaitForMultipleObjects   = Win32API.new('kernel32', 'WaitForMultipleObjects', 'LPIL', 'L')
      WaitForMultipleObjectsEx = Win32API.new('kernel32', 'WaitForMultipleObjectsEx', 'LPILI', 'L')
      WaitForSingleObject      = Win32API.new('kernel32', 'WaitForSingleObject', 'LL', 'L')
      WaitForSingleObjectEx    = Win32API.new('kernel32', 'WaitForSingleObjectEx', 'LLI', 'L')
      
      def CreateEvent(attributes, reset, state, name)
         CreateEvent.call(attributes, reset, state, name)
      end
      
      def CreateMutex(attributes, owner, name)
         CreateMutex.call(attributes, owner, name)
      end
      
      def CreateSemaphore(attributes, initial, max, name)
         CreateSemaphore.call(attributes, initial, max, name)
      end
      
      def GetOverlappedResult(handle, overlapped, bytes_transferred, wait)
         GetOverlappedResult.call(handle, overlapped, bytes_transferred, wait)
      end
      
      def MsgWaitForMultipleObjects(count, handles, wait, milli, mask)
         MsgWaitForMultipleObjects.call(count, handles, wait, milli, mask)
      end
      
      def MsgWaitForMultipleObjectsEx(count, handles, milli, mask, flags)
         MsgWaitForMultipleObjectsEx.call(count, handles, milli, mask, flags)
      end
      
      def OpenSemaphore(access, handle, name)
         OpenSemaphore.call(access, handle, name)
      end
      
      def OpenMutex(access, handle, name)
         OpenMutex.call(access, handle, name)
      end
      
      def OpenEvent(access, handle, name)
         OpenEvent.call(access, handle, name)
      end
      
      def ReleaseMutex(handle)
         ReleaseMutex.call(handle) != 0
      end
      
      def ReleaseSemaphore(handle, release_count, previous_count)
         ReleaseSemaphore.call(handle, release_count, previous_count) != 0
      end
      
      def ResetEvent(handle)
         ResetEvent.call(handle) != 0
      end
      
      def SetEvent(handle)
         SetEvent.call(handle) != 0
      end
      
      def WaitForMultipleObjects(count, handles, wait_all, milliseconds)
         WaitForMultipleObjects.call(count, handles, wait_all, milliseconds)
      end
      
      def WaitForMultipleObjectsEx(count, handles, wait_all, milliseconds, alertable)
         WaitForMultipleObjectsEx.call(count, handles, wait_all, milliseconds, alertable)
      end
      
      def WaitForSingleObject(handle, milliseconds)
         WaitForSingleObject.call(handle, milliseconds)
      end
      
      def WaitForSingleObjectEx(handle, milliseconds, alertable)
         WaitForSingleObject.call(handle, milliseconds, alertable)
      end
   end
end
