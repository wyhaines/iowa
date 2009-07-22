#!/usr/local/ruby184/bin/ruby

require 'iowa'
require 'kansas'

Cdirexion_id = 'direxion_id'.freeze
C_index_html = '/index.html'.freeze

module Iowa
	def self.noztime(t)
		m = t.month
		d = t.day
		y = t.year
		"#{m}/#{d}/#{y}"
	end

	class Component
		def with_db(side)
			application.dbpool[side].obtain do |db|
				yield db
			end
		end
	end
end

class DrxSession < Iowa::Session; end

class DrxApplication < Iowa::Application

	self.Daemonize = true

	attr_accessor :dbpool, :direxion_id_cache, :internal_content

	def initialize(*args)
		super
		
		@internal_content = Hash.new {|h,k| h[k] = {:query => Proc.new {}, :retrieve => Proc.new {}}}

		@dbpool = {}
		@dbpool[:pub] = ::PubDrxDBPool.new
		self.class.Dispatcher.dbpool[:pub] = @dbpool[:pub]
		@dbpool[:priv] = ::PrivDrxDBPool.new
		self.class.Dispatcher.dbpool[:priv] = @dbpool[:priv]
		@direxion_id_cache = Iowa::Caches::LRUCache.new(
			{:maxsize => (Iowa.config[Iowa::Capplication]['advisorcache']['maxsize'] || 200),
			:ttl => Iowa.config[Iowa::Capplication]['advisorcache']['ttl']})
		@direxion_id_cache.add_finalizer do |key,obj|
			Iowa.app.dbpool[:priv].obtain do |ksdbh|
				auth = ksdbh.select(:Authorization) {|a| a.idx == key}.first
				auth.delete if auth
			end
		end
		Iowa.config[Iowa::Capplication][Iowa::Croot_url] = 'http://direxion.enigo.com'
	end

end

Iowa.run
