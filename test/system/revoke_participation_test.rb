require "application_system_test_case"

class RevokeParticipationTest < ApplicationSystemTestCase
  def setup
    @clean_up = CleanUp.create!(
      name: "Test Clean-Up",
      description: "Test description",
      status: "registration_enabled",
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
      status: "registered",
      cigarettes_count: 0
    )
  end

  test "user can revoke participation from pending registered page" do
    # Visit the participation page
    visit show_participation_path(@participation)

    # Verify the pending registered page is shown
    assert_text "Anmeldung erfolgreich!"
    assert_text "Danke für deine Anmeldung!"

    # Verify the revoke link is present
    assert_selector "button", text: "Teilnahme stornieren"

    # Click the revoke link
    click_button "Teilnahme stornieren"

    # Verify the confirmation modal appears
    assert_text "Teilnahme stornieren"
    assert_text "Bist du sicher, dass du deine Teilnahme stornieren möchtest?"

    # Confirm the cancellation
    click_button "Ja, stornieren"

    # Verify redirect to farewell page
    assert_current_path farewell_path
    assert_text "Schade, dass du nicht dabei sein kannst!"
    assert_text "Deine Anmeldung wurde erfolgreich storniert"

    # Verify participation was deleted
    assert_nil Participation.find_by(id: @participation.id)
  end

  test "user can cancel revoke participation in modal" do
    visit show_participation_path(@participation)

    # Click the revoke link
    click_button "Teilnahme stornieren"

    # Verify the confirmation modal appears
    assert_text "Teilnahme stornieren"

    # Cancel the revocation
    click_button "Nein, zurück"

    # Verify the modal is closed and we're still on the participation page
    assert_text "Danke für deine Anmeldung!"

    # Verify participation still exists
    assert Participation.find_by(id: @participation.id)
  end

  test "revoke link is not shown when clean-up has started" do
    @clean_up.update!(status: "started")

    visit show_participation_path(@participation)

    # The page should show the "ready to start" state instead of pending
    assert_text "Der Clean-Up hat begonnen!"

    # Revoke link should not be present
    assert_no_selector "button", text: "Teilnahme stornieren"
  end

  test "farewell page has link back to homepage" do
    visit farewell_path

    assert_text "Schade, dass du nicht dabei sein kannst!"
    assert_selector "a", text: "Zurück zur Startseite"

    click_link "Zurück zur Startseite"
    # The root path redirects to new_participation_path (/go)
    assert_current_path new_participation_path
  end
end
