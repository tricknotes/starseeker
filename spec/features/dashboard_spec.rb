require 'spec_helper'

feature 'Dashboard' do
  given!(:user) { create(:user, email: 'user@starseeker.so', authentications: [build(:github)]) }

  background do
    clear_mail_box

    stub_star_event!(actor: {login: 'USER'}, repo: {name: 'github/octocat'})
    stub_repository!('github/octocat', watchers_count: 25)

    stub_star_event!(actor: {login: 'alice'}, repo: {name: 'USER/try_git'})
    stub_repository!('USER/try_git', watchers_count: 1)

    login_as(user)
  end

  scenario 'Visit Dashboard' do
    click_link 'dashboard'

    page.should have_caption('starseeker user')
    page.should have_content('user@starseeker.so')
    page.should have_sub_title('Repositories you starred recently:')
    page.should have_css('.starred_repos_by_user li', text: 'github/octocat')
    page.should have_sub_title('Your repositories recently starred by someone:')
    page.should have_css('.starred_repos_by_someone li', text: 'USER/try_git')
    page.should have_sub_title('Menu')
  end

  scenario 'Verify Email' do
    click_link 'dashboard'

    page.should have_content('(Not verified yet.)')
    click_link 'Edit email'

    page.should have_caption('Editing your email')
    fill_in('Email', with: 'jyotaro@jo.jo')
    check('Subscribe')
    click_button 'Save'

    page.should have_caption('starseeker user')
    page.should have_flash('Send email to your address.')
    page.should have_content('(Not verified yet.)')

    mail = ActionMailer::Base.deliveries.first
    mail.to.should eq(['jyotaro@jo.jo'])
    mail.subject.should eq('Verify your email')
    mail.body.should match('Welcome to starseeker, USER')

    stub_login!(user)
    activation_url = mail.body.match(%r{(http://.+)\n})[1]
    visit activation_url

    page.should have_flash('You were successfully activated.')
    visit dashboard_path

    page.should have_content('jyotaro@jo.jo (Verified)')
    page.should have_no_link('Send confirmation mail')
  end

  scenario 'Send confirmation mail' do
    click_link 'dashboard'

    click_link('Send confirmation mail')

    page.should have_flash('Confirmation mail has been sent to your mailbox.')
    mail = ActionMailer::Base.deliveries.first
    mail.to.should eq(['user@starseeker.so'])
    mail.body.should match('Welcome to starseeker, USER')
  end
end
