class CleanUpController < ApplicationController
  def index
  end

  def new
    @clean_up = CleanUp.new
    
  end
end
