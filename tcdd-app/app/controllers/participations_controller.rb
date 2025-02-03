class ParticipationsController < ApplicationController
  def new
    @participation = Participation.new
  end

  def create
    @participation = Participation.new(participation_params)
    @participation.clean_up = CleanUp.last
    @participation.status = "registered"
    puts @participation.inspect
    
    if @participation.save
      redirect_to admin_clean_up_path(CleanUp.last), notice: "Participation was successfully created."
    else
      puts @participation.errors.full_messages
      render :new
    end
  end

  private

  def participation_params
    params.require(:participation).permit(:name)
  end
end