require "test_helper"

class EndCleanUpJobTest < ActiveJob::TestCase
  test "ends a clean up" do
    clean_up = CleanUp.create!(name: "Test Cleanup", status: "started", starts_at: 1.day.ago)

    EndCleanUpJob.perform_now(clean_up.id)

    clean_up.reload
    assert clean_up.ended?
  end

  test "does not end an already ended clean up" do
    clean_up = CleanUp.create!(name: "Test Cleanup", status: "ended", starts_at: 1.day.ago)

    EndCleanUpJob.perform_now(clean_up.id)

    clean_up.reload
    assert clean_up.ended?
  end

  test "handles non-existent clean up gracefully" do
    assert_nothing_raised do
      EndCleanUpJob.perform_now(-1)
    end
  end
end
