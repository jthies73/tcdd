module Admin
  class CleanUpsController < ApplicationController
    def index
      @clean_ups = CleanUp.all
    end

    def new
      @clean_up = CleanUp.new
    end

    def create
      @clean_up = CleanUp.new(clean_up_params)
      @clean_up.status = "created"
      
      if @clean_up.save
        redirect_to admin_clean_ups_path, notice: "CleanUp was successfully created."
      else
        puts @clean_up.errors.full_messages
        render :new
      end
    end

    def show
      @clean_up = CleanUp.find(params[:id])
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
    private

    def clean_up_params
      puts "clean up params: #{params}"
      params.require(:clean_up).permit(:id, :name, :description, :status, :datetime, :address, :location)
    end

    def change_params
      puts "change params: #{params}"
      params.permit(:clean_up_id, :change_action)
    end
  end
end
