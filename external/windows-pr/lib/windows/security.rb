require 'Win32API'

module Windows
   module Security
      ACL_REVISION                   = 2
      ACL_REVISION2                  = 2
      ACL_REVISION3                  = 3
      ACL_REVISION4                  = 4
      ALLOW_ACE_LENGTH               = 62
      DACL_SECURITY_INFORMATION      = 4
      SE_DACL_PRESENT                = 4
      SECURITY_DESCRIPTOR_MIN_LENGTH = 20
      SECURITY_DESCRIPTOR_REVISION   = 1
      
      GENERIC_RIGHTS_MASK = 4026597376
      GENERIC_RIGHTS_CHK  = 4026531840
      REST_RIGHTS_MASK    = 2097151
      
      AddAce          = Win32API.new('advapi32', 'AddAce', 'PLLLL', 'I')
      CopySid         = Win32API.new('advapi32', 'CopySid', 'LLP', 'I')
      GetAce          = Win32API.new('advapi32', 'GetAce', 'LLP', 'I')
      GetFileSecurity = Win32API.new('advapi32', 'GetFileSecurity', 'PLPLP', 'I')      
      GetLengthSid    = Win32API.new('advapi32', 'GetLengthSid', 'P', 'L')  
       
      GetSecurityDescriptorControl = Win32API.new('advapi32', 'GetSecurityDescriptorControl', 'PPP', 'I')
      GetSecurityDescriptorDacl    = Win32API.new('advapi32', 'GetSecurityDescriptorDacl', 'PPPP', 'I')
      
      InitializeAcl                = Win32API.new('advapi32', 'InitializeAcl', 'PLL', 'I')
      InitializeSecurityDescriptor = Win32API.new('advapi32', 'InitializeSecurityDescriptor', 'PL', 'I')
        
      LookupAccountName = Win32API.new('advapi32', 'LookupAccountName', 'PPPPPPP', 'I')
      LookupAccountSid  = Win32API.new('advapi32', 'LookupAccountSid', 'PLPPPPP', 'I')
          
      SetFileSecurity           = Win32API.new('advapi32', 'SetFileSecurity', 'PPP', 'I') 
      SetSecurityDescriptorDacl = Win32API.new('advapi32', 'SetSecurityDescriptorDacl', 'PIPI', 'I')
      
      def AddAce(acl, rev, index, list, length)
         AddAce.call(acl, rev, index, list, length) != 0
      end
      
      def CopySid(sid_length, sid_buf, sid_source)
         CopySid.call(sid_length, sid_buf, sid_source) != 0
      end
      
      def GetAce(acl, index, ace)
         GetAce.call(acl, index, ace) != 0
      end

      def GetFileSecurity(file, info, descriptor, length, nlength)
         GetFileSecurity.call(file, info, descriptor, length, nlength) != 0
      end

      def GetLengthSid(sid)
         GetLengthSid.call(sid)
      end
      
      def GetSecurityDescriptorControl(descriptor, control, revision)
         GetSecurityDescriptorControl.call(descriptor, control, revision) != 0
      end

      def GetSecurityDescriptorDacl(descriptor, dacl_present, dacl, default)
         GetSecurityDescriptorDacl.call(descriptor, dacl_present, dacl, default) != 0
      end
      
      def InitializeAcl(acl, length, revision = ACL_REVISION)
         InitializeAcl.call(acl, length, revision) != 0
      end

      def InitializeSecurityDescriptor(descriptor, revision = SECURITY_DESCRIPTOR_REVISION)
         InitializeSecurityDescriptor.call(descriptor, revision) != 0
      end

      def LookupAccountName(sys, name, sid, sid_size, domain, domain_size, use)
         LookupAccountName.call(sys, name, sid, sid_size, domain, domain_size, use) != 0
      end

      def LookupAccountSid(sys, sid, name, name_size, domain, domain_size, use)
         LookupAccountSid.call(sys, sid, name, name_size, domain, domain_size, use) != 0
      end

      def SetFileSecurity(file, info, descriptor)
         SetFileSecurity.call(file, info, descriptor) != 0
      end

      def SetSecurityDescriptorDacl(descriptor, present, dacl, default)
         SetSecurityDescriptorDacl.call(descriptor, present, dacl, default) != 0
      end
   end
end
