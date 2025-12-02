require "test_helper"

class CleanUpsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @clean_up = CleanUp.create!(
      name: "Test Clean-Up",
      description: "Test description for the cleanup event",
      status: "started",
      starts_at: Time.zone.parse("2024-06-15 14:00:00"),
      address: "Altmarkt Dresden"
    )
  end

  test "calendar returns a valid iCalendar file" do
    get calendar_clean_up_path(@clean_up)

    assert_response :success
    assert_includes response.body, "BEGIN:VCALENDAR"
    assert_includes response.body, "END:VCALENDAR"
    assert_includes response.body, "BEGIN:VEVENT"
    assert_includes response.body, "END:VEVENT"
  end

  test "calendar returns text/calendar content type" do
    get calendar_clean_up_path(@clean_up)

    assert_response :success
    assert_equal "text/calendar", response.media_type
  end

  test "calendar contains correct event name" do
    get calendar_clean_up_path(@clean_up)

    assert_response :success
    assert_includes response.body, "SUMMARY:Test Clean-Up"
  end

  test "calendar contains correct event description" do
    get calendar_clean_up_path(@clean_up)

    assert_response :success
    assert_includes response.body, "DESCRIPTION:Test description for the cleanup event"
  end

  test "calendar contains correct event location" do
    get calendar_clean_up_path(@clean_up)

    assert_response :success
    assert_includes response.body, "LOCATION:Altmarkt Dresden"
  end

  test "calendar contains start and end times" do
    get calendar_clean_up_path(@clean_up)

    assert_response :success
    assert_includes response.body, "DTSTART:"
    assert_includes response.body, "DTEND:"
  end

  test "calendar event has 2 hour duration" do
    get calendar_clean_up_path(@clean_up)

    assert_response :success

    # Extract start and end times from the calendar
    start_match = response.body.match(/DTSTART:(\d{8}T\d{6}Z)/)
    end_match = response.body.match(/DTEND:(\d{8}T\d{6}Z)/)

    assert start_match, "DTSTART not found in calendar"
    assert end_match, "DTEND not found in calendar"

    start_time = Time.strptime(start_match[1], "%Y%m%dT%H%M%SZ")
    end_time = Time.strptime(end_match[1], "%Y%m%dT%H%M%SZ")

    assert_equal 2.hours, end_time - start_time
  end

  test "calendar filename contains clean up name" do
    get calendar_clean_up_path(@clean_up)

    assert_response :success
    assert_match(/filename="test-clean-up\.ics"/, response.headers["Content-Disposition"])
  end

  test "calendar escapes special characters in text" do
    @clean_up.update!(
      name: "Clean-Up, with; special\\chars",
      description: "Line one\nLine two"
    )

    get calendar_clean_up_path(@clean_up)

    assert_response :success
    # Backslash is escaped to \\ in iCal, comma to \, semicolon to \;
    assert_includes response.body, "SUMMARY:Clean-Up\\, with\\; special\\\\chars"
    assert_includes response.body, "DESCRIPTION:Line one\\nLine two"
  end

  test "calendar includes participation link when participation_id is provided" do
    participant = Participant.create!(name: "Test Participant", people_count: 1)
    participation = Participation.create!(
      clean_up: @clean_up,
      participant: participant,
      status: "registered"
    )

    get calendar_clean_up_path(@clean_up, participation_id: participation.id)

    assert_response :success
    assert_includes response.body, "Dein Teilnahme-Link:"
    assert_includes response.body, "/go/#{participation.id}"
  end

  test "calendar includes both description and participation link when both are present" do
    participant = Participant.create!(name: "Test Participant", people_count: 1)
    participation = Participation.create!(
      clean_up: @clean_up,
      participant: participant,
      status: "registered"
    )

    get calendar_clean_up_path(@clean_up, participation_id: participation.id)

    assert_response :success
    assert_includes response.body, "Test description for the cleanup event"
    assert_includes response.body, "Dein Teilnahme-Link:"
  end

  test "calendar does not include participation link when participation_id is not provided" do
    get calendar_clean_up_path(@clean_up)

    assert_response :success
    assert_not_includes response.body, "Dein Teilnahme-Link:"
  end

  test "calendar handles invalid participation_id gracefully" do
    get calendar_clean_up_path(@clean_up, participation_id: 99999)

    assert_response :success
    assert_not_includes response.body, "Dein Teilnahme-Link:"
  end

  test "calendar does not include participation link when participation belongs to different clean_up" do
    other_clean_up = CleanUp.create!(
      name: "Other Clean-Up",
      description: "Other description",
      status: "started",
      starts_at: Time.zone.parse("2024-06-20 14:00:00"),
      address: "Other location"
    )

    participant = Participant.create!(name: "Test Participant", people_count: 1)
    participation = Participation.create!(
      clean_up: other_clean_up,
      participant: participant,
      status: "registered"
    )

    # Request calendar for @clean_up but pass participation from other_clean_up
    get calendar_clean_up_path(@clean_up, participation_id: participation.id)

    assert_response :success
    assert_not_includes response.body, "Dein Teilnahme-Link:"
  end
end
