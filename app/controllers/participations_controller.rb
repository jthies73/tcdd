class ParticipationsController < ApplicationController
  def new
    PageVisit.track_visit!
    @latest_clean_up = CleanUp.last

    # Set statistics for display
    @total_cigarettes = CleanUp.total_cigarettes_collected
    @total_participants = Participant.total_people_count
    @total_cleanups = CleanUp.total_count

    if @latest_clean_up.nil? || @latest_clean_up.inactive?
      render "pages/no_active_clean_up" and return
    end
    render :new
  end

  def show
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
      participant_name = registration_params[:participant_name]
      participant_people_count = registration_params[:participant_people_count] || 1

      # Check if a participant with this name already exists
      if Participant.exists?(name: participant_name)
        @error_message = "Dieser Name ist bereits vergeben. Bitte wähle deinen Namen aus der Liste oder gib einen anderen Namen ein."
        @participant_data = { name: participant_name, people_count: participant_people_count }

        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to new_participation_path }
        end
        return
      end

      participant = Participant.new
      participant.name = participant_name
      participant.people_count = participant_people_count
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

  # PATCH /participations/:id/update_cigarettes_count
  def update_cigarettes_count
    @participation = Participation.find(params[:id])

    # Only allow updates when participation is started
    unless @participation.status == "started"
      head :unprocessable_entity
      return
    end

    cigarettes_count = [ cigarettes_params[:cigarettes_count].to_i, 0 ].max

    @participation.update!(cigarettes_count: cigarettes_count)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to show_participation_path(@participation) }
      format.json { head :ok }
    end
  end

  # DELETE /participations/:id
  def destroy
    participation = Participation.find(params[:id])

    # Only allow cancellation for participations in "registered" status
    # and when the clean-up has not started yet
    if participation.status == "registered" && !participation.clean_up.started? && !participation.clean_up.ended?
      participation.destroy
      redirect_to farewell_path
    else
      redirect_to show_participation_path(participation)
    end
  end

  private

  def registration_params
    params.permit(:participant_id, :participant_name, :participant_people_count)
  end

  def participation_params
    params.permit(:participation_action)
  end

  def cigarettes_params
    params.permit(:cigarettes_count)
  end
end
