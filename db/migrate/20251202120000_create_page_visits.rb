class CreatePageVisits < ActiveRecord::Migration[7.0]
  def change
    create_table :page_visits do |t|
      t.date :visited_on, null: false
      t.integer :count, default: 0, null: false
      t.timestamps
    end
    add_index :page_visits, :visited_on, unique: true
  end
end
