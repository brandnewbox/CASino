require 'casino/authenticator'

module Casino::AuthenticationProcessor
  extend ActiveSupport::Concern

  def validate_login_credentials(username, password, context = nil)
    authentication_result = nil
    authenticators.each do |authenticator_name, authenticator|
      begin
        credentials = [ username, password, context ]

        # Old authenticators that don't accept a 3rd context parameter will have a validate
        # method that only accepts 2 arguments, so check for that.
        credentials.pop if authenticator.class.instance_method(:validate).arity == 2

        data = authenticator.validate(*credentials)
      rescue Casino::Authenticator::AuthenticatorError => e
        Rails.logger.error "Authenticator '#{authenticator_name}' (#{authenticator.class}) raised an error: #{e}"
      end
      if data
        authentication_result = { authenticator: authenticator_name, user_data: data }
        Rails.logger.info("Credentials for username '#{data[:username]}' successfully validated using authenticator '#{authenticator_name}' (#{authenticator.class})")
        break
      end
    end
    authentication_result
  end

  def load_user_data(authenticator_name, username)
    authenticator = authenticators[authenticator_name]
    return nil if authenticator.nil?
    return nil unless authenticator.respond_to?(:load_user_data)
    authenticator.load_user_data(username)
  end

  def authenticators
    @authenticators ||= {}.tap do |authenticators|
      Casino.config[:authenticators].each do |name, auth|
        next unless auth.is_a?(Hash)

        authenticator = if auth[:class]
                          auth[:class].constantize
                        else
                          load_authenticator(auth[:authenticator])
                        end

        authenticators[name] = authenticator.new(auth[:options])
      end
    end
  end

  private
  def load_authenticator(name)
    gemname, classname = parse_name(name)

    begin
      require gemname unless Casino.const_defined?(classname)
      Casino.const_get(classname)
    rescue LoadError => error
      raise LoadError, load_error_message(name, gemname, error)
    rescue NameError => error
      raise NameError, name_error_message(name, error)
    end
  end

  def parse_name(name)
    [ "casino-#{name.underscore}_authenticator", "#{name.camelize}Authenticator" ]
  end

  def load_error_message(name, gemname, error)
    "Failed to load authenticator '#{name}'. Maybe you have to include " \
      "\"gem '#{gemname}'\" in your Gemfile?\n" \
      "  Error: #{error.message}\n"
  end

  def name_error_message(name, error)
    "Failed to load authenticator '#{name}'. The authenticator class must " \
      "be defined in the Casino namespace.\n" \
      "  Error: #{error.message}\n"
  end
end
