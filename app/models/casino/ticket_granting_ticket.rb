require 'user_agent'

class Casino::TicketGrantingTicket < Casino::ApplicationRecord
  include Casino::ModelConcern::Ticket
  include Casino::ModelConcern::BrowserInfo

  self.ticket_prefix = 'TGC'.freeze

  belongs_to :user
  has_many :service_tickets, dependent: :destroy

  scope :active, -> { where(awaiting_two_factor_authentication: false).order('updated_at DESC') }

  def self.cleanup(user = nil)
    if user.nil?
      base = self
    else
      base = user.ticket_granting_tickets
    end
    tgts = base.where([
      '(created_at < ? AND awaiting_two_factor_authentication = ?) OR (created_at < ? AND long_term = ?) OR created_at < ?',
      Casino.config.two_factor_authenticator[:timeout].seconds.ago,
      true,
      Casino.config.ticket_granting_ticket[:lifetime].seconds.ago,
      false,
      Casino.config.ticket_granting_ticket[:lifetime_long_term].seconds.ago
    ])
    Casino::ServiceTicket.where(ticket_granting_ticket_id: tgts).destroy_all
    tgts.destroy_all
  end

  def same_user?(other_ticket)
    if other_ticket.nil?
      false
    else
      other_ticket.user_id == self.user_id
    end
  end

  def expired?
    if awaiting_two_factor_authentication?
      lifetime = Casino.config.two_factor_authenticator[:timeout]
    elsif long_term?
      lifetime = Casino.config.ticket_granting_ticket[:lifetime_long_term]
    else
      lifetime = Casino.config.ticket_granting_ticket[:lifetime]
    end
    (Time.now - (self.created_at || Time.now)) > lifetime
  end
end
