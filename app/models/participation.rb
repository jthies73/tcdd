class Participation < ApplicationRecord
  include Turbo::Broadcastable

  belongs_to :clean_up, inverse_of: :participations
  belongs_to :participant, inverse_of: :participations

  validates :status, inclusion: { in: %w[registered started returned] }

  after_create_commit :broadcast_participation_created
  after_update_commit :broadcast_cigarettes_count_update, if: :saved_change_to_cigarettes_count?
  after_update_commit :broadcast_participation_status_changed, if: :saved_change_to_status?
  after_update_commit :broadcast_scoreboard_update, if: :should_broadcast_scoreboard_update?
  after_destroy_commit :broadcast_participation_destroyed

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
      update!(status: "started", started_at: Time.current)
    else
      Rails.logger.error("Cannot start participation for clean up that is not started")
    end
  end

  def return!
    update!(status: "returned", returned_at: Time.current)
  end

  private

  def broadcast_participation_created
    broadcast_admin_updates
    broadcast_public_participant_count
  end

  def broadcast_participation_status_changed
    broadcast_admin_updates
    broadcast_user_participation_content
  end

  def broadcast_participation_destroyed
    broadcast_admin_updates
    broadcast_public_participant_count
  end

  def broadcast_admin_updates
    # Broadcast to admin clean_up show page - update the participants table
    broadcast_replace_to(
      "admin_clean_up_#{clean_up_id}",
      target: "admin_participants_table_#{clean_up_id}",
      partial: "admin/participations/participants_table",
      locals: { clean_up: clean_up }
    )

    # Broadcast to admin clean_ups index page - update the clean-up row
    broadcast_replace_to(
      :admin_clean_ups,
      target: "admin_clean_up_row_#{clean_up_id}",
      partial: "admin/clean_ups/clean_up_row",
      locals: { clean_up: clean_up }
    )
  end

  def broadcast_public_participant_count
    # Broadcast to public registration page - update the participant count
    broadcast_replace_to(
      clean_up,
      target: "participant_count_#{clean_up_id}",
      partial: "participations/participant_count",
      locals: { clean_up: clean_up }
    )
  end

  def broadcast_user_participation_content
    # Broadcast to user's participation show page when status changes -
    # replaces the participation content section with updated UI based on new status
    broadcast_replace_to(
      "participation_#{id}",
      target: "participation_content_#{id}",
      partial: "participations/participation_content",
      locals: { participation: self }
    )
  end

  def broadcast_cigarettes_count_update
    # Broadcast to all clients viewing the same participation (same group)
    broadcast_replace_to(
      "participation_#{id}",
      target: "cigarettes_counter_#{id}",
      partial: "participations/cigarettes_counter",
      locals: { participation: self }
    )

    # Broadcast to admin clean_up show page
    broadcast_replace_to(
      "admin_clean_up_#{clean_up_id}",
      target: "admin_cigarettes_summary_#{clean_up_id}",
      partial: "admin/clean_ups/cigarettes_summary",
      locals: { clean_up: clean_up }
    )

    broadcast_replace_to(
      "admin_clean_up_#{clean_up_id}",
      target: "admin_participants_table_#{clean_up_id}",
      partial: "admin/participations/participants_table",
      locals: { clean_up: clean_up }
    )
  end

  def should_broadcast_scoreboard_update?
    saved_change_to_status? && status == "returned" && cigarettes_count.present? && cigarettes_count > 0
  end

  def broadcast_scoreboard_update
    # Broadcast to all clients viewing the scoreboard for this clean_up
    broadcast_replace_to(
      "scoreboard_#{clean_up_id}",
      target: "scoreboard_#{clean_up_id}",
      partial: "participations/scoreboard",
      locals: { clean_up: clean_up, participation: self }
    )
  end
end
