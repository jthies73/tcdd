class CreateParticipations < ActiveRecord::Migration[8.0]
  def change
    create_table :participations do |t|
      t.string :status, null: false, default: "registered"

      t.datetime :started_at
      t.datetime :returned_at

      t.integer :steps_count
      t.integer :cigarettes_count

      t.timestamps
    end

    add_reference :participations, :clean_up, null: false, foreign_key: true
  end
end
