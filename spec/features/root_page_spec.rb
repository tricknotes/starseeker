require 'spec_helper'

feature 'Root page' do
  context 'Without signin' do
    scenario 'Visit root page' do
      visit root_path

      page.should have_css('#catch-phrase', text: 'Seek your following\'s stars!')
      page.should have_link('Sign in with GitHub')
    end
  end

  context 'With signin' do
    given!(:user) { create(:user, authentications: [build(:github)]) }

    background do
      login_as(user)
    end

    scenario 'Visit root page' do
      visit root_path

      page.should have_link('Logout')
      page.should have_link('Let\'s go on a journey to seek for your stars!')
    end
  end
end
