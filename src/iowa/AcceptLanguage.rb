require 'iowa/caches/LRUCache'
require 'iowa/Constants'

module Iowa
	class AcceptLanguage

		attr_accessor :default

		QFRXP = /\s*;\s*/

		def initialize(default = Cen)
			@slf = {default => {}}
			@default = default
			@al_cache = Iowa::Caches::LRUCache.new({:maxsize => 100})
		end

		def []=(k,v)
			language,dialect = k.split(C_dash,2)
			if @slf.has_key?(language)
				@slf[language][dialect] = v
			else
				@slf[language] = {dialect => v}
			end
		end

		def [](v)
			language,dialect = v.split(C_dash,2)
			@slf.has_key?(language) ? @slf[language][dialect] : nil
		end

		def generate_language_sequence(alstring)
			seq = []
			alstring.split(C_comma).each do |spec|
				language,qf = spec.split(QFRXP)
				qf = qf.sub(/q=/,C_empty) if qf
				qf = C_1_0 unless qf.to_s != C_empty
				seq << [language,qf.to_f]
			end
			seq.sort_by {|a| a[1]}.reverse
		end

		def match(alstring)
			return @al_cache[alstring] if @al_cache.include?(alstring)
			r = nil
			seq = generate_language_sequence(alstring)
			seq.each do |litem|
				language,dialect = litem.first.split(C_dash)
				break if @slf[language] and r = @slf[language][dialect]
			end
			r ||= @slf[Cen][nil]
			@al_cache[alstring] = r
			r
		end

		def languages
			r = []
			@slf.each do |language,dlcts|
				dlcts.each_key do |dialect|
					r << (dialect ? "#{language}-#{dialect}" : language)
				end
			end
			r
		end
			
		def dialects(language)
			r = []
			if @slf.has_key?(language)
				@slf[language].each_key do |dialect|
					r << dialect ? "#{language}-#{dialect}" : language
				end
			end
			r
		end

	end
end
