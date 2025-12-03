require "application_system_test_case"

class ReturningParticipantConfirmationTest < ApplicationSystemTestCase
  def setup
    @clean_up = CleanUp.create!(
      name: "Test Clean-Up",
      description: "Test description",
      status: "registration_enabled",
      starts_at: 1.hour.from_now,
      address: "Test address"
    )

    @participant = Participant.create!(
      name: "Alice",
      people_count: 2
    )
  end

  test "returning participant can confirm and adjust people count before registering using modal" do
    visit new_participation_path

    # Step 1: Select participant from the searchable list
    search_input = find("input[data-searchable-select-target='input']")
    search_input.click

    # Wait for the list to appear
    assert_selector "ul[data-searchable-select-target='list']"

    # Click on Alice to select
    find("li[data-searchable-select-target='item'][data-name='Alice']").click

    # Verify the input shows Alice's name
    assert_equal "Alice", search_input.value

    # Step 2: Click "Weiter" button to open the modal
    click_button "Weiter"

    # Step 3: Verify the modal is visible
    assert_selector "[data-controller='people-count-modal']:not(.hidden)", wait: 5
    assert_text "Wie viele Personen seid ihr?"

    # Verify the people count shows current value
    within "[data-controller='people-count-modal']" do
      people_count_input = find("input[data-people-counter-target='input']")
      assert_equal "2", people_count_input.value

      # Step 4: Adjust people count using + button
      increment_button = find("button[data-action*='people-counter#increment']")
      increment_button.click
      increment_button.click # Click twice to increase by 2

      # Verify the count increased
      assert_equal "4", people_count_input.value

      # Step 5: Decrease count using - button
      decrement_button = find("button[data-action*='people-counter#decrement']")
      decrement_button.click

      # Verify the count decreased
      assert_equal "3", people_count_input.value

      # Step 6: Click "Bestätigen" button to complete registration
      click_button "Bestätigen"
    end

    # Step 7: Verify we're redirected to the participation show page
    assert_text "Es geht los!", wait: 5

    # Step 8: Verify the participant's people_count was updated in the database
    assert_equal 3, @participant.reload.people_count

    # Step 9: Verify a participation was created
    participation = Participation.last
    assert_equal @participant.id, participation.participant_id
    assert_equal @clean_up.id, participation.clean_up_id
    assert_equal "registered", participation.status
  end

  test "modal can be cancelled without creating participation" do
    visit new_participation_path

    # Select participant
    search_input = find("input[data-searchable-select-target='input']")
    search_input.click
    find("li[data-searchable-select-target='item'][data-name='Alice']").click

    # Open modal
    click_button "Weiter"

    # Verify modal is visible
    assert_selector "[data-controller='people-count-modal']:not(.hidden)", wait: 5

    # Click cancel button
    within "[data-controller='people-count-modal']" do
      click_button "Abbrechen"
    end

    # Verify modal is hidden
    assert_selector "[data-controller='people-count-modal'].hidden", wait: 5

    # Verify we're still on the registration page
    assert_text "Schon mal dabei gewesen?"

    # Verify no participation was created
    assert_equal 0, Participation.count
  end

  test "new participation page shows cleanup info and registration cards for active cleanup" do
    visit new_participation_path

    # Verify cleanup info is displayed
    assert_text "Nächster Clean-Up", wait: 5
    assert_text @clean_up.name

    # Verify returning participant section is displayed
    assert_text "Schon mal dabei gewesen?"
    assert_selector "input[data-searchable-select-target='input']"

    # Verify new participant section is displayed
    assert_text "Zum ersten Mal hier?"
    assert_selector "input[name='participant_name']"
  end
end
