module Admin
  class ParticipationsController < ApplicationController
    before_action :set_clean_up
    before_action :set_participation, only: %i[change_status destroy]

    # POST /admin/clean_ups/:clean_up_id/participations
    def create
      validation_error = validate_participation_input
      return redirect_with_alert(validation_error) if validation_error

      participant = find_or_create_participant
      return redirect_with_alert(participant) if participant.is_a?(String)

      update_participant_people_count(participant)

      if @clean_up.participant_already_registered?(participant)
        return redirect_to admin_clean_up_path(@clean_up), notice: "Registrierung wurde geupdatet."
      end

      create_and_save_participation(participant)
    end

    # POST /admin/clean_ups/:clean_up_id/participations/:id/change_status
    def change_status
      unless update_participation_status
        return redirect_to admin_clean_up_path(@clean_up), alert: "Ungültige Aktion."
      end

      respond_to do |format|
        format.turbo_stream { render_participants_table }
        format.html { redirect_to admin_clean_up_path(@clean_up) }
      end
    end

    # DELETE /admin/clean_ups/:clean_up_id/participations/:id
    def destroy
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

    # Status and participation management
    def update_participation_status
      case change_status_params[:status_action]
      when "start"
        @participation.start!
        true
      when "return"
        @participation.return!
        true
      else
        false
      end
    end

    def render_participants_table
      render turbo_stream: turbo_stream.replace(
        "participants_table",
        partial: "admin/participations/participants_table",
        locals: { clean_up: @clean_up }
      )
    end

    def create_and_save_participation(participant)
      participation = @clean_up.participations.new(
        participant: participant,
        status: "registered"
      )

      if participation.save
        redirect_to admin_clean_up_path(@clean_up), notice: "Teilnehmer wurde erfolgreich registriert."
      else
        redirect_with_alert(participation.errors.full_messages.join(", "))
      end
    end

    # Validation methods
    def validate_participation_input
      has_id = participation_params[:participant_id].present?
      has_name = participation_params[:participant_name].present?

      return "Bitte wählen Sie entweder einen bestehenden Teilnehmer ODER geben Sie einen neuen Namen ein - nicht beides." if has_id && has_name
      return "Bitte einen Namen eingeben oder einen Teilnehmer auswählen." if !has_id && !has_name

      nil
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
      existing = Participant.find_by(name: participation_params[:participant_name])
      return "Dieser Name ist bereits vergeben. Bitte wähle deinen Namen aus der Liste oder gib einen anderen Namen ein." if existing

      create_new_participant
    end

    def create_new_participant
      participant = Participant.new(
        name: participation_params[:participant_name],
        people_count: participation_params[:participant_people_count].presence || 1
      )

      participant.save ? participant : participant.errors.full_messages.join(", ")
    end

    def update_participant_people_count(participant)
      return unless participation_params[:participant_people_count].present?

      people_count = [ participation_params[:participant_people_count].to_i, 1 ].max
      participant.update!(people_count: people_count)
    end

    def redirect_with_alert(message)
      redirect_to admin_clean_up_path(@clean_up), alert: message
    end
  end
end
