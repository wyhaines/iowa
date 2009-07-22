require 'iowa/Pool'

module Iowa
	class Pool
		class DBConnectionPool < Iowa::Pool

			def self.DBClass(val = nil)
				if (val or !@dbclass)
					if val
						@dbclass = val
					else
						require 'dbi'
						@dbclass = DBI
					end
					DBNewMethodName()
				end
				@dbclass
			end
			def self.db_class(val = nil); DBClass(val); end

			def self.DBNewMethodName(val = nil)
				@db_new_method_name ||= nil
				if (val or !@db_new_method_name)
					if val
						@db_new_method_name = val
					else
						@db_new_method_name = @dbclass == DBI ? :connect : :new
					end
				else
					@db_new_method_name
				end
			end
			def self.db_new_method_name(val = nil); DBNewMethodName(val = nil); end

			def self.ConnectArgs(val = nil)
				(val or !@connect_args) ? (@connect_args = val) : @connect_args
			end
			def self.connect_args(val = nil); ConnectArgs(val); end

			def initialize(params = {})
				@connect_args = params[:connect_args] || self.class.ConnectArgs
				@dbclass = params[:dbclass] || self.class.DBClass
				@db_new_method_name = params[:db_new_method_name] || self.class.DBNewMethodName
				super
			end

			def newobj
				@dbclass.__send__(@db_new_method_name,*@connect_args)
			end
		end
	end
end

