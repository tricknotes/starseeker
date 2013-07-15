require 'spec_helper'

feature 'Stars page' do
  given!(:user) { create(:user) }

  background do
    user.activate!
    stub_star_event!(actor: {login: user.username}, repo: {name: 'github/octocat'})
    stub_repository!('github/octocat', watchers_count: 25, language: 'GitHub')

    visit root_path
  end

  scenario 'Show star page about user' do
    within('#members') do
      click_link('') # click avatar image
    end

    page.should have_caption('USER')
    page.should have_sub_title('Repositories USER starred recently:')
    page.should have_list('github/octocat')
    page.should have_list('[25]')
    page.should have_link('#GitHub')
  end
end
