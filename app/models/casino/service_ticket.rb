require 'addressable/uri'

class Casino::ServiceTicket < Casino::ApplicationRecord
  include Casino::ModelConcern::Ticket

  self.ticket_prefix = 'ST'.freeze

  belongs_to :ticket_granting_ticket, optional: true
  before_destroy :send_single_sign_out_notification, if: :consumed?
  has_many :proxy_granting_tickets, as: :granter, dependent: :destroy

  def self.cleanup_unconsumed
    self.where('created_at < ? AND consumed = ?', Casino.config.service_ticket[:lifetime_unconsumed].seconds.ago, false).delete_all
  end

  def self.cleanup_consumed
    self.where('(ticket_granting_ticket_id IS NULL OR created_at < ?) AND consumed = ?', Casino.config.service_ticket[:lifetime_consumed].seconds.ago, true).destroy_all
  end

  def self.cleanup_consumed_hard
    self.where('created_at < ? AND consumed = ?', (Casino.config.service_ticket[:lifetime_consumed] * 2).seconds.ago, true).delete_all
  end

  def service=(service)
    normalized_encoded_service = Addressable::URI.parse(service).normalize.to_str
    super(normalized_encoded_service)
  end

  def service_with_ticket_url
    service_uri = Addressable::URI.parse(service)
    service_uri.query_values = (service_uri.query_values(Array) || []) << ['ticket', ticket]
    service_uri.to_s
  end

  def expired?
    lifetime = if consumed?
                 Casino.config.service_ticket[:lifetime_consumed]
               else
                 Casino.config.service_ticket[:lifetime_unconsumed]
               end
    (Time.now - (created_at || Time.now)) > lifetime
  end

  private

  def send_single_sign_out_notification
    notifier = SingleSignOutNotifier.new(self)
    notifier.notify
    true
  end
end
