require 'Win32API'

module Windows
   module Path
      # These constants are for use by the PathGetCharType() function.
      GCT_INVALID   = 0x0000   # The character is not valid in a path.
      GCT_LFNCHAR   = 0x0001   # The character is valid in a long file name.
      GCT_SHORTCHAR = 0x0002   # The character is valid in a short (8.3) file name.
      GCT_WILD      = 0x0004   # The character is a wildcard character.
      GCT_SEPARATOR = 0x0008   # The character is a path separator.

      PathAddBackslash  = Win32API.new('shlwapi', 'PathAddBackslash', 'P', 'P')
      PathAddExtension  = Win32API.new('shlwapi', 'PathAddExtension', 'PP', 'I')
      PathAppend        = Win32API.new('shlwapi', 'PathAppend', 'PP', 'I')
      PathBuildRoot     = Win32API.new('shlwapi', 'PathBuildRoot', 'PI', 'P')
      PathCanonicalize  = Win32API.new('shlwapi', 'PathCanonicalize', 'PP', 'I')
      PathCombine       = Win32API.new('shlwapi', 'PathCombine', 'PPP', 'P')
      PathCommonPrefix  = Win32API.new('shlwapi', 'PathCommonPrefix', 'PPP', 'I')
      PathCompactPath   = Win32API.new('shlwapi', 'PathCompactPath', 'PPI', 'I')
      PathCompactPathEx = Win32API.new('shlwapi', 'PathCompactPathEx', 'PPIL', 'I')
      PathCreateFromUrl = Win32API.new('shlwapi', 'PathCreateFromUrl', 'PPPL', 'L')      
      PathFileExists    = Win32API.new('shlwapi', 'PathFileExists', 'P', 'I')
      PathFindExtension = Win32API.new('shlwapi', 'PathFindExtension', 'P', 'P')
      PathFindFileName  = Win32API.new('shlwapi', 'PathFindFileName', 'P', 'P') 

      PathFindNextComponent  = Win32API.new('shlwapi', 'PathFindNextComponent', 'P', 'P')
      PathFindOnPath         = Win32API.new('shlwapi', 'PathFindOnPath', 'PP', 'I')
      PathFindSuffixArray    = Win32API.new('shlwapi', 'PathFindSuffixArray', 'PPI', 'P')
      PathGetArgs            = Win32API.new('shlwapi', 'PathGetArgs', 'P', 'P')
      PathGetCharType        = Win32API.new('shlwapi', 'PathGetCharType', 'P', 'I')
      PathGetDriveNumber     = Win32API.new('shlwapi', 'PathGetDriveNumber', 'P', 'I')
      PathIsContentType      = Win32API.new('shlwapi', 'PathIsContentType', 'PP', 'I')
      PathIsDirectory        = Win32API.new('shlwapi', 'PathIsDirectory', 'P', 'I')
      PathIsDirectoryEmpty   = Win32API.new('shlwapi', 'PathIsDirectoryEmpty', 'P', 'I')
      PathIsFileSpec         = Win32API.new('shlwapi', 'PathIsFileSpec', 'P', 'I')
      #PathIsHTMLFile        = Win32API.new('shlwapi', 'PathIsHTMLFile', 'P', 'I')
      PathIsLFNFileSpec      = Win32API.new('shlwapi', 'PathIsLFNFileSpec', 'P', 'I')
      PathIsNetworkPath      = Win32API.new('shlwapi', 'PathIsNetworkPath', 'P', 'I')
      PathIsPrefix           = Win32API.new('shlwapi', 'PathIsPrefix', 'PP', 'I')
      PathIsRelative         = Win32API.new('shlwapi', 'PathIsRelative', 'P', 'I')
      PathIsRoot             = Win32API.new('shlwapi', 'PathIsRoot', 'P', 'I')
      PathIsSameRoot         = Win32API.new('shlwapi', 'PathIsSameRoot', 'PP', 'I')
      PathIsSystemFolder     = Win32API.new('shlwapi', 'PathIsSystemFolder', 'PL', 'I')
      PathIsUNC              = Win32API.new('shlwapi', 'PathIsUNC', 'P', 'I')
      PathIsUNCServer        = Win32API.new('shlwapi', 'PathIsUNCServer', 'P', 'I')  
      PathIsUNCServerShare   = Win32API.new('shlwapi', 'PathIsUNCServerShare','P','I')     
      PathIsURL              = Win32API.new('shlwapi', 'PathIsURL', 'P', 'I')
      PathMakePretty         = Win32API.new('shlwapi', 'PathMakePretty', 'P', 'I')  
      PathMakeSystemFolder   = Win32API.new('shlwapi', 'PathMakeSystemFolder', 'P', 'I')      
      PathMatchSpec          = Win32API.new('shlwapi', 'PathMatchSpec', 'PP', 'I')
      PathParseIconLocation  = Win32API.new('shlwapi', 'PathParseIconLocation', 'P', 'I')
      PathQuoteSpaces        = Win32API.new('shlwapi', 'PathQuoteSpaces', 'P', 'V')
      PathRelativePathTo     = Win32API.new('shlwapi', 'PathRelativePathTo', 'PPLPL', 'I')
      PathRemoveArgs         = Win32API.new('shlwapi', 'PathRemoveArgs', 'P', 'V')
      PathRemoveBackslash    = Win32API.new('shlwapi', 'PathRemoveBackslash', 'P', 'P')
      PathRemoveBlanks       = Win32API.new('shlwapi', 'PathRemoveBlanks', 'P', 'V')
      PathRemoveExtension    = Win32API.new('shlwapi', 'PathRemoveExtension', 'P','V')
      PathRemoveFileSpec     = Win32API.new('shlwapi', 'PathRemoveFileSpec', 'P', 'L')
      PathRenameExtension    = Win32API.new('shlwapi', 'PathRenameExtension', 'PP','I')
      PathSearchAndQualify   = Win32API.new('shlwapi', 'PathSearchAndQualify', 'PPI', 'I')
      PathSetDlgItemPath     = Win32API.new('shlwapi', 'PathSetDlgItemPath', 'LIP', 'V')
      PathSkipRoot           = Win32API.new('shlwapi', 'PathSkipRoot', 'P', 'P')
      PathStripPath          = Win32API.new('shlwapi', 'PathStripPath', 'P', 'V')
      PathStripToRoot        = Win32API.new('shlwapi', 'PathStripToRoot', 'P', 'I')
      PathUndecorate         = Win32API.new('shlwapi', 'PathUndecorate', 'P', 'V')
      PathUnExpandEnvStrings = Win32API.new('shlwapi', 'PathUnExpandEnvStrings', 'PPI', 'I')
      PathUnmakeSystemFolder = Win32API.new('shlwapi', 'PathUnmakeSystemFolder', 'P', 'I')
      PathUnquoteSpaces      = Win32API.new('shlwapi', 'PathUnquoteSpaces', 'P', 'V')

      def PathAddBackslash(path)
         PathAddBackslash.call(path)
      end

      def PathAddExtension(path, ext)
         PathAddExtension.call(path, ext) > 0
      end

      def PathAppend(path, more)
         PathAppend.call(path, more) > 0
      end

      def PathBuildRoot(root, drive)
         PathBuildRoot.call(root, drive)
      end

      def PathCanonicalize(dst, src)
         PathCanonicalize.call(dst, src) > 0
      end

      def PathCombine(dest, dir, file)
         PathCombine.call(dest, dir, file)
      end

      def PathCommonPrefix(path1, path2, buf)
         PathCommonPrefix.call(path1, path2, buf)
      end

      def PathCompactPath(handle, path, px_width)
         PathCompactPath.call(handle, path, px_width) > 0
      end

      def PathCompactPathEx(out, src, max, flags = nil)
         PathCompactPathEx.call(out, src, max, flags) > 0
      end

      def PathCreateFromUrl(url, path, path_size, reserved = nil)
         PathCreateFromUrl.call(url, path, path_size, reserved) >= 0
      end

      def PathFileExists(path)
         PathFileExists.call(path) > 0
      end

      def PathFindExtension(path)
         PathFindExtension.call(path)
      end

      def PathFindFileName(path)
         PathFindFileName.call(path)
      end

      def PathFindNextComponent(path)
         PathFindNextComponent.call(path)
      end

      def PathFindOnPath(file, dirs)
         PathFindOnPath.call(file, dirs)
      end

      def PathFindSuffixArray(path, suffix_array, suffix_size)
         PathFindSuffixArray.call(path, suffix_array, suffix_size)
      end

      def PathGetArgs(path)
         PathGetArgs.call(path)
      end

      def PathGetCharType(char)
         PathGetCharType.call(char)
      end

      def PathGetDriveNumber(path)
         PathGetDriveNumber.call(path)
      end

      def PathIsContentType(path, content_type)
         PathIsContentType.call(path, content_type) > 0
      end

      def PathIsDirectory(path)
         PathIsDirectory.call(path) > 0
      end

      def PathIsDirectoryEmpty(path)
         PathIsDirectoryEmpty.call(path) > 0
      end

      def PathIsFileSpec(path)
         PathIsFileSpec.call(path) > 0
      end

      # This appears to be broken with the current MSVC distro.  Use
      # PathIsContentType instead.
      #def PathIsHTMLFile(path)
      #   PathIsHTMLFile.call(path)
      #end

      def PathIsLFNFileSpec(path)
         PathIsLFNFileSpec.call(path) > 0
      end

      def PathIsNetworkPath(path)
         PathIsNetworkPath.call(path) > 0
      end

      def PathIsPrefix(prefix, path)
         PathIsPrefix.call(prefix, path) > 0
      end

      def PathIsRelative(path)
         PathIsRelative.call(path) > 0
      end

      def PathIsRoot(path)
         PathIsRoot.call(path) > 0
      end

      def PathIsSameRoot(path1, path2)
         PathIsSameRoot.call(path1, path2) > 0
      end

      def PathIsSystemFolder(path)
         PathIsSystemFolder.call(path) > 0
      end

      def PathIsUNC(path)
         PathIsUNC.call(path) > 0
      end

      def PathIsUNCServer(path)
         PathIsUNCServer.call(path) > 0
      end

      def PathIsUNCServerShare(path)
         PathIsUNCServerShare.call(path) > 0
      end

      def PathIsURL(path)
         PathIsURL.call(path) > 0
      end

      def PathMakePretty(path)
         PathMakePretty.call(path) > 0
      end

      def PathMakeSystemFolder(path)
         PathMakeSystemFolder.call(path) > 0
      end

      def PathMatchSpec(path, spec)
         PathMatchSpec.call(path, spec) > 0
      end

      def PathParseIconLocation(path)
         PathParseIconLocation.call(path)
      end

      def PathQuoteSpaces(path)
         PathQuoteSpaces.call(path)
      end

      def PathRelativePathTo(path, from, from_attr, to, to_attr)
         PathRelativePathTo.call(path, from, from_attr, to, to_attr) > 0
      end

      def PathRemoveArgs(path)
         PathRemoveArgs.call(path)
      end

      def PathRemoveBackslash(path)
         PathRemoveBackslash.call(path)
      end

      def PathRemoveBlanks(path)
         PathRemoveBlanks.call(path)
      end

      def PathRemoveExtension(path)
         PathRemoveExtension.call(path)
      end

      def PathRemoveFileSpec(path)
         PathRemoveFileSpec.call(path) > 0
      end

      def PathRenameExtension(path, ext)
         PathRenameExtension.call(path, ext) > 0
      end
      
      def PathSearchAndQualify(path, full_path, full_path_size)
         PathSearchAndQualify.call(path, full_path, full_path_size) > 0
      end
      
      def PathSetDlgItemPath(handle, id, path)
         PathSetDlgItemPath.call(handle, id, path)
      end
      
      def PathSkipRoot(path)
         PathSkipRoot.call(path)
      end
      
      def PathStripPath(path)
         PathStripPath.call(path)
      end
      
      def PathStripToRoot(path)
         PathStripToRoot.call(path) > 0
      end
      
      def PathUndecorate(path)
         PathUndecorate.call(path)
      end
      
      def PathUnExpandEnvStrings(path, buf, buf_size)
         PathUnExpandEnvStrings.call(path, buf, buf_size) > 0
      end
      
      def PathUnmakeSystemFolder(path)
         PathUnmakeSystemFolder.call(path) > 0
      end 
      
      def PathUnquoteSpaces(path)
         PathUnquoteSpaces.call(path)
      end
   end
end
