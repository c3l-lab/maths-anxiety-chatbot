json.extract! chatbot, :id, :participant_id, :chatbot_type, :conversation, :conversation_started_at, :conversation_finished_at, :created_at, :updated_at
json.url chatbot_url(chatbot, format: :json)
