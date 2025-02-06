class AddStatusToCleanUpsAndCreateParticipationLogs < ActiveRecord::Migration[8.0]
  def change
    add_column :clean_ups, :status, :string

    create_table :participation_logs do |t|
      t.references :participation, null: false, foreign_key: true
      t.string :status

      t.timestamps
    end
  end
end
