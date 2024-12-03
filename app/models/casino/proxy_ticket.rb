require 'addressable/uri'

class Casino::ProxyTicket < Casino::ApplicationRecord
  include Casino::ModelConcern::Ticket

  self.ticket_prefix = 'PT'.freeze

  validates :ticket, uniqueness: true
  belongs_to :proxy_granting_ticket
  has_many :proxy_granting_tickets, as: :granter, dependent: :destroy

  def self.cleanup_unconsumed
    self.where('created_at < ? AND consumed = ?', Casino.config.proxy_ticket[:lifetime_unconsumed].seconds.ago, false).delete_all
  end

  def self.cleanup_consumed
    self.where('created_at < ? AND consumed = ?', Casino.config.proxy_ticket[:lifetime_consumed].seconds.ago, true).delete_all
  end

  def expired?
    lifetime = if consumed?
      Casino.config.proxy_ticket[:lifetime_consumed]
    else
      Casino.config.proxy_ticket[:lifetime_unconsumed]
    end
    (Time.now - (self.created_at || Time.now)) > lifetime
  end
end
