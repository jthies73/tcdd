require "application_system_test_case"

class HalloMertenBannerTest < ApplicationSystemTestCase
  test "user sees Hallo Merten banner on home page" do
    # Create an active clean up to ensure the home page shows the registration view
    CleanUp.create!(
      name: "Test Clean-Up",
      description: "Test description",
      status: "registration_enabled",
      starts_at: 1.hour.from_now,
      address: "Test address"
    )

    # Visit the home page
    visit root_path

    # Verify the Hallo Merten banner is displayed
    assert_text "Hallo Merten"
  end
end
