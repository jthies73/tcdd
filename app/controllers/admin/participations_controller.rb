module Admin
  class ParticipationsController < ApplicationController
    before_action :set_clean_up
    before_action :set_participation, only: %i[change_status destroy]

    # POST /admin/clean_ups/:clean_up_id/participations
    def create
      @participation = @clean_up.participations.new
      @participation.status = "registered"

      # Check if participant_id is provided (existing user selected from dropdown)
      if participation_params[:participant_id].present?
        existing_participant = Participant.find_by(id: participation_params[:participant_id])
        if existing_participant.nil?
          return redirect_to admin_clean_up_path(@clean_up), alert: "Teilnehmer nicht gefunden."
        end

        # Check if this participant is already registered for this cleanup
        existing_participation = @clean_up.find_participation_by_participant_id(existing_participant.id)
        if existing_participation.present?
          return redirect_to admin_clean_up_path(@clean_up), alert: "Teilnehmer ist bereits registriert."
        end

        @participation.participant = existing_participant
      elsif participation_params[:participant_name].present?
        # Check if participant already exists by name
        existing_participant = Participant.find_by(name: participation_params[:participant_name])

        if existing_participant
          # Check if this participant is already registered for this cleanup
          existing_participation = @clean_up.find_participation_by_participant_id(existing_participant.id)
          if existing_participation.present?
            return redirect_to admin_clean_up_path(@clean_up), alert: "Teilnehmer ist bereits registriert."
          end

          @participation.participant = existing_participant
        else
          # Create a new participant
          participant = Participant.new(
            name: participation_params[:participant_name],
            people_count: participation_params[:participant_people_count].presence || 1
          )

          unless participant.save
            return redirect_to admin_clean_up_path(@clean_up), alert: participant.errors.full_messages.join(", ")
          end

          @participation.participant = participant
        end
      else
        return redirect_to admin_clean_up_path(@clean_up), alert: "Bitte einen Namen eingeben oder einen Teilnehmer auswählen."
      end

      if @participation.save
        redirect_to admin_clean_up_path(@clean_up), notice: "Teilnehmer wurde erfolgreich registriert."
      else
        redirect_to admin_clean_up_path(@clean_up), alert: @participation.errors.full_messages.join(", ")
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

      redirect_to admin_clean_up_path(@clean_up)
    end

    # DELETE /admin/clean_ups/:clean_up_id/participations/:id
    def destroy
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
  end
end
