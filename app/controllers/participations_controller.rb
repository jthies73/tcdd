class ParticipationsController < ApplicationController
  def new
    @latest_clean_up = CleanUp.last
    render "pages/no_active_clean_up" and return if @latest_clean_up.nil? || @latest_clean_up.inactive?
    render :new
  end

  def show
    puts "params: #{params}"
    @participation = Participation.find(params[:id])
    render :show
  end

  # POST /participations
  def create
    # initialize participation
    participation = Participation.new
    participation.status = "registered"
    participation.clean_up = CleanUp.last

    # if the clean up is not in the registration enabled state, redirect to the participation page
    if !participation.clean_up.registerable? && !participation.idle?
      redirect_to root_path and return
    end

    # if a participant id is provided, use it to create the participation
    # this means the participant has already registered at least once for a clean up
    if registration_params[:participant_id].present?
       existing_participation = participation.clean_up.find_participation_by_participant_id(registration_params[:participant_id])
      if existing_participation.present?
        # if the participant has already registered for the clean up, redirect him to the participation page
        redirect_to show_participation_path(existing_participation) and return
      else
        # if the participant has not registered for this clean up, create a new participation
        participation.participant_id = registration_params[:participant_id]
      end
    else
      # if only a participant name is provided, create a new participant
      participant = Participant.new
      participant.name = registration_params[:participant_name]
      participant.people_count = registration_params[:participant_people_count] || 1
      participant.save
      participation.participant_id = participant.id
    end

    if participation.save
      # once the participation is saved, redirect to the participation page
      redirect_to show_participation_path(participation)
    end
  end

  # PATCH /participations/:id
  def update
    participation = Participation.find(params[:id])
    if participation_params[:participation_action] == "start"
      participation.start!
    elsif participation_params[:participation_action] == "return"
      participation.return!
    end
    redirect_to show_participation_path(participation)
  end

  # PATCH /participations/:id/update_cigarettes
  def update_cigarettes
    participation = Participation.find_by(id: params[:id])

    if participation.nil?
      render json: { success: false, error: "Participation not found" }, status: :not_found
      return
    end

    begin
      cigarettes_count = Integer(params[:cigarettes_count])
    rescue ArgumentError, TypeError
      render json: { success: false, error: "Cigarettes count must be a valid integer" }, status: :unprocessable_entity
      return
    end

    if cigarettes_count < 0
      render json: { success: false, error: "Cigarettes count must be non-negative" }, status: :unprocessable_entity
      return
    end

    if participation.update(cigarettes_count: cigarettes_count)
      # Broadcast to the participant's view
      Turbo::StreamsChannel.broadcast_replace_to(
        "participation_#{participation.id}",
        target: "cigarette_counter_#{participation.id}",
        partial: "participations/cigarette_counter",
        locals: { participation: participation }
      )

      # Broadcast to the admin clean_up view - update total cigarettes
      Turbo::StreamsChannel.broadcast_replace_to(
        "clean_up_#{participation.clean_up_id}_cigarettes",
        target: "total_cigarettes_#{participation.clean_up_id}",
        partial: "admin/clean_ups/total_cigarettes",
        locals: { clean_up: participation.clean_up }
      )

      # Broadcast to the admin clean_up view - update individual cigarette count
      Turbo::StreamsChannel.broadcast_replace_to(
        "clean_up_#{participation.clean_up_id}_cigarettes",
        target: "cigarette_count_#{participation.id}",
        partial: "admin/participations/cigarette_count_cell",
        locals: { participation: participation }
      )

      render json: { success: true, cigarettes_count: participation.cigarettes_count }
    else
      render json: { success: false, error: participation.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    puts "registration params: #{params}"
    params.permit(:participant_id, :participant_name, :participant_people_count)
  end

  def participation_params
    puts "participation params: #{params}"
    params.permit(:participation_action)
  end
end
