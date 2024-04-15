# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  resources :chatbots
  patch 'chatbots/:id/start', to: 'chatbots#start', as: :start_chatbot
  patch 'chatbots/:id/finish', to: 'chatbots#finish', as: :finish_chatbot
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  root to: 'chatbots#index'
end
