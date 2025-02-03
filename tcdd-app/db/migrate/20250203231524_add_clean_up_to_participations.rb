class AddCleanUpToParticipations < ActiveRecord::Migration[8.0]
  def change
    add_reference :participations, :clean_up, null: false, foreign_key: true
  end
end
