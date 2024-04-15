# frozen_string_literal: true

require 'csv'
class Chatbot < ApplicationRecord
  CHATBOT_TYPES = ['Group A - Helpful Chatbot', 'Group B - Neutral Chatbot'].freeze

  # Used to export all the chatbots to a CSV file
  def self.to_csv
    chatbots = all
    CSV.generate do |csv|
      csv << column_names.map do |header|
        # Make the column names a bit more user-friendly
        case header when 'id' then 'database_id' when 'conversation' then 'conversation (JSON)' else header end
      end

      chatbots.each do |chatbot|
        csv << chatbot.attributes.values_at(*column_names)
      end
    end
  end
end
