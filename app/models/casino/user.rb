
class Casino::User < Casino::ApplicationRecord
  attr_accessor :fullname, :age, :roles

  has_many :ticket_granting_tickets
  has_many :two_factor_authenticators
  has_many :login_attempts

  def active_two_factor_authenticator
    self.two_factor_authenticators.where(active: true).first
  end

  def extra_attributes
    JSON.parse(read_attribute(:extra_attributes) || '{}')
  rescue JSON::ParserError
    {}
  end

  # Setter for extra_attributes
  def extra_attributes=(value)
    write_attribute(:extra_attributes, value.to_json)
  end
end
