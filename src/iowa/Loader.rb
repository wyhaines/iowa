# This is the master loader.  It creates instances of each of the loaders
# that the application will use.  The application uses this class to load
# template data; it does not use the various loaders directly.  The logic
# is to search the Ruby search path for iowa/loaders/* files, and to look
# in the IOWA paths for /loaders/*.  It will require anything that it
# finds, in the order that they are found.  Each loader will register itself
# with the master loader.
#

module Iowa

	class Loader

		LOADERS = []
		
		def self.add_loader(loader)
			LOADERS.push loader
		end
		
	end

end
