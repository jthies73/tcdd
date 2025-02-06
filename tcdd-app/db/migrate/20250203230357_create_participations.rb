class CreateParticipations < ActiveRecord::Migration[8.0]
  def change
    create_table :participations do |t|
      t.string :status, null: false, default: "registered"

      t.start_time :datetime
      t.end_time :datetime

      t.integer :steps_count
      t.integer :cigarettes_count

      t.timestamps
    end

    add_reference :participations, :clean_up, null: false, foreign_key: true
  end
end
