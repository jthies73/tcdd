class ParticipationsController < ApplicationController
  def new
    if params[:id]
      @participation = Participation.find(params[:id])
    else
      @participation = Participation.new
    end

    if CleanUp.last.status == "ended"
      # render pages/no_active_clean_up.html.erb
      render "pages/no_active_clean_up"
    else
      render :new
    end
  end

  def register
    puts "register_params: #{register_params}"
    if register_params[:id].nil?
      @participation = Participation.new(name: register_params[:name])
      @participation.clean_up = CleanUp.last
    else
      @participation = Participation.find(register_params[:id])
    end

    @participation.register!
    if @participation.save
      clean_up = CleanUp.last
      clean_up.participations << @participation
      clean_up.save
      redirect_to new_participation_path(id: @participation.id)
    end

    puts "participation_errors: #{@participation.errors.full_messages}"
  end

  def start
    @participation = Participation.find(start_params[:id])
    @participation.start!
    redirect_to new_participation_path(id: @participation.id)
  end

  def return
    @participation = Participation.find(return_params[:id])
    @participation.return!
    redirect_to thank_you_path
  end

  private

  def participation_params
    params.require(:participation).permit(:name)
  end

  def register_params
    params.require(:participation).permit(:id, :name)
  end

  def start_params
    params.require(:participation).permit(:id)
  end

  def return_params
    params.require(:participation).permit(:id)
  end
end
