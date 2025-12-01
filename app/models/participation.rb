class Participation < ApplicationRecord
  belongs_to :clean_up, inverse_of: :participations
  belongs_to :participant, inverse_of: :participations

  validates :status, inclusion: { in: %w[registered started returned] }
  validates :cigarettes_count, numericality: { greater_than_or_equal_to: 0, allow_nil: true }

  def self.total_cigarettes_for_clean_up(clean_up)
    where(clean_up: clean_up).sum(:cigarettes_count)
  end

  def color_by_status
    case status
    when "registered"
      "gray"
    when "started"
      "red"
    when "returned"
      "green"
    end
  end

  def label_by_status
    case status
    when "registered"
      "registriert"
    when "started"
      "unterwegs"
    when "returned"
      "zurück"
    end
  end

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
