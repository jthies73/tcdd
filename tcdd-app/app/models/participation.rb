class Participation < ApplicationRecord
  belongs_to :clean_up

  validates :name, presence: true, uniqueness: true
  validates :status, inclusion: { in: %w[registered started returned] }

  # Method to change status to 'registered'
  def register!
    update!(status: "registered")
  end

  # Method to change status to 'participating'
  def start!
    update!(status: "started")
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
