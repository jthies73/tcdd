class AddFinalParticipantCountToCleanUps < ActiveRecord::Migration[8.0]
  def change
    add_column :clean_ups, :final_participant_count, :integer
  end
end
