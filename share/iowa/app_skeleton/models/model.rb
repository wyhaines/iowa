require 'iowa/pools/DBConnectionPool'
require 'kansas'

$public_dbconf = Iowa.config[Iowa::Capplication]['public_database']
$private_dbconf = Iowa.config[Iowa::Capplication]['private_database']
KSDatabase.new("dbi:#{$public_dbconf['vendor']}:#{$public_dbconf['database']}:#{$public_dbconf['host']}",$public_dbconf['user'],$public_dbconf['password']).map_all_tables

class KSDatabase

	class ProductUrls
		to_one(:product, :product_idx, :Products)
		to_one(:product_preview, :product_idx, :ProductsPreview)
	end

	class Products
		to_many(:product_url, :ProductUrls, :product_idx)
	end

	class ProductsPreview
		to_many(:product_url, :ProductUrls, :product_idx)
	end

end

class PubDrxDBPool < Iowa::Pool::DBConnectionPool
	StartSize $public_dbconf['startsize']
	MaxSize $public_dbconf['maxsize']
	MaxAge $public_dbconf['maxage']
	MonitorInterval $public_dbconf['monitorinterval']
	DBClass KSDatabase
	ConnectArgs ["dbi:#{$public_dbconf['vendor']}:#{$public_dbconf['database']}:#{$public_dbconf['host']}",$public_dbconf['user'],$public_dbconf['password']]

	def getConnection(&b)
		obtain {|h| b.call(h)}
	end
end

class PrivDrxDBPool < Iowa::Pool::DBConnectionPool
	StartSize $private_dbconf['startsize']
	MaxSize $private_dbconf['maxsize']
	MaxAge $private_dbconf['maxage']
	MonitorInterval $private_dbconf['monitorinterval']
	DBClass KSDatabase
	ConnectArgs ["dbi:#{$private_dbconf['vendor']}:#{$private_dbconf['database']}:#{$private_dbconf['host']}",$private_dbconf['user'],$private_dbconf['password']]

	def getConnection(&b)
		obtain {|h| b.call(h)}
	end
end
