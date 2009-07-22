module IowaComponentMixins

	def import(name)
		Iowa.app.import(name,self.name)
	end

end
