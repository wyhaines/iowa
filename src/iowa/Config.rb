require 'yaml'

require 'iowa/Constants'
require 'iowa/Hash'

module Iowa
	@config = Hash.new{|h,k| h[k] = Hash.new {|h2,k2| h2[k2] = {}}}
	def Iowa.version; '0.99.3.5'; end
	def Iowa.readConfiguration(configuration_file)
		begin
			File.open(configuration_file) do |cf|
				@config.step_merge! YAML::load(cf)
			end
		rescue Errno::ENOENT
		rescue Exception => exception
			puts "Failure while accessing the configuration file (#{configuration_file})\n"
			raise
		end
		checkConfiguration
	end
end
