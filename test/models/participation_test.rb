require "test_helper"

class ParticipationTest < ActiveSupport::TestCase
  def setup
    @clean_up = CleanUp.create!(
      name: "Test Clean-Up",
      description: "Test description",
      status: "started",
      starts_at: 1.hour.from_now,
      address: "Test address"
    )

    @participant = Participant.create!(
      name: "Test Participant",
      people_count: 2
    )

    @participation = Participation.create!(
      clean_up: @clean_up,
      participant: @participant,
      status: "started",
      cigarettes_count: 0
    )
  end

  test "cigarettes_count defaults to nil when not set" do
    new_participation = Participation.create!(
      clean_up: @clean_up,
      participant: Participant.create!(name: "Another Participant", people_count: 1),
      status: "registered"
    )
    assert_nil new_participation.cigarettes_count
  end

  test "cigarettes_count can be updated" do
    @participation.update!(cigarettes_count: 10)
    assert_equal 10, @participation.reload.cigarettes_count
  end

  test "cigarettes_count can be set to zero" do
    @participation.update!(cigarettes_count: 5)
    @participation.update!(cigarettes_count: 0)
    assert_equal 0, @participation.reload.cigarettes_count
  end

  test "color_by_status returns correct colors" do
    @participation.status = "registered"
    assert_equal "gray", @participation.color_by_status

    @participation.status = "started"
    assert_equal "red", @participation.color_by_status

    @participation.status = "returned"
    assert_equal "green", @participation.color_by_status
  end

  test "label_by_status returns correct labels" do
    @participation.status = "registered"
    assert_equal "registriert", @participation.label_by_status

    @participation.status = "started"
    assert_equal "unterwegs", @participation.label_by_status

    @participation.status = "returned"
    assert_equal "zurück", @participation.label_by_status
  end

  test "start! updates status when clean up is started" do
    @participation.update!(status: "registered")
    @participation.start!
    assert_equal "started", @participation.reload.status
  end

  test "start! sets started_at when clean up is started" do
    @participation.update!(status: "registered", started_at: nil)
    freeze_time do
      @participation.start!
      assert_equal Time.current, @participation.reload.started_at
    end
  end

  test "start! does not update status when clean up is not started" do
    @clean_up.update!(status: "registration_enabled")
    @participation.update!(status: "registered")
    @participation.start!
    assert_equal "registered", @participation.reload.status
  end

  test "start! does not set started_at when clean up is not started" do
    @clean_up.update!(status: "registration_enabled")
    @participation.update!(status: "registered", started_at: nil)
    @participation.start!
    assert_nil @participation.reload.started_at
  end

  test "return! updates status to returned" do
    @participation.return!
    assert_equal "returned", @participation.reload.status
  end

  test "return! sets returned_at" do
    @participation.update!(returned_at: nil)
    freeze_time do
      @participation.return!
      assert_equal Time.current, @participation.reload.returned_at
    end
  end

  test "validates status inclusion" do
    @participation.status = "invalid_status"
    assert_not @participation.valid?
    assert_includes @participation.errors[:status], "is not included in the list"
  end

  test "has broadcast callbacks defined for create" do
    # Verify the after_create_commit callback is defined
    callbacks = Participation._commit_callbacks.select { |cb| cb.filter == :broadcast_participation_created }
    assert_not_empty callbacks, "Expected broadcast_participation_created callback to be defined"
  end

  test "has broadcast callbacks defined for status change" do
    # Verify the after_update_commit callback for status change is defined
    callbacks = Participation._commit_callbacks.select { |cb| cb.filter == :broadcast_participation_status_changed }
    assert_not_empty callbacks, "Expected broadcast_participation_status_changed callback to be defined"
  end

  test "has broadcast callbacks defined for destroy" do
    # Verify the after_destroy_commit callback is defined
    callbacks = Participation._commit_callbacks.select { |cb| cb.filter == :broadcast_participation_destroyed }
    assert_not_empty callbacks, "Expected broadcast_participation_destroyed callback to be defined"
  end

  test "broadcast methods are defined as private methods" do
    # Verify the broadcast methods exist as private methods
    assert Participation.private_method_defined?(:broadcast_participation_created),
           "Expected broadcast_participation_created to be defined as a private method"
    assert Participation.private_method_defined?(:broadcast_participation_status_changed),
           "Expected broadcast_participation_status_changed to be defined as a private method"
    assert Participation.private_method_defined?(:broadcast_participation_destroyed),
           "Expected broadcast_participation_destroyed to be defined as a private method"
    assert Participation.private_method_defined?(:broadcast_admin_updates),
           "Expected broadcast_admin_updates to be defined as a private method"
    assert Participation.private_method_defined?(:broadcast_public_participant_count),
           "Expected broadcast_public_participant_count to be defined as a private method"
    assert Participation.private_method_defined?(:broadcast_user_participation_content),
           "Expected broadcast_user_participation_content to be defined as a private method"
    assert Participation.private_method_defined?(:broadcast_scoreboard_update),
           "Expected broadcast_scoreboard_update to be defined as a private method"
    assert Participation.private_method_defined?(:should_broadcast_scoreboard_update?),
           "Expected should_broadcast_scoreboard_update? to be defined as a private method"
  end

  test "has broadcast_scoreboard_update callback registered" do
    # Verify the after_update_commit callback for scoreboard update is defined
    callbacks = Participation._commit_callbacks.select { |cb| cb.filter == :broadcast_scoreboard_update }
    assert_not_empty callbacks, "Expected broadcast_scoreboard_update callback to be defined"
  end
end
