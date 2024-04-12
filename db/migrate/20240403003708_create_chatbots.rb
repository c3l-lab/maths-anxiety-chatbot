# frozen_string_literal: true

class CreateChatbots < ActiveRecord::Migration[7.1]
  def change
    create_table :chatbots do |t|
      t.string :participant_id, null: false
      t.string :chatbot_type, null: false
      t.json :conversation
      t.datetime :conversation_started_at
      t.datetime :conversation_finished_at

      t.timestamps
    end
  end
end
