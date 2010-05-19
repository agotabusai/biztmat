class CreateCnumsTable < Sequel::Migration
	
	def up
		create_table :cnums do
			Integer :x
			Integer :d
			Integer :m
		end
	end

	def down
		drop_table :cnums
	end
end
