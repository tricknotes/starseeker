require 'spec_helper'

describe User do
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
end
