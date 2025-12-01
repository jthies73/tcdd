require "test_helper"

class ParticipationsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @clean_up = CleanUp.create!(
      name: "Test Clean-Up",
      description: "Test description",
      status: "started",
      starts_at: 1.hour.ago,
      address: "Test address"
    )

    @participant = Participant.create!(
      name: "John Doe",
      people_count: 2
    )

    @participation = Participation.create!(
      clean_up: @clean_up,
      participant: @participant,
      status: "started",
      cigarettes_count: 5
    )
  end

  test "update_cigarettes successfully updates count" do
    patch update_cigarettes_participation_path(@participation), params: { cigarettes_count: 10 }, as: :json

    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response["success"]
    assert_equal 10, json_response["cigarettes_count"]

    @participation.reload
    assert_equal 10, @participation.cigarettes_count
  end

  test "update_cigarettes prevents negative values" do
    patch update_cigarettes_participation_path(@participation), params: { cigarettes_count: -5 }, as: :json

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_not json_response["success"]
    assert_equal "Cigarettes count must be non-negative", json_response["error"]

    @participation.reload
    assert_equal 5, @participation.cigarettes_count
  end

  test "update_cigarettes returns error for invalid participation_id" do
    patch update_cigarettes_participation_path(id: 99999), params: { cigarettes_count: 10 }, as: :json

    assert_response :not_found
    json_response = JSON.parse(response.body)
    assert_not json_response["success"]
    assert_equal "Participation not found", json_response["error"]
  end

  test "update_cigarettes allows zero count" do
    patch update_cigarettes_participation_path(@participation), params: { cigarettes_count: 0 }, as: :json

    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response["success"]
    assert_equal 0, json_response["cigarettes_count"]

    @participation.reload
    assert_equal 0, @participation.cigarettes_count
  end

  test "update_cigarettes allows updating from nil to a value" do
    @participation.update_column(:cigarettes_count, nil)

    patch update_cigarettes_participation_path(@participation), params: { cigarettes_count: 15 }, as: :json

    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response["success"]
    assert_equal 15, json_response["cigarettes_count"]

    @participation.reload
    assert_equal 15, @participation.cigarettes_count
  end

  test "update_cigarettes returns error for non-numeric string" do
    patch update_cigarettes_participation_path(@participation), params: { cigarettes_count: "invalid" }, as: :json

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_not json_response["success"]
    assert_equal "Cigarettes count must be a valid integer", json_response["error"]

    @participation.reload
    assert_equal 5, @participation.cigarettes_count
  end
end
