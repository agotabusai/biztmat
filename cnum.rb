class Cnum < Sequel::Model
	set_allowed_columns :x, :d, :m

	def validate
		if x.to_s.empty?
			errors.add(:x, "nem lehet üres")		
		end
		if d.to_s.empty?
			errors.add(:d, "nem lehet üres")		
		end
		if m.to_s.empty?
			errors.add(:m, "nem lehet üres")		
		end
	end
end
