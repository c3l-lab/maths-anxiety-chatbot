# frozen_string_literal: true

# We want to be able to sign in with both a username and an email
class AddUsernameToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :username, :string
    add_index :users, :username, unique: true
  end
end
