require 'grape'

class Casino::Api::Resource::AuthTokenTickets < Grape::API
  resource :auth_token_tickets do
    desc 'Create an auth token ticket'
    post do
      @ticket = Casino::AuthTokenTicket.create
      Rails.logger.debug "Created auth token ticket '#{@ticket.ticket}'"
      present @ticket, with: Casino::Api::Entity::AuthTokenTicket
    end
  end
end
