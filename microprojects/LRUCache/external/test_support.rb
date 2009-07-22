module IWATestSupport

	def self.cd_to_test_dir(dir)
		Dir.chdir(File.dirname(File.expand_path(dir)))
	end

end

