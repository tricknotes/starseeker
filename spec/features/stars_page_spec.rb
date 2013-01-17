require 'spec_helper'

feature 'Stars page' do
  given!(:user) { create(:user) }

  background do
    stub_star_event!(actor: {login: user.username}, repo: {name: 'github/octocat'})
    stub_repository!('github/octocat', watchers_count: 25)
    visit root_path
  end

  scenario 'Show star page about user' do
    within('#members') do
      click_link('') # click avatar image
    end

    page.should have_title('USER')
    page.should have_sub_title('Repositories USER starred recently:')
    page.should have_css('#content li', text: 'github/octocat', count: 1)
    page.should have_css('#content li', text: '[25]', count: 1)
  end
end
