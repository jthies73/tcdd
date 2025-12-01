class Participation < ApplicationRecord
  include Turbo::Broadcastable

  belongs_to :clean_up, inverse_of: :participations
  belongs_to :participant, inverse_of: :participations

  validates :status, inclusion: { in: %w[registered started returned] }

  after_update_commit :broadcast_cigarettes_count_update, if: :saved_change_to_cigarettes_count?

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

  private

  def broadcast_cigarettes_count_update
    # Broadcast to all clients viewing the same participation (same group)
    broadcast_replace_to(
      "participation_#{id}",
      target: "cigarettes_counter_#{id}",
      partial: "participations/cigarettes_counter",
      locals: { participation: self }
    )
  end
end
