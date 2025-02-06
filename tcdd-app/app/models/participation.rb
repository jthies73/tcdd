class Participation < ApplicationRecord
  belongs_to :clean_up, inverse_of: :participations
  belongs_to :participant, inverse_of: :participations

  validates :status, inclusion: { in: %w[registered started returned] }

  def start!
    if clean_up.started?
      update!(status: "started")
    else
      Rails.logger.error("Cannot start participation for clean up that is not started")
    end
  end

  def return!
    update!(status: "returned")
  end
end
