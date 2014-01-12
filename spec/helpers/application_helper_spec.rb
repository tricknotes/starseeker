require 'spec_helper'

describe ApplicationHelper do
  describe '#github_url' do
    it 'should contains name' do
      github_url('ACTOR').should eq('https://github.com/ACTOR')
    end
  end

  describe '#html_title_about_user' do
    context 'when user has username and name' do
      let(:user) { create(:user) }

      it 'should contain username' do
        html_title_about_user(user).should match('USER')
      end

      it 'should contain name' do
        html_title_about_user(user).should match('starseeker')
      end
    end

    context 'when user has no name' do
      let(:user) { create(:user, name: nil) }

      it 'should not render placeholder' do
        html_title_about_user(user).should eq('USER')
      end
    end
  end
end
