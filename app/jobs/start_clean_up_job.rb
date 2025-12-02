class StartCleanUpJob < ApplicationJob
  queue_as :default

  def perform(clean_up_id)
    clean_up = CleanUp.find_by(id: clean_up_id)
    return unless clean_up
    return if clean_up.started? || clean_up.ended?

    clean_up.start!
  end
end
