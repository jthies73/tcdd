class ParticipationsController < ApplicationController
  def new
    @latest_clean_up = CleanUp.last
    render "pages/no_active_clean_up" and return if @latest_clean_up.inactive?
    render :new
  end

  def show
    @participation = Participation.find(participation_params[:id])
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
    participation = Participation.find(participation_params[:id])
    if participation_params[:participation_action] == "start"
      participation.start!
    elsif participation_params[:participation_action] == "return"
      participation.return!
    end
    redirect_to show_participation_path(participation)
  end

  private

  def registration_params
    puts "registration params: #{params}"
    params.permit(:participant_id, :participant_name)
  end

  def participation_params
    puts "participation params: #{params}"
    params.permit(:id, :participation_action)
  end
end
