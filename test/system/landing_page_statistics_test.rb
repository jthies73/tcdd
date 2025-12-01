require "application_system_test_case"

class LandingPageStatisticsTest < ApplicationSystemTestCase
  test "user sees statistics on landing page when no cleanup is open for registration" do
    # Clear existing data first
    Participation.destroy_all
    CleanUp.destroy_all

    # Create some completed clean ups with participation data
    clean_up1 = CleanUp.create!(
      name: "First Clean-Up",
      status: "ended",
      starts_at: 2.weeks.ago,
      manual_cigarettes_count: 100
    )

    clean_up2 = CleanUp.create!(
      name: "Second Clean-Up",
      status: "ended",
      starts_at: 1.week.ago,
      manual_cigarettes_count: 50
    )

    # Create participants with different group sizes
    participant1 = Participant.create!(name: "Solo Volunteer", people_count: 1)
    participant2 = Participant.create!(name: "Family of Four", people_count: 4)
    participant3 = Participant.create!(name: "Duo Friends", people_count: 2)

    # Create participations with cigarette counts
    clean_up1.participations.create!(
      participant: participant1,
      status: "returned",
      cigarettes_count: 25
    )
    clean_up1.participations.create!(
      participant: participant2,
      status: "returned",
      cigarettes_count: 75
    )
    clean_up2.participations.create!(
      participant: participant3,
      status: "returned",
      cigarettes_count: 50
    )

    # Visit the landing page
    visit root_path

    # Verify we're on the no active clean up page
    assert_text "Aktuell kein Clean-Up geplant"

    # Verify the statistics section is displayed
    assert_text "Unsere bisherigen Erfolge"

    # Verify cigarette count: 25 + 75 + 50 (participations) + 100 + 50 (manual) = 300
    assert_text "300"
    assert_text "Zigaretten gesammelt"

    # Verify participant count: 1 + 4 + 2 = 7
    assert_text "7"
    assert_text "Teilnehmer insgesamt"

    # Verify the Instagram link is still visible
    assert_text "@trashcan_dresden"
  end

  test "user does not see statistics section when no data exists" do
    Participation.destroy_all
    CleanUp.destroy_all

    visit root_path

    # Verify we're on the no active clean up page
    assert_text "Aktuell kein Clean-Up geplant"

    # The statistics section should not be shown when there's no data
    assert_no_text "Unsere bisherigen Erfolge"
    assert_no_text "Zigaretten gesammelt"
    assert_no_text "Teilnehmer insgesamt"
  end

  test "user sees registration page when a cleanup is open for registration" do
    Participation.destroy_all
    CleanUp.destroy_all

    # Create an active clean up
    CleanUp.create!(
      name: "Active Clean-Up",
      status: "registration_enabled",
      starts_at: 1.hour.from_now
    )

    visit root_path

    # Verify we're on the registration page, not the no active clean up page
    assert_no_text "Aktuell kein Clean-Up geplant"
    assert_text "Active Clean-Up"
  end
end
