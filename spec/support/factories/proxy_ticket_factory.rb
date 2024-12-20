require 'factory_girl'

FactoryBot.define do
  factory :proxy_ticket, class: Casino::ProxyTicket do
    proxy_granting_ticket
    sequence :ticket do |n|
      "PT-ticket#{n}"
    end
    sequence :service do |n|
      "imaps://mail#{n}.example.org/"
    end

    trait :consumed do
      consumed true
    end
  end
end
