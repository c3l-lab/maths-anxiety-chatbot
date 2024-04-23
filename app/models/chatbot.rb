# frozen_string_literal: true

require 'csv'
class Chatbot < ApplicationRecord
  HELPFUL_GROUP = 'Group A'
  NEUTRAL_GROUP = 'Group B'
  CHATBOT_TYPES = [HELPFUL_GROUP, NEUTRAL_GROUP].freeze

  # Used to export all the chatbots to a CSV file
  def self.to_csv
    chatbots = all
    excluded_columns = %w[created_at updated_at]
    output_columns = column_names - excluded_columns
    CSV.generate do |csv|
      # Setup the header row
      header_row = output_columns.map do |header|
        # Make the column names a bit more user-friendly
        case header when 'id' then 'database_id' when 'conversation' then 'conversation (JSON)' else header end
      end
      header_row << 'Number of strategies / comments requested'
      header_row << 'Reached response limit?'
      csv << header_row

      chatbots.each do |chatbot|
        value_row = chatbot.attributes.values_at(*output_columns)
        value_row << chatbot.number_of_strategies_requested
        value_row << (chatbot.out_of_responses? ? 'Yes' : 'No')
        csv << value_row
      end
    end
  end

  def number_of_strategies_requested
    return 0 if conversation.blank?

    # Count the number of times a response was given
    conversation.count do |message|
      if chatbot_type == HELPFUL_GROUP
        HELPFUL_RESPONSES.include?(message['message'])
      elsif chatbot_type == NEUTRAL_GROUP
        NEUTRAL_RESPONSES.include?(message['message'])
      end
    end
  end

  def waiting?
    return false if conversation.blank?

    conversation.last['message'] == NO_RESPONSE
  end

  def out_of_responses?
    return false if conversation.blank?

    if chatbot_type == HELPFUL_GROUP
      conversation.last['message'] == HELPFUL_NO_MORE_RESPONSES
    elsif chatbot_type == NEUTRAL_GROUP
      conversation.last['message'] == NEUTRAL_NO_MORE_RESPONSES
    end
  end

  def start
    update!(conversation_started_at: DateTime.now)
    conversation = []

    if chatbot_type == HELPFUL_GROUP
      conversation << { message: HELPFUL_WELCOME_1, from: 'chatbot' }
      conversation << { message: HELPFUL_WELCOME_2, from: 'chatbot' }
    elsif chatbot_type == NEUTRAL_GROUP
      conversation << { message: NEUTRAL_WELCOME_1, from: 'chatbot' }
      conversation << { message: NEUTRAL_WELCOME_2, from: 'chatbot' }
    end
    update!(conversation:)
  end

  def yes
    conversation << { message: 'Yes', from: 'user' }
    next_message
  end

  def no
    conversation << { message: 'No', from: 'user' }
    conversation << { message: NO_RESPONSE, from: 'chatbot' }
    save!
    sleep 0.1 # Simulate a delay
  end

  def hear_more
    conversation << { message: USER_HEAR_MORE, from: 'user' }
    next_message
  end

  # Have we started a conversation with this chatbot?
  def started?
    conversation_started_at.present?
  end

  def next_message
    # Add the next message based on the user response and the chatbot type
    # Pretty hacky but it's a once off thing so it doesn't matter too much
    if chatbot_type == HELPFUL_GROUP
      if number_of_strategies_requested >= HELPFUL_RESPONSES.length
        conversation << { message: HELPFUL_NO_MORE_RESPONSES, from: 'chatbot' }
      else
        conversation << { message: HELPFUL_RESPONSES[number_of_strategies_requested], from: 'chatbot' }
        conversation << { message: HELPFUL_PROMPT, from: 'chatbot' }
      end
    elsif chatbot_type == NEUTRAL_GROUP
      if number_of_strategies_requested >= NEUTRAL_RESPONSES.length
        conversation << { message: NEUTRAL_NO_MORE_RESPONSES, from: 'chatbot' }
      else
        conversation << { message: NEUTRAL_RESPONSES[number_of_strategies_requested], from: 'chatbot' }
        conversation << { message: NEUTRAL_PROMPT, from: 'chatbot' }
      end
    end
    save!
    sleep 0.1 # Simulate a delay
  end

  HELPFUL_WELCOME_1 = "Hi there, I'm Chatty the Chatbot. Taking a math test can be a stressful and anxiety-provoking task for many people. I'll be here to keep you company throughout your test and provide some extra support."
  HELPFUL_WELCOME_2 = 'Would you like to hear a strategy for anxiety reduction?'
  HELPFUL_PROMPT = 'Would you like to hear another strategy?'
  HELPFUL_RESPONSES = [
    'Research suggests that deep breathing can help reduce these feelings of stress or anxiety. Try slowly inhaling through your nose and exhaling through your mouth 10 times before returning to the exercise.',
    'Research has shown us that by reframing our negative thoughts as positive thoughts, we can actually perform better. Try approaching the next question with the mindset that the question is challenging, rather than threatening, and that you have the ability to tackle it.',
    'Research has demonstrated the impressive power of mental imagery. Try visualizing yourself solving the next problem. It may just give you the confidence boost you need to succeed.',
    'Research has proven that a confidence boost can go a long way. Try starting with the questions you feel comfortable with, before moving on to tackling the ones you are feeling unsure about.',
    'Research has proven that taking time for your body to relax or recharge can reduce anxiety and improve performance. Try taking a short break, standing up, or performing some stretches before returning to the exercise.',
    "Research has indicated that when we're anxious we tend to focus on our negative experiences. However, focusing on positive experiences can remind us of our strengths. Try thinking of some examples of times you've had a successful or enjoyable interaction with math before returning to the exercise."
  ].freeze
  HELPFUL_NO_MORE_RESPONSES = "I'm sorry, I don't have any more strategies to share with you."

  NO_RESPONSE = "Sounds like you've got this covered! Just let me know if you'd like to hear more."

  NEUTRAL_WELCOME_1 = "Hi there, I'm Chatty the Chatbot. Taking a math test can be a stressful and anxiety-provoking task for many people. I'll be here to keep you company throughout your test."
  NEUTRAL_WELCOME_2 = 'Would you like to hear a comment about research studies?'
  NEUTRAL_PROMPT = 'Would you like to hear another comment?'
  NEUTRAL_RESPONSES = [
    "You're taking part in a research study right now. Research studies help us learn more about specific topics.",
    "Taking part in a study from the participant's perspective can be helpful if you ever want to do your own research.",
    'Psychology rocks!',
    'Participants and researchers play different, but equally important roles in the process of carrying out research.',
    'There are many moving parts involved in creating a research study. These moving parts help ensure that the study runs smoothly and safely for each participant.',
    'Thanks for taking part in our study today!'
  ].freeze
  NEUTRAL_NO_MORE_RESPONSES = "I'm sorry, I don't have any more comments to share with you."

  USER_HEAR_MORE = "I'd like to hear more"
end
