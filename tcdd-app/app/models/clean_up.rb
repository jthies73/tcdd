class CleanUp < ApplicationRecord
  has_many :participations
  has_many :participation_logs

  validates :status, inclusion: { in: %w[registration_enabled started ended], allow_nil: true }

  def enable_registration!
    update!(status: "registration_enabled")
  end

  def disable_registration!
    update!(status: nil)
  end

  def start!
    update!(status: "started")
  end

  def end!
    update!(status: "ended")
    participations.each do |participation|
      # add a log to the clean up that shows all the participations and their status
      participation_log = ParticipationLog.new(participation_id: participation.id, status: participation.status)
      participation_log.save


      # reset the status of the participation
      participation.reset!
    end
  end
end
