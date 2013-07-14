require 'spec_helper'

describe UserMailer do
  let(:user) { create(:user) }

  describe '#activation_needed_email' do
    subject { UserMailer.activation_needed_email(user) }

    it 'should contains username' do
      subject.body.should match('USER')
    end

    it 'should contains activation url' do
      user.activation_token.should_not be_blank
      subject.body.should match(URI.join(Settings.base_url, '/sessions/activate/', user.activation_token).to_s)
    end
  end

  describe '#activation_success_email' do
    subject { UserMailer.activation_success_email(user) }

    it 'should contains username' do
      subject.body.should match('USER')
    end

    it 'should contains login url' do
      subject.body.should match(URI.join(Settings.base_url, '/auth/github').to_s)
    end
  end
end
