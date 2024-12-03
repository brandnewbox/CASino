require 'grape-entity'

class Casino::Api::Entity::AuthTokenTicket < Grape::Entity
  expose :ticket
end
