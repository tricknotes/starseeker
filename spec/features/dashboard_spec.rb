require 'spec_helper'

feature 'Dashboard' do
  given!(:user) { create(:user, :with_authentication, email: 'user@starseeker.so') }
  given!(:starred_user_data) { {login: 'USER', avatar_url: 'http://example.com/user.png'} }

  background do
    clear_mail_box

    stub_star_event!(actor: starred_user_data, repo: {name: 'github/octocat'})
    stub_repository!('github/octocat', watchers_count: 25)

    stub_star_event!(actor: starred_user_data, repo: {name: 'USER/try_git'})
    stub_repository!('USER/try_git', watchers_count: 1)

    login_as(user)
  end

  scenario 'Visit Dashboard' do
    click_link 'dashboard'

    expect(page).to have_caption('starseeker user')
    expect(page).to have_content('user@starseeker.so')
    expect(page).to have_sub_title('Repositories you starred recently:')
    expect(page).to have_css('.starred_repos_by_user li', text: 'github/octocat')
    expect(page).to have_sub_title('Your repositories recently starred by someone:')
    expect(page).to have_css('.starred_repos_by_someone li', text: 'USER/try_git')
    expect(page).to have_sub_title('Menu')
  end

  scenario 'Verify Email' do
    click_link 'dashboard'

    expect(page).to have_content('(Not verified yet.)')
    click_link 'Edit email'

    expect(page).to have_caption('Editing your email')
    fill_in('Email', with: 'jyotaro@jo.jo')
    check('Subscribe')
    click_button 'Save'

    expect(page).to have_caption('starseeker user')
    expect(page).to have_flash('Send email to your address.')
    expect(page).to have_content('(Not verified yet.)')

    mail = ActionMailer::Base.deliveries.first
    expect(mail.to).to eq(['jyotaro@jo.jo'])
    expect(mail.subject).to eq('[starseeker] Verify your email')
    expect(mail.body).to match('Welcome to starseeker, USER')

    stub_login!(user)
    activation_url = mail.body.match(%r{(http://.+)\n})[1]
    visit activation_url

    expect(page).to have_flash('You were successfully activated.')
    visit dashboard_path

    expect(page).to have_content('jyotaro@jo.jo (Verified)')
    expect(page).to have_no_link('Send confirmation mail')
  end

  scenario 'Send confirmation mail' do
    click_link 'dashboard'

    click_link('Send confirmation mail')

    expect(page).to have_flash('Confirmation mail has been sent to your mailbox.')

    mail = ActionMailer::Base.deliveries.first
    expect(mail.to).to eq(['user@starseeker.so'])
    expect(mail.body).to match('Welcome to starseeker, USER')
  end
end
