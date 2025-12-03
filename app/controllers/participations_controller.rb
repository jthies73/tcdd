class ParticipationsController < ApplicationController
  def new
    PageVisit.track_visit!
    # find the latest clean up that is in status registration_enabled or started
    @latest_clean_up = CleanUp.latest_active

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
    clean_up = CleanUp.latest_active

    unless clean_up&.registerable?
      redirect_to root_path and return
    end

    if registration_params[:participant_id].present?
      handle_existing_participant(clean_up)
    else
      handle_new_participant(clean_up)
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

  def handle_existing_participant(clean_up)
    participant = Participant.find(registration_params[:participant_id])

    # Update participant's people_count if provided
    update_participant_people_count(participant)

    # Check for existing participation
    existing_participation = clean_up.participations.find_by(participant_id: participant.id)
    if existing_participation
      redirect_to show_participation_path(existing_participation) and return
    end

    # Create new participation
    create_participation(clean_up, participant)
  end

  def handle_new_participant(clean_up)
    participant_name = registration_params[:participant_name]
    participant_people_count = registration_params[:participant_people_count] || 1

    # Check if a participant with this name already exists
    if Participant.exists?(name: participant_name)
      handle_duplicate_name_error(participant_name, participant_people_count)
      return
    end

    # Create new participant and participation
    participant = Participant.create!(
      name: participant_name,
      people_count: participant_people_count
    )

    create_participation(clean_up, participant)
  end

  def update_participant_people_count(participant)
    return unless registration_params[:participant_people_count].present?

    people_count = [ registration_params[:participant_people_count].to_i, 1 ].max
    participant.update!(people_count: people_count)
  end

  def create_participation(clean_up, participant)
    participation = clean_up.participations.create!(
      participant_id: participant.id,
      status: "registered"
    )

    redirect_to show_participation_path(participation)
  end

  def handle_duplicate_name_error(participant_name, participant_people_count)
    @error_message = "Dieser Name ist bereits vergeben. Bitte wähle deinen Namen aus der Liste oder gib einen anderen Namen ein."
    @participant_data = { name: participant_name, people_count: participant_people_count }

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to new_participation_path }
    end
  end

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
