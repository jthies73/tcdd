class Participation < ApplicationRecord
  belongs_to :clean_up

  validates :name, presence: true, uniqueness: true
  validates :status, inclusion: { in: %w[registered started returned], allow_nil: true }

  # Method to change status to 'registered'
  def register!
    update!(status: "registered")
  end

  # Method to change status to 'participating'
  def start!
    if clean_up.started?
      update!(status: "started")
    else
      errors.add(:base, "Clean up has not started yet")
      throw :abort
    end
  end

  # Method to change status to 'returned'
  def return!
    update!(status: "returned")
  end

  # Method to remove the status of the participation
  def reset!
    update!(status: nil)
  end
end
