class CreateHubs < ActiveRecord::Migration[5.1]
  def change
    create_table :hubs do |t|
      t.integer :number
      t.string :name
      t.string :worked_type

      t.timestamps
    end
  end
end
