class Casino::LoginAttempt < Casino::ApplicationRecord
  include Casino::ModelConcern::BrowserInfo

  belongs_to :user
end
