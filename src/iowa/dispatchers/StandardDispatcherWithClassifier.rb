require 'iowa/dispatchers/StandardDispatcher'
require 'iowa/classifier'

module Iowa
	module Dispatchers
		
		# This is the same as the StandardDispatcher except that it uses a trie
		# based classifier instead of a hash for the simple matches.
		# Syntax for defining a map file is the same as the StandardDispatcher,
		# as well, except that order matters when passing the arguments to the
		# Classifier.  The change in syntax to accomodate that is just to put
		# the :map elements into an array, as an array of hashes, instead of as
		# a single hash.  For example, instead of this:
		#
		#  /: A
		#  /funds: B
		#  /funds/: C
		#  /funds/portfolio.html: D
		#
		# Do this:
		#
		#  - /: A
		#  - /funds: B
		#  - /funds/: C
		#  - /funds/portfolio.html: D
		#
		
		class StandardDispatcherWithClassifier < Iowa::Dispatchers::StandardDispatcher

			def initialize(*args)
				@mutex = Iowa::Mutex.new
				@mapfileMTime = Time.at(1)
				@next_check = Time.at(1)
				if args[0].respond_to?(:[])
					if args[0].kind_of?(::Hash)
						oargs = args[0]
						args = Iowa::Hash.new
						args.step_merge!(oargs)
					end
					args.stringify_keys! if args.respond_to? :stringify_keys!
					@mapfile = args[Cmapfile].to_s != '' ? args[Cmapfile] : nil
					@poll_interval = args['poll_interval'] ? args['poll_interval'] : 30
					@path_map = populate_classifier(args['map'] || [])
					@rewrites = RuleSet.new(args['rewrites'] || [])
					@secondary_rewrites = RuleSet.new(args['secondary_rewrites'] || [])
				else
					@mapfile = args[0]
					@poll_interval = args[1] ? args[1] : 30
					@path_map = populate_classifier(args[2] || [])
					@rewrites = RuleSet.new(args[3] || [])
					@secondary_rewrites = RuleSet.new(args[4] || [])
				end

				raise(NoMapFile, "The mapfile (#{@mapfile}) does not appear to exist.") if !FileTest.exist?(@mapfile.to_s) if @mapfile
				@mapfile ||= 'mapfile.map' if FileTest.exist?('mapfile.map')
				check_mapfile
				@mapfile
			end

			def populate_classifier(args)
				cl = Iowa::Classifier.new
				args.each do |arghash|
					next unless arghash.respond_to?(:each_pair)
					arghash.each_pair {|k,v| cl[k] = v}
				end
				cl
			end

			def load_mapfile
				raw_data = {}
				File.open(@mapfile) do |mf|
					rd = YAML::load(mf)
					break unless rd.respond_to?(:has_key?)
					raw_data = Iowa::Hash.new
					raw_data.step_merge!(rd)
					raw_data.symbolify_keys!
					rs = raw_data.has_key?(:rewrites) ? raw_data[:rewrites] : []
					@rewrites = RuleSet.new(rs)
					rs = (raw_data.respond_to?(:[]) and raw_data.has_key?(:secondary_rewrites)) ? raw_data[:secondary_rewrites] : []
					@secondary_rewrites = RuleSet.new(rs)
					@path_map = (raw_data.respond_to?(:[]) and raw_data.has_key?(:map)) ? populate_classifier(raw_data[:map]) : []
					if raw_data.respond_to?(:delete)
						raw_data.delete(:rewrites)
						raw_data.delete(:secondary_rewrites)
						raw_data.delete(:map)
					end
					raw_data.each {|k,v| @path_map[k] = v if (k.class.is_a?(String) and v.class.is_a?(String))}
					@mapfileMTime = mf.mtime
					end
			end
		end
	end	
end
