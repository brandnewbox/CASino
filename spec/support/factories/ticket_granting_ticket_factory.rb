require 'factory_girl'

FactoryBot.define do
  factory :ticket_granting_ticket, class: Casino::TicketGrantingTicket do
    user
    sequence :ticket do |n|
      "TGC-ticket#{n}"
    end
    user_agent 'TestBrowser 1.0'
    user_ip '127.0.0.1'

    trait :awaiting_two_factor_authentication do
      awaiting_two_factor_authentication true
    end
  end
end
