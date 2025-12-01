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

  test "start! does not update status when clean up is not started" do
    @clean_up.update!(status: "registration_enabled")
    @participation.update!(status: "registered")
    @participation.start!
    assert_equal "registered", @participation.reload.status
  end

  test "return! updates status to returned" do
    @participation.return!
    assert_equal "returned", @participation.reload.status
  end

  test "validates status inclusion" do
    @participation.status = "invalid_status"
    assert_not @participation.valid?
    assert_includes @participation.errors[:status], "is not included in the list"
  end
end
