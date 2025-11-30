require "test_helper"

class CleanUpTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "start! schedules EndCleanUpJob for 24 hours after starts_at" do
    starts_at = Time.current + 1.hour
    clean_up = CleanUp.create!(name: "Test Cleanup", status: "created", starts_at: starts_at)

    assert_enqueued_with(job: EndCleanUpJob, args: [ clean_up.id ], at: starts_at + 24.hours) do
      clean_up.start!
    end

    assert clean_up.started?
  end

  test "start! does not schedule job when starts_at is nil" do
    clean_up = CleanUp.create!(name: "Test Cleanup", status: "created", starts_at: nil)

    assert_no_enqueued_jobs only: EndCleanUpJob do
      clean_up.start!
    end

    assert clean_up.started?
  end
end
