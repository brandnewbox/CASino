require 'factory_girl'

FactoryBot.define do
  factory :login_attempt, class: Casino::LoginAttempt do
    user
    successful true
    user_ip '133.133.133.133'
    user_agent 'TestBrowser'
  end
end
