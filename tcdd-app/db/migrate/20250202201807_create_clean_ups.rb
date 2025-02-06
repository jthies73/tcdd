class CreateCleanUps < ActiveRecord::Migration[8.0]
  def change
    create_table :clean_ups do |t|
      t.string :name, null: false
      t.text :description
      t.string :status, null: false, default: "created"
      t.datetime :datetime
      t.string :address # stores the friendly address of the location
      t.string :location # stores the coordinates of the location

      t.timestamps
    end
  end
end
