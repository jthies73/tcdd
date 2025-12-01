require "application_system_test_case"

class CigaretteCounterTest < ApplicationSystemTestCase
  def setup
    @clean_up = CleanUp.create!(
      name: "Test Clean-Up",
      description: "Test description",
      status: "started",
      starts_at: 1.hour.from_now,
      address: "Test address"
    )

    @participant = Participant.create!(
      name: "Test Group",
      people_count: 3
    )

    @participation = Participation.create!(
      clean_up: @clean_up,
      participant: @participant,
      status: "started",
      cigarettes_count: 0
    )
  end

  test "participant can view and interact with cigarette counter when cleanup is started" do
    visit show_participation_path(@participation)

    # Verify the cigarette counter is visible
    assert_selector "div[data-controller='cigarette-counter']"
    assert_text "Zigarettenstummel"
    assert_text "Gefundene Stummel zählen"
    assert_text "Automatische Speicherung nach 2 Sekunden"

    # Check the input starts at 0
    counter_input = find("input[data-cigarette-counter-target='input']")
    assert_equal "0", counter_input.value

    # Test increment button updates UI
    find("button[data-action='click->cigarette-counter#increment']").click
    assert_equal "1", counter_input.value

    # Test increment again
    find("button[data-action='click->cigarette-counter#increment']").click
    assert_equal "2", counter_input.value

    # Test decrement button updates UI
    find("button[data-action='click->cigarette-counter#decrement']").click
    assert_equal "1", counter_input.value

    # Decrement cannot go below 0
    find("button[data-action='click->cigarette-counter#decrement']").click
    assert_equal "0", counter_input.value

    find("button[data-action='click->cigarette-counter#decrement']").click
    assert_equal "0", counter_input.value
  end

  test "cigarette counter is not visible when participation is registered" do
    @participation.update!(status: "registered")

    visit show_participation_path(@participation)

    assert_no_selector "div[data-controller='cigarette-counter']"
    assert_no_text "Zigarettenstummel"
  end

  test "admin can view cigarette counts on cleanup detail page" do
    # Add some cigarette counts to participations
    @participation.update!(cigarettes_count: 15)

    participant2 = Participant.create!(name: "Second Group", people_count: 2)
    Participation.create!(
      clean_up: @clean_up,
      participant: participant2,
      status: "started",
      cigarettes_count: 10
    )

    visit admin_clean_up_path(@clean_up)

    # Verify total count summary is displayed
    assert_text "Zigarettenstummel Gesamt"
    assert_text "25"

    # Verify individual counts in table
    within "table" do
      assert_text "Test Group"
      assert_text "15"
      assert_text "Second Group"
      assert_text "10"
    end
  end
end
