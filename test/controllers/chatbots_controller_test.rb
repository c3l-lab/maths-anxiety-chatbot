require "test_helper"

class ChatbotsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @chatbot = chatbots(:one)
  end

  test "should get index" do
    get chatbots_url
    assert_response :success
  end

  test "should get new" do
    get new_chatbot_url
    assert_response :success
  end

  test "should create chatbot" do
    assert_difference("Chatbot.count") do
      post chatbots_url, params: { chatbot: { chatbot_type: @chatbot.chatbot_type, conversation: @chatbot.conversation, conversation_finished_at: @chatbot.conversation_finished_at, conversation_started_at: @chatbot.conversation_started_at, participant_id: @chatbot.participant_id } }
    end

    assert_redirected_to chatbot_url(Chatbot.last)
  end

  test "should show chatbot" do
    get chatbot_url(@chatbot)
    assert_response :success
  end

  test "should get edit" do
    get edit_chatbot_url(@chatbot)
    assert_response :success
  end

  test "should update chatbot" do
    patch chatbot_url(@chatbot), params: { chatbot: { chatbot_type: @chatbot.chatbot_type, conversation: @chatbot.conversation, conversation_finished_at: @chatbot.conversation_finished_at, conversation_started_at: @chatbot.conversation_started_at, participant_id: @chatbot.participant_id } }
    assert_redirected_to chatbot_url(@chatbot)
  end

  test "should destroy chatbot" do
    assert_difference("Chatbot.count", -1) do
      delete chatbot_url(@chatbot)
    end

    assert_redirected_to chatbots_url
  end
end
