require 'active_support/core_ext/object/deep_dup'

RSpec.configure do |config|
  config.before do
    @base_config = Casino.config.deep_dup
  end

  config.after do
    Casino.config.clear
    Casino.config.merge! @base_config
  end
end
