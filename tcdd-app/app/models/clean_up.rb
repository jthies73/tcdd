class CleanUp < ApplicationRecord
  has_many :participations

  validates :name, presence: true
  validates :status, inclusion: { in: %w[created registration_enabled started ended] }

  def find_participation_by_participant_id(participant_id)
    participations.where(participant_id: participant_id)
  end

  def inactive?
    status == "created" || status == "ended"
  end

  def enable_registration!
    # end all clean ups that are currently NOT ended
    CleanUp.where.not(status: "ended").each do |clean_up|
      clean_up.end!
    end
    
    update!(status: "registration_enabled")
  end

  def registerable?
    status == "registration_enabled" || status == "started"
  end

  def start!
    update!(status: "started")
  end

  def started?
    status == "started"
  end

  def end!
    update!(status: "ended")
  end
end
