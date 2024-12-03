require 'grape'

class Casino::API < Grape::API
  format :json

  mount Casino::API::Resource::AuthTokenTickets
end
