class CreateParticipants < ActiveRecord::Migration[8.0]
  def change
    create_table :participants do |t|
      t.string :name
      t.integer :people_count

      t.timestamps
    end

    add_reference :participations, :participant, null: false, foreign_key: true
  end
end
