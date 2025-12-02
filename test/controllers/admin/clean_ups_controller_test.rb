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

    test "revert_status transitions registration_enabled to created and redirects to show" do
      @clean_up.update!(status: "registration_enabled")

      post revert_status_admin_clean_up_path(@clean_up)

      @clean_up.reload
      assert_equal "created", @clean_up.status
      assert_redirected_to admin_clean_up_path(@clean_up)
    end

    test "revert_status transitions started to registration_enabled and redirects to show" do
      @clean_up.update!(status: "started")

      post revert_status_admin_clean_up_path(@clean_up)

      @clean_up.reload
      assert_equal "registration_enabled", @clean_up.status
      assert_redirected_to admin_clean_up_path(@clean_up)
    end

    test "revert_status transitions ended to started and redirects to show" do
      @clean_up.update!(status: "ended")

      post revert_status_admin_clean_up_path(@clean_up)

      @clean_up.reload
      assert_equal "started", @clean_up.status
      assert_redirected_to admin_clean_up_path(@clean_up)
    end

    test "update updates clean up name and redirects to show" do
      patch admin_clean_up_path(@clean_up), params: {
        clean_up: { name: "Updated Name" }
      }

      @clean_up.reload
      assert_equal "Updated Name", @clean_up.name
      assert_redirected_to admin_clean_up_path(@clean_up)
      assert_equal "Clean-Up wurde erfolgreich aktualisiert.", flash[:notice]
    end

    test "update updates clean up description" do
      patch admin_clean_up_path(@clean_up), params: {
        clean_up: { description: "Updated description" }
      }

      @clean_up.reload
      assert_equal "Updated description", @clean_up.description
      assert_redirected_to admin_clean_up_path(@clean_up)
    end

    test "update updates clean up address" do
      patch admin_clean_up_path(@clean_up), params: {
        clean_up: { address: "New Address 123" }
      }

      @clean_up.reload
      assert_equal "New Address 123", @clean_up.address
      assert_redirected_to admin_clean_up_path(@clean_up)
    end

    test "update updates clean up date and time" do
      patch admin_clean_up_path(@clean_up), params: {
        clean_up: { date: "2025-06-15", time: "14:30" }
      }

      @clean_up.reload
      berlin_time = @clean_up.starts_at.in_time_zone("Europe/Berlin")
      assert_equal 2025, berlin_time.year
      assert_equal 6, berlin_time.month
      assert_equal 15, berlin_time.day
      assert_equal 14, berlin_time.hour
      assert_equal 30, berlin_time.min
      assert_redirected_to admin_clean_up_path(@clean_up)
    end

    test "update updates multiple fields at once" do
      patch admin_clean_up_path(@clean_up), params: {
        clean_up: {
          name: "Multi Update",
          description: "Multi description",
          address: "Multi address",
          date: "2025-07-20",
          time: "10:00"
        }
      }

      @clean_up.reload
      assert_equal "Multi Update", @clean_up.name
      assert_equal "Multi description", @clean_up.description
      assert_equal "Multi address", @clean_up.address
      berlin_time = @clean_up.starts_at.in_time_zone("Europe/Berlin")
      assert_equal 2025, berlin_time.year
      assert_equal 7, berlin_time.month
      assert_equal 20, berlin_time.day
      assert_redirected_to admin_clean_up_path(@clean_up)
    end

    test "update with invalid name renders show with unprocessable entity status" do
      patch admin_clean_up_path(@clean_up), params: {
        clean_up: { name: "" }
      }

      assert_response :unprocessable_entity
    end

    test "update with invalid date format renders show with unprocessable entity status" do
      patch admin_clean_up_path(@clean_up), params: {
        clean_up: { date: "invalid-date" }
      }

      assert_response :unprocessable_entity
    end
  end
end
