require "application_system_test_case"

class CigaretteCounterTest < ApplicationSystemTestCase
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

    @participation = Participation.create!(
      clean_up: @clean_up,
      participant: @participant,
      status: "started",
      cigarettes_count: 5
    )
  end

  test "counter only visible when participation is started" do
    # Counter should be visible when started
    visit show_participation_path(@participation)
    assert_selector "h2", text: "Gesammelte Zigaretten"

    # Counter should not be visible when registered
    @participation.update!(status: "registered")
    visit show_participation_path(@participation)
    assert_no_selector "h2", text: "Gesammelte Zigaretten"

    # Counter should not be visible when returned
    @participation.update!(status: "returned")
    visit show_participation_path(@participation)
    assert_no_selector "h2", text: "Gesammelte Zigaretten"
  end

  test "increment button increases count" do
    visit show_participation_path(@participation)

    # Initial count should be 5
    input = find("input[data-cigarette-counter-target='input']")
    assert_equal "5", input.value

    # Click increment button (plus button is the second button)
    increment_button = find("button[data-action='click->cigarette-counter#increment']")
    increment_button.click

    # Count should be 6
    assert_equal "6", input.value
  end

  test "decrement button decreases count" do
    visit show_participation_path(@participation)

    input = find("input[data-cigarette-counter-target='input']")
    assert_equal "5", input.value

    # Click decrement button
    decrement_button = find("button[data-action='click->cigarette-counter#decrement']")
    decrement_button.click

    # Count should be 4
    assert_equal "4", input.value
  end

  test "decrement button stops at zero" do
    @participation.update!(cigarettes_count: 0)
    visit show_participation_path(@participation)

    input = find("input[data-cigarette-counter-target='input']")
    assert_equal "0", input.value

    # Click decrement button multiple times
    decrement_button = find("button[data-action='click->cigarette-counter#decrement']")
    3.times { decrement_button.click }

    # Count should still be 0
    assert_equal "0", input.value
  end

  test "direct input updates count" do
    visit show_participation_path(@participation)

    input = find("input[data-cigarette-counter-target='input']")

    # Clear and enter new value
    input.fill_in(with: "42")

    # Trigger change event
    input.native.send_keys(:tab)

    # Count should be updated
    assert_equal "42", input.value
  end

  test "complete workflow: user increments, decrements, and manually updates count" do
    visit show_participation_path(@participation)

    # Verify initial state
    assert_selector "h1", text: "Das CleanUp läuft"
    assert_selector "h2", text: "Gesammelte Zigaretten"

    input = find("input[data-cigarette-counter-target='input']")
    assert_equal "5", input.value

    # Increment twice
    increment_button = find("button[data-action='click->cigarette-counter#increment']")
    2.times { increment_button.click }
    assert_equal "7", input.value

    # Decrement once
    decrement_button = find("button[data-action='click->cigarette-counter#decrement']")
    decrement_button.click
    assert_equal "6", input.value

    # Manually enter a value
    input.fill_in(with: "100")
    input.native.send_keys(:tab)
    assert_equal "100", input.value

    # Wait for debounce and verify database update using polling
    Timeout.timeout(5) do
      loop do
        @participation.reload
        break if @participation.cigarettes_count == 100
        sleep 0.5
      end
    end

    # Reload page to verify persistence
    visit show_participation_path(@participation)
    input = find("input[data-cigarette-counter-target='input']")
    assert_equal "100", input.value
  end
end
