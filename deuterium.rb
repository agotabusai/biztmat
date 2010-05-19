class Deuterium < Sequel::Model
	many_to_one :user

	set_allowed_columns :user_id, :age, :w, :n, :s, :p

end
