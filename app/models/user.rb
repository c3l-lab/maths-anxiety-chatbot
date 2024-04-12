# frozen_string_literal: true

class User < ApplicationRecord
  # Include devise modules.
  # See https://github.com/heartcombo/devise for more details
  devise :database_authenticatable, :timeoutable,
         :rememberable, :validatable

  # Username must be unique
  validates :username, presence: true, uniqueness: { case_sensitive: false }
  # Username must only contain letters, numbers, underscores, and periods
  validates :username, format: { with: /^[a-zA-Z0-9_.]*$/, multiline: true }

  # Add a virtual attribute for login (so we can use email or username)
  attr_writer :login

  def login
    @login || username || email
  end

  # Override Devise's find_for_database_authentication method to allow users to sign in using their username or email
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if (login = conditions.delete(:login))
      where(conditions.to_h).where(['lower(username) = :value OR lower(email) = :value',
                                    { value: login.downcase }]).first
    elsif conditions.key?(:username) || conditions.key?(:email)
      where(conditions.to_h).first
    end
  end
end
