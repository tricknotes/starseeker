require 'spec_helper'

describe User do
  describe 'default attributes' do
    its(:activation_state) { should be_nil }
    its(:subscribe) { should be_true }
  end

  describe '#authentication' do
    subject do
      FactoryGirl.create(:user, authentications: [FactoryGirl.build(:github)])
    end

    context 'when provider is exist' do
      it 'should return authentication' do
        subject.authentication(:github).provider.should eq('github')
      end
    end

    context 'when provider is not exist' do
      it 'should return `nil`' do
        subject.authentication(:facebook).should be_nil
      end
    end
  end

  describe '#access_token' do
    context 'when github authentication is exist' do
      subject do
        FactoryGirl.create(:user, authentications: [FactoryGirl.build(:github)])
      end

      its(:access_token) { should eq('GITHUB_TOKEN') }
    end

    context 'when github authentication is not exist' do
      its(:access_token) { should be_nil }
    end
  end

  describe '#email_sendable?' do
    subject { FactoryGirl.build(:user) }

    context 'when email is not exist' do
      before { subject.email = nil}
      its(:email_sendable?) { should be_false }
    end

    context 'when subscribe is false' do
      before { subject.subscribe = false }
      its(:email_sendable?) { should be_false }
    end

    context 'when email is exist and subscribe is true' do
      its(:email_sendable?) { should be_true }
    end
  end

  describe '#active?' do
    subject { FactoryGirl.build(:user) }

    context 'when activation_state is "active"' do
      its(:active?) { should be_true }
    end

    context 'when activation_state is `nil`' do
      before { subject.activation_state = nil }
      its(:active?) { should be_false }
    end
  end
end
