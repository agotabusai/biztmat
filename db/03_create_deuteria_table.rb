class CreateDeuteriaTable < Sequel::Migration
	def up
		create_table :deuteria do
			primary_key :id
			Integer :user_id
			Integer :age
			String :w
			Integer :n
			Integer :s
			Integer :p
		end
	end

	def down
		drop_table :deuteria
	end
end
			
			
