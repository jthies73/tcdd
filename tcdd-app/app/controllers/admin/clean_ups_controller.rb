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

    # enable registration for the clean up
    def enable_registration
      @clean_up = CleanUp.find(params[:id])
      @clean_up.enable_registration!
      redirect_to admin_clean_up_path(@clean_up)
    end

    # disable registration for the clean up
    def disable_registration
      @clean_up = CleanUp.find(params[:id])
      @clean_up.disable_registration!
      redirect_to admin_clean_up_path(@clean_up)
    end

    # start the clean up
    def start 
      @clean_up = CleanUp.find(params[:id])
      @clean_up.start!
      redirect_to admin_clean_up_path(@clean_up)
    end

    # finish the clean up
    def end
      @clean_up = CleanUp.find(params[:id])
      @clean_up.end!
      redirect_to admin_clean_up_path(@clean_up)
    end

    def show
      @clean_up = CleanUp.find(params[:id])
    end

    private

    def clean_up_params
      params.require(:clean_up).permit(:id, :name, :description, :status, :datetime, :address, :location)
    end
  end
end
