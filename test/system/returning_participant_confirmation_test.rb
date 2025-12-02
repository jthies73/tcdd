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

  test "returning participant can confirm and adjust people count before registering" do
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

    # Step 2: Click "Weiter" button to go to confirmation page
    click_button "Weiter"

    # Step 3: Verify we're on the confirmation page
    assert_text "Teilnahme bestätigen", wait: 5
    assert_text "Alice"

    # Verify the people count shows current value
    people_count_input = find("input[name='participant_people_count']")
    assert_equal "2", people_count_input.value

    # Step 4: Adjust people count using + button
    increment_button = find("button[data-action='click->people-counter#increment']")
    increment_button.click
    increment_button.click # Click twice to increase by 2

    # Verify the count increased
    assert_equal "4", people_count_input.value

    # Step 5: Decrease count using - button
    decrement_button = find("button[data-action='click->people-counter#decrement']")
    decrement_button.click

    # Verify the count decreased
    assert_equal "3", people_count_input.value

    # Step 6: Try to go below 1 (should not work)
    2.times { decrement_button.click }

    # Should stop at 1
    assert_equal "1", people_count_input.value

    # Try one more time - should still be 1
    decrement_button.click
    assert_equal "1", people_count_input.value

    # Step 7: Set back to a reasonable number and submit
    2.times { increment_button.click }
    assert_equal "3", people_count_input.value

    # Step 8: Click "Bestätigen" button to complete registration
    click_button "Bestätigen"

    # Step 9: Verify we're redirected to the participation show page
    assert_text "Es geht los!", wait: 5

    # Step 10: Verify the participant's people_count was updated in the database
    assert_equal 3, @participant.reload.people_count

    # Step 11: Verify a participation was created
    participation = Participation.last
    assert_equal @participant.id, participation.participant_id
    assert_equal @clean_up.id, participation.clean_up_id
    assert_equal "registered", participation.status
  end

  test "returning participant can use back button to return to registration page" do
    visit new_participation_path

    # Select participant
    search_input = find("input[data-searchable-select-target='input']")
    search_input.click
    find("li[data-searchable-select-target='item'][data-name='Alice']").click

    # Go to confirmation page
    click_button "Weiter"
    assert_text "Teilnahme bestätigen", wait: 5

    # Click back button
    click_link "Zurück"

    # Verify we're back on the registration page
    assert_text "Schon mal dabei gewesen?", wait: 5
    assert_selector "input[data-searchable-select-target='input']"
  end

  test "confirmation page shows clean-up details" do
    visit new_participation_path

    # Select participant and go to confirmation
    search_input = find("input[data-searchable-select-target='input']")
    search_input.click
    find("li[data-searchable-select-target='item'][data-name='Alice']").click
    click_button "Weiter"

    # Verify clean-up information is displayed
    assert_text "Clean-Up Details", wait: 5
    assert_text @clean_up.name
    assert_text @clean_up.address
  end

  test "confirmation page allows manual input of people count" do
    visit new_participation_path

    # Select participant and go to confirmation
    search_input = find("input[data-searchable-select-target='input']")
    search_input.click
    find("li[data-searchable-select-target='item'][data-name='Alice']").click
    click_button "Weiter"

    # Manually type a people count
    people_count_input = find("input[name='participant_people_count']")
    people_count_input.fill_in with: "5"

    # Submit
    click_button "Bestätigen"

    # Verify success
    assert_text "Es geht los!", wait: 5

    # Verify the count was updated
    assert_equal 5, @participant.reload.people_count
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
