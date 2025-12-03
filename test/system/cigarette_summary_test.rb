require "application_system_test_case"

class CigaretteSummaryTest < ApplicationSystemTestCase
  def setup
    @clean_up = CleanUp.create!(
      name: "Test Clean-Up",
      description: "Test description",
      status: "started",
      starts_at: 1.hour.ago,
      address: "Test address"
    )

    @participant1 = Participant.create!(
      name: "Test Group 1",
      people_count: 2
    )

    @participant2 = Participant.create!(
      name: "Test Group 2",
      people_count: 3
    )
  end

  test "displays total cigarette summary with encouraging message on returned status" do
    # Create participations with cigarette counts
    participation1 = Participation.create!(
      clean_up: @clean_up,
      participant: @participant1,
      status: "returned",
      cigarettes_count: 300
    )

    Participation.create!(
      clean_up: @clean_up,
      participant: @participant2,
      status: "returned",
      cigarettes_count: 250
    )

    visit show_participation_path(participation1)

    # Verify the total summary section is displayed
    assert_text "Gemeinsam gesammelt"
    
    # Verify total count is shown (300 + 250 = 550)
    assert_text "550"
    
    # Verify encouraging message for 500-999 range
    assert_text "Fantastische Arbeit! Ihr seid großartig!"
    assert_text "Ihr macht Dresden sauberer! 💚"
  end

  test "displays appropriate message for small count" do
    participation = Participation.create!(
      clean_up: @clean_up,
      participant: @participant1,
      status: "returned",
      cigarettes_count: 50
    )

    visit show_participation_path(participation)

    assert_text "Gemeinsam gesammelt"
    assert_text "50"
    assert_text "Jede Kippe zählt! Weiter so!"
  end

  test "displays appropriate message for medium count" do
    participation1 = Participation.create!(
      clean_up: @clean_up,
      participant: @participant1,
      status: "returned",
      cigarettes_count: 150
    )

    Participation.create!(
      clean_up: @clean_up,
      participant: @participant2,
      status: "returned",
      cigarettes_count: 100
    )

    visit show_participation_path(participation1)

    assert_text "Gemeinsam gesammelt"
    assert_text "250"
    assert_text "Super Leistung! Gemeinsam schaffen wir mehr!"
  end

  test "displays appropriate message for large count" do
    participation1 = Participation.create!(
      clean_up: @clean_up,
      participant: @participant1,
      status: "returned",
      cigarettes_count: 600
    )

    Participation.create!(
      clean_up: @clean_up,
      participant: @participant2,
      status: "returned",
      cigarettes_count: 500
    )

    visit show_participation_path(participation1)

    assert_text "Gemeinsam gesammelt"
    assert_text "1.100"
    assert_text "Über 1.000 Kippen gesammelt! Unglaublich!"
  end

  test "displays appropriate message for very large count" do
    participation = Participation.create!(
      clean_up: @clean_up,
      participant: @participant1,
      status: "returned",
      cigarettes_count: 2500
    )

    visit show_participation_path(participation)

    assert_text "Gemeinsam gesammelt"
    assert_text "2.500"
    assert_text "Herausragende Leistung! Ihr seid Helden!"
  end

  test "does not display summary when total is zero" do
    participation = Participation.create!(
      clean_up: @clean_up,
      participant: @participant1,
      status: "returned",
      cigarettes_count: 0
    )

    visit show_participation_path(participation)

    assert_no_text "Gemeinsam gesammelt"
  end

  test "includes manual cigarettes count in total" do
    @clean_up.update!(manual_cigarettes_count: 200)

    participation = Participation.create!(
      clean_up: @clean_up,
      participant: @participant1,
      status: "returned",
      cigarettes_count: 300
    )

    visit show_participation_path(participation)

    assert_text "Gemeinsam gesammelt"
    # Total should be 300 (from participation) + 200 (manual) = 500
    assert_text "500"
    assert_text "Fantastische Arbeit! Ihr seid großartig!"
  end
end
