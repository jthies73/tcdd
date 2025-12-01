class AddLastManualCigarettesAmountToCleanUps < ActiveRecord::Migration[8.0]
  def change
    add_column :clean_ups, :last_manual_cigarettes_amount, :integer, default: 0, null: false
  end
end
