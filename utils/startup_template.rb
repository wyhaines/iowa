#!/usr/local/bin/ruby

require 'iowa'
#require 'iowa_webrick' # Uncomment this line and comment the one above to use Iowa + WEBrick.
#require 'iowa/DbPool'
#require 'kansas' # Uncomment this to use the Kansas ORM.  Feel free to use another ORM (ie Og, ActiveRecord) if you prefer.

class MyAppSession < Iowa::Session
	#####
	#
	# Here is where you override any Session details that you may
	# wish to customize.  Most of the time, you need not do anything.
	# In those cases, you don't even need to bother creating a subclass.
	#
	#####
end

class MyApp < Iowa::Application

	#####
	#
	# Here is where you override Application details.  You may not be
	# doing any of this, either, in which case you need not subclass,
	# but for most applications, you will want to customize a few things.
	#
	#####
	
	# attr_accessor :dbpool # If you are using a dbpool, uncomment.

	def initialize(*args)
		super # Before anything, get superclass's initialization.

		#####
		# Iowa.config provides access to the configuration of the application.
		# Use it!  Use the config to provide information rather than coding it
		# directly into your application.
		#####

		#####
		# If using a database with a db connection pool and Kansas, you might
		# do something like the following:
		#####
		#
		#dbconf = Iowa.config[Iowa::Capplication][Iowa::Cdatabase]
		#
		#  * this is ugly and could be streamlined!
		#@dbpool = Iowa::DbPool.new(dbconf['vendor'],dbconf['host'],dbconf['database'],dbconf['user'],dbconf['password'],dbconf['connections'],dbconf['monitor_interval']) do |dbh|
		#	ksdbh = KSDatabase.new(dbh)
		#	unless self.class.const_defined?(:KS_DONE_INIT)
		#		self.class.const_set(:KS_DONE_INIT,true)
		#		ksdbh.map_all_tables
		#		KSDatabase::ProductUrls.to_one(:product, :product_idx, :Products)
		#		KSDatabase::ProductUrls.to_one(:product_preview, :product_idx, :ProductsPreview)
		#	end
		#	ksdbh
		#end
	end

end

#####
#
# The last step is to start the event loop for the application.
# If the configuration file is named with the same base name as this file,
# but with a .cnf suffix, IOWA will find it and load it automatically.
# So that needs to be done is to call the run() method on Iowa.
# The run() method takes a couple optional arguments.  As shown below,
# one can toggle whether it automatically daemonizes the IOWA application,
# or not.
#
#####

Iowa.run({:daemonize => false})
