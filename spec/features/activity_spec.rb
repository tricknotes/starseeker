require 'spec_helper'

feature 'Activity' do
  given!(:user) { create(:user, authentications: [build(:github)]) }

  background do
    allow_any_instance_of(User).to receive(:followings).and_return([{'login' => 'Jeseph'}])

    stub_star_event! actor: {login: 'Jeseph'}, repo: {name: 'DIO/the-world'}
    stub_repository! 'DIO/the-world', watchers_count: 21, language: 'Stand'

    login_as user
  end

  scenario 'Daily Hot Repositories' do
    click_link 'Hot repositories'

    expect(page).to have_caption('Daily hot repositories')
    expect(page).to have_link('[News Feed]')
    expect(page).to have_list('DIO/the-world [21]')
    expect(page).to have_link('#Stand')
  end

  scenario 'News Feed' do
    click_link 'Hot repositories'
    click_link '[News Feed]'

    expect(page.body).to match(%r{\A<\?xml version="1\.0" encoding="UTF-8"\?>})
    expect(page.body).to match('<title>DIO/the-world</title>')
  end
end
