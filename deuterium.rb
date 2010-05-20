class Deuterium < Sequel::Model
	many_to_one :user

	set_allowed_columns :user_id, :age, :w, :n, :s, :p
=begin
	def validate
		if n.to_s.empty?
			errors.add(:n, "nem lehet üres")		
		end
		if s.empty?
			errors.add(:s, "nem lehet üres")
		end
	end
=end
end
