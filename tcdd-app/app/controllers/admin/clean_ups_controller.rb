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
      if @clean_up.save
        redirect_to admin_clean_ups_path, notice: "CleanUp was successfully created."
      else
        render :new
      end
    end

    def show
      @clean_up = CleanUp.find(params[:id])
      @participations = Participation.where(id: @clean_up.id)
    end

    private

    def clean_up_params
      params.require(:clean_up).permit(:name, :description)
    end
  end
end
