require "test_helper"

class ParticipationTest < ActiveSupport::TestCase
  def setup
    @clean_up = CleanUp.create!(
      name: "Test Clean-Up",
      description: "Test description",
      status: "started",
      starts_at: 1.hour.ago,
      address: "Test address"
    )

    @participant = Participant.create!(
      name: "John Doe",
      people_count: 2
    )
  end

  test "cigarettes_count validation allows nil" do
    participation = Participation.new(
      clean_up: @clean_up,
      participant: @participant,
      status: "registered",
      cigarettes_count: nil
    )

    assert participation.valid?
  end

  test "cigarettes_count validation allows zero" do
    participation = Participation.new(
      clean_up: @clean_up,
      participant: @participant,
      status: "registered",
      cigarettes_count: 0
    )

    assert participation.valid?
  end

  test "cigarettes_count validation allows positive values" do
    participation = Participation.new(
      clean_up: @clean_up,
      participant: @participant,
      status: "registered",
      cigarettes_count: 100
    )

    assert participation.valid?
  end

  test "cigarettes_count validation rejects negative values" do
    participation = Participation.new(
      clean_up: @clean_up,
      participant: @participant,
      status: "registered",
      cigarettes_count: -1
    )

    assert_not participation.valid?
    assert_includes participation.errors[:cigarettes_count], "must be greater than or equal to 0"
  end

  test "total_cigarettes_for_clean_up returns sum of all participation cigarettes" do
    participant2 = Participant.create!(name: "Jane Smith", people_count: 1)
    participant3 = Participant.create!(name: "Bob Wilson", people_count: 1)

    Participation.create!(
      clean_up: @clean_up,
      participant: @participant,
      status: "started",
      cigarettes_count: 10
    )

    Participation.create!(
      clean_up: @clean_up,
      participant: participant2,
      status: "started",
      cigarettes_count: 15
    )

    Participation.create!(
      clean_up: @clean_up,
      participant: participant3,
      status: "started",
      cigarettes_count: 25
    )

    assert_equal 50, Participation.total_cigarettes_for_clean_up(@clean_up)
  end

  test "total_cigarettes_for_clean_up handles nil cigarettes_count" do
    participant2 = Participant.create!(name: "Jane Smith", people_count: 1)

    Participation.create!(
      clean_up: @clean_up,
      participant: @participant,
      status: "started",
      cigarettes_count: 10
    )

    Participation.create!(
      clean_up: @clean_up,
      participant: participant2,
      status: "started",
      cigarettes_count: nil
    )

    assert_equal 10, Participation.total_cigarettes_for_clean_up(@clean_up)
  end

  test "total_cigarettes_for_clean_up returns zero when no participations" do
    other_clean_up = CleanUp.create!(
      name: "Other Clean-Up",
      description: "Other description",
      status: "created",
      starts_at: 1.day.from_now,
      address: "Other address"
    )

    assert_equal 0, Participation.total_cigarettes_for_clean_up(other_clean_up)
  end

  test "total_cigarettes_for_clean_up only counts participations for specified clean_up" do
    other_clean_up = CleanUp.create!(
      name: "Other Clean-Up",
      description: "Other description",
      status: "started",
      starts_at: 1.day.from_now,
      address: "Other address"
    )

    other_participant = Participant.create!(name: "Other Person", people_count: 1)

    # Participation for the main clean_up
    Participation.create!(
      clean_up: @clean_up,
      participant: @participant,
      status: "started",
      cigarettes_count: 10
    )

    # Participation for another clean_up (should not be counted)
    Participation.create!(
      clean_up: other_clean_up,
      participant: other_participant,
      status: "started",
      cigarettes_count: 100
    )

    assert_equal 10, Participation.total_cigarettes_for_clean_up(@clean_up)
  end
end
