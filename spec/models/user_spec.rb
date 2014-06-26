require 'spec_helper'

describe User do
  describe 'default attributes' do
    its(:activation_state) { should be_nil }
    its(:subscribe) { should be_truthy }
  end

  describe '#access_token' do
    context 'when github authentication is exist' do
      subject do
        create(:user, authentications: [build(:github)])
      end

      its(:access_token) { should eq('GITHUB_TOKEN') }
    end

    context 'when github authentication is not exist' do
      its(:access_token) { should be_nil }
    end
  end

  describe '#feed_token' do
    subject do
      create(:user)
    end

    # its(:feed_token) { should have(32).length } # TODO `have` matcher doesn't support String?
    it { subject.feed_token.should_not be_blank }
  end

  describe '#email_sendable?' do
    subject { build(:user) }

    context 'when email is not exist' do
      before { subject.email = nil}
      its(:email_sendable?) { should be_falsey }
    end

    context 'when subscribe is false' do
      before { subject.subscribe = false }
      its(:email_sendable?) { should be_falsey }
    end

    context 'when email is exist and subscribe is true' do
      its(:email_sendable?) { should be_truthy }
    end
  end

  describe '#active?' do
    subject { build(:user) }

    context 'when activation_state is "active"' do
      its(:active?) { should be_truthy }
    end

    context 'when activation_state is `nil`' do
      before { subject.activation_state = nil }
      its(:active?) { should be_falsey }
    end
  end
end
