require "test_helper"

module Admin
  class CleanUpsControllerTest < ActionDispatch::IntegrationTest
    def setup
      @clean_up = CleanUp.create!(
        name: "Test Clean-Up",
        description: "Test description",
        status: "created",
        starts_at: 1.hour.from_now,
        address: "Test address"
      )
    end

    test "destroy removes the clean up and redirects to index" do
      assert_difference("CleanUp.count", -1) do
        delete admin_clean_up_path(@clean_up)
      end

      assert_redirected_to admin_clean_ups_path
      assert_equal "Clean-Up wurde erfolgreich gelöscht.", flash[:notice]
    end

    test "destroy removes clean up along with its participations" do
      participant = Participant.create!(name: "Test Participant", people_count: 2)
      @clean_up.participations.create!(participant: participant, status: "registered")

      assert_difference("CleanUp.count", -1) do
        assert_difference("Participation.count", -1) do
          delete admin_clean_up_path(@clean_up)
        end
      end

      assert_redirected_to admin_clean_ups_path
    end
  end
end
