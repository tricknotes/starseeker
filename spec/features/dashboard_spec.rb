require 'spec_helper'

feature 'Dashboard' do
  given!(:user) { create(:user, authentications: [build(:github)]) }

  background do
    stub_star_event!(actor: {login: 'USER'}, repo: {name: 'github/octocat'})
    stub_repository!('github/octocat', watchers_count: 25)

    stub_star_event!(actor: {login: 'alice'}, repo: {name: 'USER/try_git'})
    stub_repository!('USER/try_git', watchers_count: 1)

    login_as(user)
  end

  scenario 'Visit Dashboard' do
    click_link 'dashboard'

    page.should have_title('starseeker user')
    page.should have_content('user@starseeker.so')
    page.should have_sub_title('Repositories you starred recently:')
    page.should have_css('.starred_repos_by_user li', text: 'github/octocat')
    page.should have_sub_title('Your repositories recently starred by someone:')
    page.should have_css('.starred_repos_by_someone li', text: 'USER/try_git')
    page.should have_sub_title('Menu')
  end
end
