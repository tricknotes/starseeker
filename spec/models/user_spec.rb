require 'spec_helper'

describe User do
  describe 'default attributes' do
    its(:activation_state) { is_expected.to be_nil }
    its(:subscribe) { is_expected.to be_truthy }
  end

  describe '#access_token' do
    context 'when github authentication is exist' do
      subject do
        create(:user, :with_authentication)
      end

      its(:access_token) { is_expected.to eq('GITHUB_TOKEN') }
    end

    context 'when github authentication is not exist' do
      its(:access_token) { is_expected.to be_nil }
    end
  end

  describe '#feed_token' do
    subject do
      create(:user)
    end

    # its(:feed_token) { is_expected.to have(32).length } # TODO `have` matcher doesn't support String?
    its(:feed_token) { is_expected.not_to be_blank }
  end

  describe '#email_sendable?' do
    subject { build(:user) }

    context 'when email is not exist' do
      before { subject.email = nil}
      its(:email_sendable?) { is_expected.to be_falsey }
    end

    context 'when subscribe is false' do
      before { subject.subscribe = false }
      its(:email_sendable?) { is_expected.to be_falsey }
    end

    context 'when email is exist and subscribe is true' do
      its(:email_sendable?) { is_expected.to be_truthy }
    end
  end

  describe '#active?' do
    subject { build(:user) }

    context 'when activation_state is "active"' do
      its(:active?) { is_expected.to be_truthy }
    end

    context 'when activation_state is `nil`' do
      before { subject.activation_state = nil }
      its(:active?) { is_expected.to be_falsey }
    end
  end
end
