require "application_system_test_case"

class ShareLinkTest < ApplicationSystemTestCase
  def setup
    @clean_up = CleanUp.create!(
      name: "Test Clean-Up",
      description: "Test description",
      status: "registration_enabled",
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
      status: "registered",
      cigarettes_count: 0
    )
  end

  test "participant sees share link info box when registered and pending" do
    visit show_participation_path(@participation)

    # Verify the share link info box is visible
    assert_text "Tipp:"
    assert_text "Speichere diesen Link, um später wieder auf diese Seite zu gelangen."

    # Verify the copy button is present
    assert_selector "button", text: "Kopieren"

    # Verify the share link input contains the correct URL
    share_input = find("input[data-clipboard-target='source']")
    assert_includes share_input.value, "/go/#{@participation.id}"
  end

  test "participant sees group sharing info box when cleanup is started" do
    # Start the clean up and participation
    @clean_up.update!(status: "started")
    @participation.update!(status: "started", started_at: Time.current)

    visit show_participation_path(@participation)

    # Verify the group sharing info box is visible
    assert_text "Gruppenfunktion:"
    assert_text "Teile diesen Link mit deiner Gruppe – alle können gemeinsam Kippen zählen!"

    # Verify the copy button is present
    assert_selector "button", text: "Kopieren"

    # Verify the share link input contains the correct URL
    share_input = find("input[data-clipboard-target='source']")
    assert_includes share_input.value, "/go/#{@participation.id}"
  end
end
