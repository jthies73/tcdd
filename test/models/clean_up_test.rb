require "test_helper"

class CleanUpTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    @clean_up = CleanUp.create!(
      name: "Test Clean-Up",
      description: "Test description",
      status: "registration_enabled",
      starts_at: 1.hour.from_now,
      address: "Test address"
    )

    @participant = Participant.create!(
      name: "John Doe",
      people_count: 2
    )
  end

  test "participant_already_registered? returns false when participant is not registered" do
    assert_not @clean_up.participant_already_registered?(@participant)
  end

  test "participant_already_registered? returns true when participant is already registered" do
    # Create a participation for this participant
    @clean_up.participations.create!(
      participant: @participant,
      status: "registered"
    )

    assert @clean_up.participant_already_registered?(@participant)
  end

  test "participant_already_registered? returns false for different participant" do
    other_participant = Participant.create!(
      name: "Jane Smith",
      people_count: 1
    )

    # Register the first participant
    @clean_up.participations.create!(
      participant: @participant,
      status: "registered"
    )

    # The other participant should not be considered registered
    assert_not @clean_up.participant_already_registered?(other_participant)
  end

  test "participant_already_registered? works with different participation statuses" do
    # Test with different statuses
    %w[registered started returned].each do |status|
      # Clean up any existing participations
      @clean_up.participations.destroy_all

      # Create participation with specific status
      @clean_up.participations.create!(
        participant: @participant,
        status: status
      )

      assert @clean_up.participant_already_registered?(@participant),
             "Should return true for participant with status '#{status}'"
    end
  end

  test "participant_already_registered? handles nil participant gracefully" do
    assert_raises(NoMethodError) do
      @clean_up.participant_already_registered?(nil)
    end
  end

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

  test "total_cigarettes_count returns sum of all participations cigarettes_count" do
    participant1 = Participant.create!(name: "Participant 1", people_count: 1)
    participant2 = Participant.create!(name: "Participant 2", people_count: 1)

    @clean_up.participations.create!(
      participant: participant1,
      status: "started",
      cigarettes_count: 10
    )
    @clean_up.participations.create!(
      participant: participant2,
      status: "started",
      cigarettes_count: 15
    )

    assert_equal 25, @clean_up.total_cigarettes_count
  end

  test "total_cigarettes_count returns 0 when no participations have counts" do
    assert_equal 0, @clean_up.total_cigarettes_count
  end

  test "total_cigarettes_count handles nil cigarettes_count values" do
    participant1 = Participant.create!(name: "Participant 1", people_count: 1)
    participant2 = Participant.create!(name: "Participant 2", people_count: 1)

    @clean_up.participations.create!(
      participant: participant1,
      status: "started",
      cigarettes_count: nil
    )
    @clean_up.participations.create!(
      participant: participant2,
      status: "started",
      cigarettes_count: 5
    )

    assert_equal 5, @clean_up.total_cigarettes_count
  end
end
