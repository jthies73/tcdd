module Admin
  class CleanUpsController < ApplicationController
    def index
      @clean_ups = CleanUp.order(starts_at: :desc)
    end

    def new
      @clean_up = CleanUp.new
    end

    def create
      modified_params = build_params_with_starts_at
      return render :new, status: :unprocessable_entity if modified_params.nil?

      @clean_up = CleanUp.new(modified_params)
      @clean_up.status = "created"

      if @clean_up.save
        redirect_to admin_clean_ups_path, notice: "CleanUp was successfully created."
      else
        render :new
      end
    end

    def show
      @clean_up = CleanUp.find(params[:id])
      @participants = Participant.all
    end

    def update
      @clean_up = CleanUp.find(params[:id])
      modified_params = build_params_with_starts_at

      if modified_params.nil?
        @participants = Participant.all
        return render :show, status: :unprocessable_entity
      end

      if @clean_up.update(modified_params)
        redirect_to admin_clean_up_path(@clean_up), notice: "Clean-Up wurde erfolgreich aktualisiert."
      else
        @participants = Participant.all
        render :show, status: :unprocessable_entity
      end
    end

    # POST /admin/clean_ups/:id/change_status
    def change_status
      @clean_up = CleanUp.find(change_params[:clean_up_id])

      case change_params[:change_action]
      when "enable_registration"
        @clean_up.enable_registration!
      when "start"
        @clean_up.start!
      when "end"
        @clean_up.end!
      end

      redirect_to admin_clean_up_path(@clean_up)
    end

    # POST /admin/clean_ups/:id/revert_status
    def revert_status
      @clean_up = CleanUp.find(params[:id])

      case @clean_up.status
      when "registration_enabled"
        @clean_up.update!(status: "created")
      when "started"
        @clean_up.update!(status: "registration_enabled")
      when "ended"
        @clean_up.update!(status: "started")
      end

      redirect_to admin_clean_up_path(@clean_up)
    end

    # DELETE /admin/clean_ups/:id
    def destroy
      @clean_up = CleanUp.find(params[:id])
      @clean_up.destroy

      redirect_to admin_clean_ups_path, notice: "Clean-Up wurde erfolgreich gelöscht."
    end

    # POST /admin/clean_ups/:id/add_cigarettes
    def add_cigarettes
      @clean_up = CleanUp.find(params[:id])
      amount = add_cigarettes_params[:amount].to_i

      if amount > 0
        @clean_up.update!(last_manual_cigarettes_amount: amount)
        @clean_up.increment!(:manual_cigarettes_count, amount)
      end

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to admin_clean_up_path(@clean_up) }
      end
    end

    # POST /admin/clean_ups/:id/revert_cigarettes
    def revert_cigarettes
      @clean_up = CleanUp.find(params[:id])
      last_amount = @clean_up.last_manual_cigarettes_amount

      if last_amount > 0 && @clean_up.manual_cigarettes_count >= last_amount
        @clean_up.decrement!(:manual_cigarettes_count, last_amount)
        @clean_up.update!(last_manual_cigarettes_amount: 0)
      end

      respond_to do |format|
        format.turbo_stream { render "add_cigarettes" }
        format.html { redirect_to admin_clean_up_path(@clean_up) }
      end
    end

    private

    def clean_up_params
      params.require(:clean_up).permit(:id, :name, :description, :status, :date, :time, :address, :location)
    end

    def change_params
      params.permit(:clean_up_id, :change_action)
    end

    def add_cigarettes_params
      params.permit(:amount)
    end

    def build_params_with_starts_at
      date_str = clean_up_params[:date]
      time_str = clean_up_params[:time]
      base_params = clean_up_params.except(:date, :time)

      return base_params if date_str.blank?

      begin
        date = Date.parse(date_str)
        berlin_tz = ActiveSupport::TimeZone["Europe/Berlin"]

        if time_str.present?
          time = Time.parse(time_str)
          local_datetime = berlin_tz.local(date.year, date.month, date.day, time.hour, time.min, time.sec)
        else
          local_datetime = berlin_tz.local(date.year, date.month, date.day, 0, 0, 0)
        end

        base_params.merge(starts_at: local_datetime.utc)
      rescue ArgumentError
        nil
      end
    end
  end
end
