class CleanUp < ApplicationRecord
  broadcasts_refreshes
  broadcasts_refreshes_to ->(clean_up) { :clean_ups }

  has_many :participations, dependent: :destroy

  validates :name, presence: true
  validates :status, inclusion: { in: %w[created registration_enabled started ended] }

  def participant_count
    return final_participant_count if status == "ended" && final_participant_count.present?

    # sum of all people counts (participant.count)
    sum = 0
    participations.each do |participation|
      sum += participation.participant.people_count
    end
    sum
  end

  def total_cigarettes_count
    participations.sum(:cigarettes_count) + manual_cigarettes_count
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
    update!(status: "ended", final_participant_count: compute_participant_count)
  end

  def compute_participant_count
    participations.joins(:participant).sum("participants.people_count")
  end

  def ended?
    status == "ended"
  end

  # Class methods for global statistics
  def self.total_cigarettes_collected
    sum_from_participations = Participation.sum(:cigarettes_count)
    sum_from_manual = CleanUp.sum(:manual_cigarettes_count)
    sum_from_participations + sum_from_manual
  end

  def self.total_count
    where(status: "ended").count
  end

  private

  def schedule_auto_end
    return unless starts_at.present?

    end_time = starts_at + 24.hours
    EndCleanUpJob.set(wait_until: end_time).perform_later(id)
  end
end
