require 'grape'

class Casino::Api < Grape::API
  format :json

  mount Casino::Api::Resource::AuthTokenTickets
end
