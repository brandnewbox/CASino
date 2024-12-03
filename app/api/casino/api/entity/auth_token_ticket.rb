require 'grape-entity'

class Casino::API::Entity::AuthTokenTicket < Grape::Entity
  expose :ticket
end
