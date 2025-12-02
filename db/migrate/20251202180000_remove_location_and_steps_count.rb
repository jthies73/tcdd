class RemoveLocationAndStepsCount < ActiveRecord::Migration[7.1]
  def change
    remove_column :clean_ups, :location, :string
    remove_column :participations, :steps_count, :integer
  end
end
