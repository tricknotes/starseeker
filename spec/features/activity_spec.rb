require 'spec_helper'

feature 'Activity' do
  given!(:user) { create(:user, authentications: [build(:github)]) }

  background do
    User.any_instance.stub(:followings).and_return([{'login' => 'Jeseph'}])
    stub_star_event!(actor: {login: 'Jeseph'}, repo: {name: 'DIO/the-world'})
    stub_repository!('DIO/the-world', watchers_count: 21)

    login_as(user)
  end

  scenario 'Daily Hot Repositories' do
    click_link 'Hot repositories'

    page.should have_title('Daily hot repositories')
    page.should have_link('[News Feed]')
    page.should have_list('DIO/the-world [21]')
  end

  scenario 'News Feed' do
    click_link 'Hot repositories'
    click_link '[News Feed]'

    page.body.should match(%r{\A<\?xml version="1\.0" encoding="UTF-8"\?>})
    page.body.should match('<title>DIO/the-world</title>')
  end
end
