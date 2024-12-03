require 'rotp'

module Casino::TwoFactorAuthenticatorProcessor
  extend ActiveSupport::Concern

  def validate_one_time_password(otp, authenticator)
    if authenticator.nil? || authenticator.expired?
      Casino::ValidationResult.new 'INVALID_AUTHENTICATOR', 'Authenticator does not exist or expired', :warn
    else
      totp = ROTP::TOTP.new(authenticator.secret)
      if totp.verify_with_drift(otp, Casino.config.two_factor_authenticator[:drift])
        Casino::ValidationResult.new
      else
        Casino::ValidationResult.new 'INVALID_OTP', 'One-time password not valid', :warn
      end
    end
  end
end
