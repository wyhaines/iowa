##############################################################################
# sound.rb
#
# Includes the following functions:
#
# Beep()
# PlaySound()
# WaveOutSetVolume()
# WaveOutGetVolume()
#
# Defines the following constants:
# 
# SND_APPLICATION
# SND_ALIAS
# SND_ALIAS_ID
# SND_ASYNC
# SND_FILENAME
# SND_LOOP
# SND_MEMORY
# SND_NODEFAULT
# SND_NOSTOP
# SND_NOWAIT
# SND_PURGE
# SND_RESOURCE
# SND_SYNC
##############################################################################
require 'Win32API'

module Windows  
   module Sound
      SND_SYNC          = 0x0000  # play synchronously (default)
      SND_ASYNC         = 0x0001  # play asynchronously
      SND_NODEFAULT     = 0x0002  # silence (!default) if sound not found
      SND_MEMORY        = 0x0004  # pszSound points to a memory file
      SND_LOOP          = 0x0008  # loop the sound until next sndPlaySound
      SND_NOSTOP        = 0x0010  # don't stop any currently playing sound 

      SND_NOWAIT        = 8192    # don't wait if the driver is busy
      SND_ALIAS         = 65536   # name is a registry alias
      SND_ALIAS_ID      = 1114112 # alias is a predefined ID
      SND_FILENAME      = 131072  # name is file name
      SND_RESOURCE      = 262148  # name is resource name or atom

      SND_PURGE         = 0x0040  # purge non-static events for task
      SND_APPLICATION   = 0x0080  # look for application specific association
      
      Beep             = Win32API.new('kernel32', 'Beep', 'LL', 'I')
      PlaySound        = Win32API.new('winmm', 'PlaySound', 'PPL', 'I')
      WaveOutSetVolume = Win32API.new('winmm', 'waveOutSetVolume', 'PL', 'I')
      WaveOutGetVolume = Win32API.new('winmm', 'waveOutGetVolume', 'IP', 'I')
   end
end
