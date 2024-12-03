class Casino::LoginAttemptsController < Casino::ApplicationController
  include Casino::SessionsHelper

  before_action :ensure_signed_in, only: [:index]

  def index
    @login_attempts = current_user.login_attempts.order(created_at: :desc)
                                  .page(params[:page]).per(10)
  end
end
