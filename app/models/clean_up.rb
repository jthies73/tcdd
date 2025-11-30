class CleanUp < ApplicationRecord
  has_many :participations, dependent: :destroy

  validates :name, presence: true
  validates :status, inclusion: { in: %w[created registration_enabled started ended] }

  def participant_count
    # sum of all people counts (participant.count)
    sum = 0
    participations.each do |participation|
      sum += participation.participant.people_count
    end
    sum
  end

  def find_participation_by_participant_id(participant_id)
    participations.where(participant_id: participant_id).first
  end

  def participant_already_registered?(participant)
    find_participation_by_participant_id(participant.id).present?
  end

  def color_by_status
    case status
    when "created"
      "gray"
    when "registration_enabled"
      "green"
    when "started"
      "green"
    when "ended"
      "red"
    end
  end

  def label_by_status
    case status
    when "created"
      "erstellt"
    when "registration_enabled"
      "Aktiv"
    when "started"
      "Aktiv"
    when "ended"
      "Beendet"
    end
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
    schedule_auto_end
  end

  def started?
    status == "started"
  end

  def end!
    update!(status: "ended")
  end

  def ended?
    status == "ended"
  end

  private

  def schedule_auto_end
    return unless starts_at.present?

    end_time = starts_at + 24.hours
    EndCleanUpJob.set(wait_until: end_time).perform_later(id)
  end
end
