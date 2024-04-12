# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create our main lab manager user
User.create(
  email: "#{Rails.application.credentials.lab_manager_username!}@c3l.ai",
  username: Rails.application.credentials.lab_manager_username!,
  password: Rails.application.credentials.lab_manager_password!,
  password_confirmation: Rails.application.credentials.lab_manager_password!
)
