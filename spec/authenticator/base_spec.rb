require 'spec_helper'

require 'casino/authenticator'

describe Casino::Authenticator do
  subject {
    Casino::Authenticator.new
  }

  context '#validate' do
    it 'raises an error' do
      expect { subject.validate(nil, nil) }.to raise_error(NotImplementedError)
    end
  end
end
