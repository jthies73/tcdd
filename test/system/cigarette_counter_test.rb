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

  test "admin can manually add cigarettes to the total count" do
    # Add some cigarette counts from participations
    @participation.update!(cigarettes_count: 15)

    visit admin_clean_up_path(@clean_up)

    # Verify initial total count summary is displayed
    assert_text "Zigarettenstummel Gesamt"
    assert_text "15"

    # Verify the manual addition form is visible
    within "#admin_cigarettes_summary_#{@clean_up.id}" do
      assert_selector "input[name='amount']"
      assert_selector "button[type='submit']", text: "Hinzufügen"

      # Set the amount to add
      fill_in "amount", with: 10

      # Click the add button
      click_button "Hinzufügen"
    end

    # Verify the total count is updated (15 from participation + 10 manual = 25)
    within "#admin_cigarettes_summary_#{@clean_up.id}" do
      assert_text "25"
    end

    # Add more manually
    within "#admin_cigarettes_summary_#{@clean_up.id}" do
      fill_in "amount", with: 5
      click_button "Hinzufügen"
    end

    # Verify the accumulated total (15 + 10 + 5 = 30)
    within "#admin_cigarettes_summary_#{@clean_up.id}" do
      assert_text "30"
    end

    # Verify the database was updated
    @clean_up.reload
    assert_equal 15, @clean_up.manual_cigarettes_count
    assert_equal 30, @clean_up.total_cigarettes_count
  end
end
