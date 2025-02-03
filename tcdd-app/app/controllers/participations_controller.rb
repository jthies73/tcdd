class ParticipationsController < ApplicationController
  def new
    @participation = Participation.new
  end
end