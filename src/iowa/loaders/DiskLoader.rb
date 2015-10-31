# This is the default loader for IOWA applications.
# The DiskLoader loads templates from disk.
#
# A Loader is responsible for:
#   - Returning a template's contents, given a path to the template.
#   - Returning the last modification tome of a template, given a path
#     to the template.
#   - Taking a path, and determining if it is a path that the loader can handle.
#   - Returning a priority number indicating the order in which the template loader should have a chance at the path.

module Iowa
  module Loaders
    class DiskLoader

      Iowa::Loader.add_loader self

      def self.priority
        100
      end

      # Returns a list, selected from the list passed into the method,
      # of the paths that this class is willing to handle.
  
      def self.will_handle?(paths)
        paths.select {|path| FileTest.directory? path}
      end

      # Initialize the loader with the load paths.  It will check
      # each path in the array and only initialize for the ones that
      # it will handle.
  
      def initialize(paths = ['.'])
        @paths = self.class.will_handle?(paths)
      end

      def load(name)
        File.read(name)
      end

      def mtime(name)
        FileTest.exist?(name) && File.mtime(name) || nil
      end

      def handle?(name)
        FileTest.exist?(name)
      end

    end
  end
end
