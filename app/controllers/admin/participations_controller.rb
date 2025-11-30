module Admin
  class ParticipationsController < ApplicationController
    before_action :set_clean_up
    before_action :set_participation, only: %i[change_status destroy]

    # POST /admin/clean_ups/:clean_up_id/participations
    def create
      @participation = @clean_up.participations.new(status: "registered")

      # Validate input parameters
      validation_error = validate_participation_input
      return redirect_with_alert(validation_error) if validation_error

      # Find or create participant
      participant = find_or_create_participant
      return redirect_with_alert(participant) if participant.is_a?(String) # Error message

      # Check if participant is already registered
      if @clean_up.participant_already_registered?(participant)
        return redirect_with_alert("Teilnehmer ist bereits registriert.")
      end

      @participation.participant = participant

      if @participation.save
        redirect_to admin_clean_up_path(@clean_up), notice: "Teilnehmer wurde erfolgreich registriert."
      else
        redirect_with_alert(@participation.errors.full_messages.join(", "))
      end
    end

    # POST /admin/clean_ups/:clean_up_id/participations/:id/change_status
    def change_status
      case change_status_params[:status_action]
      when "start"
        @participation.start!
      when "return"
        @participation.return!
      else
        return redirect_to admin_clean_up_path(@clean_up), alert: "Ungültige Aktion."
      end

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "participants_table",
            partial: "admin/participations/participants_table",
            locals: { clean_up: @clean_up }
          )
        end
        format.html { redirect_to admin_clean_up_path(@clean_up) }
      end
    end

    # DELETE /admin/clean_ups/:clean_up_id/participations/:id
    def destroy
      # Only allow deletion of participants in registered state
      unless @participation.status == "registered"
        return redirect_to admin_clean_up_path(@clean_up), alert: "Nur Teilnehmer im Status 'registriert' können entfernt werden."
      end

      @participation.destroy
      redirect_to admin_clean_up_path(@clean_up), notice: "Teilnehmer wurde entfernt."
    end

    private

    def set_clean_up
      @clean_up = CleanUp.find(params[:clean_up_id])
    end

    def set_participation
      @participation = @clean_up.participations.find(params[:id])
    end

    def participation_params
      params.permit(:participant_id, :participant_name, :participant_people_count)
    end

    def change_status_params
      params.permit(:status_action)
    end

    # Validation methods
    def validate_participation_input
      participant_id_present = participation_params[:participant_id].present?
      participant_name_present = participation_params[:participant_name].present?

      if participant_id_present && participant_name_present
        "Bitte wählen Sie entweder einen bestehenden Teilnehmer ODER geben Sie einen neuen Namen ein - nicht beides."
      elsif !participant_id_present && !participant_name_present
        "Bitte einen Namen eingeben oder einen Teilnehmer auswählen."
      end
    end

    def find_or_create_participant
      if participation_params[:participant_id].present?
        find_existing_participant_by_id
      elsif participation_params[:participant_name].present?
        find_or_create_participant_by_name
      end
    end

    def find_existing_participant_by_id
      participant = Participant.find_by(id: participation_params[:participant_id])
      return "Teilnehmer nicht gefunden." if participant.nil?

      participant
    end

    def find_or_create_participant_by_name
      existing_participant = Participant.find_by(name: participation_params[:participant_name])

      if existing_participant
        existing_participant
      else
        create_new_participant
      end
    end

    def create_new_participant
      participant = Participant.new(
        name: participation_params[:participant_name],
        people_count: participation_params[:participant_people_count].presence || 1
      )

      return participant.errors.full_messages.join(", ") unless participant.save

      participant
    end

    def redirect_with_alert(message)
      redirect_to admin_clean_up_path(@clean_up), alert: message
    end
  end
end
