class CreateCleanUps < ActiveRecord::Migration[8.0]
  def change
    create_table :clean_ups do |t|
      t.string :name
      t.text :description
      t.timestamps
    end
  end
end
