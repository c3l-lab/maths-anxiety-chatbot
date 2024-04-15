# frozen_string_literal: true

require 'csv'
class Chatbot < ApplicationRecord
  CHATBOT_TYPES = ['Group A - Helpful Chatbot', 'Group B - Neutral Chatbot'].freeze

  # Used to export all the chatbots to a CSV file
  def self.to_csv
    chatbots = all
    excluded_columns = %w[created_at updated_at]
    output_columns = column_names - excluded_columns
    CSV.generate do |csv|
      csv << output_columns.map do |header|
        # Make the column names a bit more user-friendly
        case header when 'id' then 'database_id' when 'conversation' then 'conversation (JSON)' else header end
      end

      chatbots.each do |chatbot|
        csv << chatbot.attributes.values_at(*output_columns)
      end
    end
  end

  def start
    update!(conversation_started_at: DateTime.now)
    conversation = []

    if chatbot_type == 'Group A - Helpful Chatbot'
      conversation << { message: HELPFUL_WELCOME_1, from: 'chatbot' }
      conversation << { message: HELPFUL_WELCOME_2, from: 'chatbot' }
    elsif chatbot_type == 'Group B - Neutral Chatbot'
      conversation << { message: NEUTRAL_WELCOME_1, from: 'chatbot' }
      conversation << { message: NEUTRAL_WELCOME_2, from: 'chatbot' }
    end
    update!(conversation:)
  end

  def yes
    conversation << { message: 'Yes', from: 'user' }
    conversation << { message: next_message, from: 'chatbot' }
    prompt = if chatbot_type == 'Group A - Helpful Chatbot'
               HELPFUL_PROMPT
             elsif chatbot_type == 'Group B - Neutral Chatbot'
               NEUTRAL_PROMPT
             end
    conversation << { message: prompt, from: 'chatbot' }
    save!
    sleep 0.1 # Simulate a delay
  end

  def no
    conversation << { message: 'No', from: 'user' }
    conversation << { message: NO_RESPONSE, from: 'chatbot' }
    save!
    sleep 0.1 # Simulate a delay
  end

  def hear_more
    conversation << { message: "I'd like to hear more", from: 'user' }
    conversation << { message: next_message, from: 'chatbot' }
    prompt = if chatbot_type == 'Group A - Helpful Chatbot'
               HELPFUL_PROMPT
             elsif chatbot_type == 'Group B - Neutral Chatbot'
               NEUTRAL_PROMPT
             end
    conversation << { message: prompt, from: 'chatbot' }
    save!
    sleep 0.1 # Simulate a delay
  end

  # Have we started a conversation with this chatbot?
  def started?
    conversation_started_at.present?
  end

  def next_message
    existing_messages = conversation.map { |message| message['message'] }
    available_responses = if chatbot_type == 'Group A - Helpful Chatbot'
                            HELPFUL_RESPONSES
                          elsif chatbot_type == 'Group B - Neutral Chatbot'
                            NEUTRAL_RESPONSES
                          end

    # Return a response that has the lowest count
    lowest_count = available_responses.map { |response| existing_messages.count(response) }.min
    available_responses.find { |response| existing_messages.count(response) == lowest_count }
  end

  HELPFUL_WELCOME_1 = "Hi there, I'm Chatty the Chatbot. I'll be here to keep you company throughout your test and provide some extra support"
  HELPFUL_WELCOME_2 = 'Would you like to hear some strategies to help you with your test?'
  HELPFUL_PROMPT = 'Would you like to hear another strategy?'
  HELPFUL_RESPONSES = [
    'Taking a math test can be a stressful and anxiety-provoking task for many people. Research suggests that deep breathing can help reduce these feelings of stress or anxiety. Try slowly inhaling through your nose and exhaling through your mouth 10 times before returning to the exercise.',
    'Taking a math test can be a stressful and anxiety-provoking task for many people. Research has shown us that by reframing our negative thoughts as positive thoughts, we can actually perform better. Try approaching the next question with the mindset that the question is challenging, rather than threatening, and that you have the ability to tackle it.',
    'Taking a math test can be a stressful and anxiety-provoking task for many people, but research has demonstrated the impressive power of mental imagery. Try visualizing yourself solving the next problem. It may just give you the confidence boost you need to succeed.',
    'Taking a math test can be a stressful and anxiety-provoking task for many people, but research has proven that a confidence boost can go a long way. Try starting with the questions you feel comfortable with, before moving on to tackling the ones you are feeling unsure about.',
    'Taking a math test can be a stressful and anxiety-provoking task for many people. Research has proven that taking time for your body to relax or recharge can reduce anxiety and improve performance. Try taking a short break, standing up, or performing some stretches before returning to the exercise.',
    "Taking a math test can be a stressful and anxiety-provoking task for many people, and research has indicated that when we're anxious we tend to focus on our negative experiences. However, focusing on positive experiences can remind us of our strengths. Try thinking of some examples of times you've had a successful or enjoyable interaction with math before returning to the exercise."
  ].freeze

  NO_RESPONSE = "Sounds like you've got this covered! Just let me know if you'd like to hear more."

  NEUTRAL_WELCOME_1 = "Hi there, I'm Chatty the Chatbot. I'll be here to keep you company throughout your test"
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
end
