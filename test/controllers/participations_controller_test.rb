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
end
