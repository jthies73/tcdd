require "application_system_test_case"

class SearchableParticipantSelectTest < ApplicationSystemTestCase
  def setup
    @clean_up = CleanUp.create!(
      name: "Test Clean-Up",
      description: "Test description",
      status: "started",
      starts_at: 1.hour.from_now,
      address: "Test address"
    )

    # Create participants in non-alphabetical order to verify sorting
    @participant_charlie = Participant.create!(name: "Charlie", people_count: 1)
    @participant_alice = Participant.create!(name: "Alice", people_count: 2)
    @participant_bob = Participant.create!(name: "Bob", people_count: 1)
  end

  test "participant selector shows searchable list with alphabetically sorted entries" do
    visit new_participation_path

    # Verify the search input is visible
    assert_selector "input[data-searchable-select-target='input']"

    # Click the search input to show the list
    search_input = find("input[data-searchable-select-target='input']")
    search_input.click

    # Wait for the list to appear (not hidden)
    assert_selector "ul[data-searchable-select-target='list']"
    list = find("ul[data-searchable-select-target='list']")
    assert_not list[:class].include?("hidden"), "List should be visible"

    # Verify participants are in the list and sorted alphabetically by checking data-name attributes
    # Use visible: :all to get all items including those that might be scrolled out of view
    items = all("li[data-searchable-select-target='item']", visible: :all)
    names = items.map { |item| item["data-name"] }

    assert_equal [ "Alice", "Bob", "Charlie" ], names
  end

  test "participant selector filters entries as user types" do
    visit new_participation_path

    search_input = find("input[data-searchable-select-target='input']")
    search_input.click

    # Type a filter query
    search_input.fill_in with: "Ali"

    # Wait a moment for filtering
    sleep 0.1

    # Check that only Alice is visible (not hidden)
    all("li[data-searchable-select-target='item']", visible: :all).each do |item|
      if item["data-name"] == "Alice"
        assert_not item[:class].include?("hidden"), "Alice should be visible"
      else
        assert item[:class].include?("hidden"), "#{item['data-name']} should be hidden"
      end
    end
  end

  test "participant selector shows no results message when filter has no matches" do
    visit new_participation_path

    search_input = find("input[data-searchable-select-target='input']")
    search_input.click

    # Type a filter query with no matches
    search_input.fill_in with: "xyz123"

    # Wait a moment for filtering
    sleep 0.1

    # The no results message should be visible (not hidden)
    no_results = find("li[data-searchable-select-target='noResults']", visible: :all)
    assert_not no_results[:class].include?("hidden"), "No results message should be visible"
    assert_equal "Kein Eintrag gefunden", no_results.text

    # All participant items should be hidden
    all("li[data-searchable-select-target='item']", visible: :all).each do |item|
      assert item[:class].include?("hidden"), "#{item['data-name']} should be hidden"
    end
  end

  test "user can select a participant from the searchable list and register" do
    visit new_participation_path

    search_input = find("input[data-searchable-select-target='input']")
    search_input.click

    # Wait for the list to appear
    assert_selector "ul[data-searchable-select-target='list']"

    # Click on Bob to select him
    find("li[data-searchable-select-target='item'][data-name='Bob']").click

    # Verify the input now shows Bob's name
    assert_equal "Bob", search_input.value

    # Verify the hidden field has Bob's ID
    hidden_field = find("input[data-searchable-select-target='hiddenField']", visible: false)
    assert_equal @participant_bob.id.to_s, hidden_field.value

    # Submit the form
    click_button "Anmelden"

    # Wait for navigation and verify we're on the participation show page
    # The show page shows "Es geht los!" when clean_up is started
    assert_text "Es geht los!", wait: 5
  end

  test "user can filter and then select a participant" do
    visit new_participation_path

    search_input = find("input[data-searchable-select-target='input']")
    search_input.click

    # Type to filter
    search_input.fill_in with: "Char"

    # Wait a moment for filtering
    sleep 0.1

    # Charlie should be the only visible one
    charlie_item = find("li[data-searchable-select-target='item'][data-name='Charlie']", visible: :all)
    assert_not charlie_item[:class].include?("hidden"), "Charlie should be visible"

    # Click on Charlie
    charlie_item.click

    # Verify the input shows Charlie's name
    assert_equal "Charlie", search_input.value

    # Verify the hidden field has Charlie's ID
    hidden_field = find("input[data-searchable-select-target='hiddenField']", visible: false)
    assert_equal @participant_charlie.id.to_s, hidden_field.value

    # Submit the form
    click_button "Anmelden"

    # Wait for navigation and verify we're on the participation show page
    # The show page shows "Es geht los!" when clean_up is started
    assert_text "Es geht los!", wait: 5
  end
end
