require "test_helper"

class ParticipationsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @clean_up = CleanUp.create!(
      name: "Test Clean-Up",
      description: "Test description",
      status: "started",
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
      status: "started",
      cigarettes_count: 0
    )
  end

  test "update_cigarettes_count updates the count successfully" do
    patch update_cigarettes_count_participation_path(@participation),
      params: { cigarettes_count: 10 },
      as: :json

    assert_response :success
    assert_equal 10, @participation.reload.cigarettes_count
  end

  test "update_cigarettes_count responds with turbo_stream" do
    patch update_cigarettes_count_participation_path(@participation),
      params: { cigarettes_count: 5 },
      headers: { "Accept" => "text/vnd.turbo-stream.html, text/html, application/xhtml+xml" }

    assert_response :success
    assert_equal 5, @participation.reload.cigarettes_count
  end

  test "update_cigarettes_count normalizes negative values to zero" do
    patch update_cigarettes_count_participation_path(@participation),
      params: { cigarettes_count: -5 },
      as: :json

    assert_response :success
    assert_equal 0, @participation.reload.cigarettes_count
  end

  test "update_cigarettes_count returns unprocessable_entity when participation is not started" do
    @participation.update!(status: "registered")

    patch update_cigarettes_count_participation_path(@participation),
      params: { cigarettes_count: 10 },
      as: :json

    assert_response :unprocessable_entity
  end

  test "update_cigarettes_count returns unprocessable_entity when participation is returned" do
    @participation.update!(status: "returned")

    patch update_cigarettes_count_participation_path(@participation),
      params: { cigarettes_count: 10 },
      as: :json

    assert_response :unprocessable_entity
  end

  test "show displays participation details" do
    get show_participation_path(@participation)
    assert_response :success
  end

  test "show displays cigarettes counter when participation is started" do
    get show_participation_path(@participation)
    assert_response :success
    assert_select "div[data-controller='cigarette-counter']"
  end

  test "show does not display cigarettes counter when participation is registered" do
    @participation.update!(status: "registered")
    get show_participation_path(@participation)
    assert_response :success
    assert_select "div[data-controller='cigarette-counter']", count: 0
  end

  test "new shows no_active_clean_up page when no clean up exists" do
    Participation.destroy_all
    CleanUp.destroy_all

    get new_participation_path
    assert_response :success
    assert_select "h2", text: "Aktuell kein Clean-Up geplant"
  end

  test "new shows no_active_clean_up page when latest clean up is inactive (status: created)" do
    @clean_up.update!(status: "created")

    get new_participation_path
    assert_response :success
    assert_select "h2", text: "Aktuell kein Clean-Up geplant"
  end

  test "new shows no_active_clean_up page when latest clean up is inactive (status: ended)" do
    @clean_up.update!(status: "ended")

    get new_participation_path
    assert_response :success
    assert_select "h2", text: "Aktuell kein Clean-Up geplant"
  end

  test "new shows statistics on no_active_clean_up page when data exists" do
    @clean_up.update!(status: "ended")
    @participation.update!(cigarettes_count: 25)

    get new_participation_path
    assert_response :success
    assert_select "h3", text: "Unsere bisherigen Erfolge"
  end

  test "create with duplicate participant name returns turbo_stream response" do
    post participations_path,
      params: { participant_name: "Test Participant", participant_people_count: 3 },
      headers: { "Accept" => "text/vnd.turbo-stream.html, text/html, application/xhtml+xml" }

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html; charset=utf-8", response.content_type
  end

  test "create with duplicate participant name contains error message" do
    post participations_path,
      params: { participant_name: "Test Participant", participant_people_count: 3 },
      headers: { "Accept" => "text/vnd.turbo-stream.html, text/html, application/xhtml+xml" }

    assert_response :success
    assert_includes response.body, "Dieser Name ist bereits vergeben"
  end

  test "create with duplicate participant name repopulates form with submitted values" do
    post participations_path,
      params: { participant_name: "Test Participant", participant_people_count: 5 },
      headers: { "Accept" => "text/vnd.turbo-stream.html, text/html, application/xhtml+xml" }

    assert_response :success
    assert_includes response.body, "Test Participant"
    assert_includes response.body, "5"
  end

  test "create with duplicate participant name does not create new participant" do
    assert_no_difference "Participant.count" do
      post participations_path,
        params: { participant_name: "Test Participant", participant_people_count: 3 },
        headers: { "Accept" => "text/vnd.turbo-stream.html, text/html, application/xhtml+xml" }
    end
  end

  test "create with unique participant name creates participant and redirects" do
    assert_difference "Participant.count", 1 do
      post participations_path,
        params: { participant_name: "New Unique Participant", participant_people_count: 2 }
    end

    assert_redirected_to show_participation_path(Participation.last)
  end

  # Confirm action tests
  test "confirm displays confirmation page for returning participant" do
    get confirm_participation_path, params: { participant_id: @participant.id }
    assert_response :success
    assert_select "input[name='participant_people_count']"
  end

  test "confirm shows participant name" do
    get confirm_participation_path, params: { participant_id: @participant.id }
    assert_response :success
    assert_includes response.body, @participant.name
  end

  test "confirm shows current people count" do
    get confirm_participation_path, params: { participant_id: @participant.id }
    assert_response :success
    assert_select "input[value='#{@participant.people_count}']"
  end

  # Create with participant_id and updated people_count tests
  test "create with participant_id and updated people_count updates participant and creates participation" do
    @clean_up.update!(status: "registration_enabled")
    original_count = @participant.people_count

    assert_difference "Participation.count", 1 do
      post participations_path,
        params: { participant_id: @participant.id, participant_people_count: 5 }
    end

    assert_redirected_to show_participation_path(Participation.last)
    assert_equal 5, @participant.reload.people_count
    assert_not_equal original_count, @participant.people_count
  end

  test "create with participant_id enforces minimum people_count of 1" do
    @clean_up.update!(status: "registration_enabled")

    post participations_path,
      params: { participant_id: @participant.id, participant_people_count: 0 }

    assert_equal 1, @participant.reload.people_count
  end

  test "create with participant_id enforces minimum people_count for negative values" do
    @clean_up.update!(status: "registration_enabled")

    post participations_path,
      params: { participant_id: @participant.id, participant_people_count: -5 }

    assert_equal 1, @participant.reload.people_count
  end

  test "create with participant_id without people_count does not update participant" do
    @clean_up.update!(status: "registration_enabled")
    original_count = @participant.people_count

    post participations_path,
      params: { participant_id: @participant.id }

    assert_equal original_count, @participant.reload.people_count
  end

  # Destroy action tests
  test "destroy deletes participation and redirects to farewell when registered and clean-up not started" do
    @clean_up.update!(status: "registration_enabled")
    @participation.update!(status: "registered")

    assert_difference "Participation.count", -1 do
      delete participation_path(@participation)
    end

    assert_redirected_to farewell_path
  end

  test "destroy does not delete participation when clean-up has started" do
    @clean_up.update!(status: "started")
    @participation.update!(status: "registered")

    assert_no_difference "Participation.count" do
      delete participation_path(@participation)
    end

    assert_redirected_to show_participation_path(@participation)
  end

  test "destroy does not delete participation when clean-up has ended" do
    @clean_up.update!(status: "ended")
    @participation.update!(status: "registered")

    assert_no_difference "Participation.count" do
      delete participation_path(@participation)
    end

    assert_redirected_to show_participation_path(@participation)
  end

  test "destroy does not delete participation when status is started" do
    @clean_up.update!(status: "registration_enabled")
    @participation.update!(status: "started")

    assert_no_difference "Participation.count" do
      delete participation_path(@participation)
    end

    assert_redirected_to show_participation_path(@participation)
  end

  test "destroy does not delete participation when status is returned" do
    @clean_up.update!(status: "registration_enabled")
    @participation.update!(status: "returned")

    assert_no_difference "Participation.count" do
      delete participation_path(@participation)
    end

    assert_redirected_to show_participation_path(@participation)
  end

  test "farewell page renders successfully" do
    get farewell_path
    assert_response :success
    assert_select "h2", text: "Schade, dass du nicht dabei sein kannst!"
  end
end
