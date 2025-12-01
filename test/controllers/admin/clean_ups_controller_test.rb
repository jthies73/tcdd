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

    test "add_cigarettes adds to manual cigarettes count" do
      @clean_up.update!(status: "started")
      assert_equal 0, @clean_up.manual_cigarettes_count

      post add_cigarettes_admin_clean_up_path(@clean_up), params: { amount: 15 }

      @clean_up.reload
      assert_equal 15, @clean_up.manual_cigarettes_count
    end

    test "add_cigarettes accumulates when called multiple times" do
      @clean_up.update!(status: "started")

      post add_cigarettes_admin_clean_up_path(@clean_up), params: { amount: 10 }
      post add_cigarettes_admin_clean_up_path(@clean_up), params: { amount: 5 }

      @clean_up.reload
      assert_equal 15, @clean_up.manual_cigarettes_count
    end

    test "add_cigarettes does not add negative amounts" do
      @clean_up.update!(status: "started", manual_cigarettes_count: 10)

      post add_cigarettes_admin_clean_up_path(@clean_up), params: { amount: -5 }

      @clean_up.reload
      assert_equal 10, @clean_up.manual_cigarettes_count
    end

    test "add_cigarettes does not add zero amount" do
      @clean_up.update!(status: "started", manual_cigarettes_count: 10)

      post add_cigarettes_admin_clean_up_path(@clean_up), params: { amount: 0 }

      @clean_up.reload
      assert_equal 10, @clean_up.manual_cigarettes_count
    end

    test "add_cigarettes responds with turbo_stream" do
      @clean_up.update!(status: "started")

      post add_cigarettes_admin_clean_up_path(@clean_up),
           params: { amount: 5 },
           headers: { "Accept" => "text/vnd.turbo-stream.html" }

      assert_response :success
      assert_match "turbo-stream", response.body
    end

    test "add_cigarettes stores the last amount for revert" do
      @clean_up.update!(status: "started")

      post add_cigarettes_admin_clean_up_path(@clean_up), params: { amount: 15 }

      @clean_up.reload
      assert_equal 15, @clean_up.last_manual_cigarettes_amount
    end

    test "revert_cigarettes reverts the last added amount" do
      @clean_up.update!(status: "started", manual_cigarettes_count: 25, last_manual_cigarettes_amount: 10)

      post revert_cigarettes_admin_clean_up_path(@clean_up)

      @clean_up.reload
      assert_equal 15, @clean_up.manual_cigarettes_count
      assert_equal 0, @clean_up.last_manual_cigarettes_amount
    end

    test "revert_cigarettes does nothing when no previous addition" do
      @clean_up.update!(status: "started", manual_cigarettes_count: 25, last_manual_cigarettes_amount: 0)

      post revert_cigarettes_admin_clean_up_path(@clean_up)

      @clean_up.reload
      assert_equal 25, @clean_up.manual_cigarettes_count
    end

    test "revert_cigarettes responds with turbo_stream" do
      @clean_up.update!(status: "started", manual_cigarettes_count: 15, last_manual_cigarettes_amount: 5)

      post revert_cigarettes_admin_clean_up_path(@clean_up),
           headers: { "Accept" => "text/vnd.turbo-stream.html" }

      assert_response :success
      assert_match "turbo-stream", response.body
    end
  end
end
