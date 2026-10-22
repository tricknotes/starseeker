feature 'Activity' do
  given!(:user) { create(:user, :with_authentication) }
  given!(:starred_user_data) { {'login' => 'Jeseph', 'avatar_url' => 'http://example.com/joseph.png'} }

  background do
    allow_any_instance_of(User).to receive(:followings).and_return([starred_user_data['login']])

    stub_star_event! actor: starred_user_data, repo: {name: 'DIO/the-world'}
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

  scenario 'News Feed escapes values embedded in the HTML content' do
    stub_star_event! actor: {login: '<b>actor</b>', avatar_url: 'http://example.com/actor.png'}, repo: {name: 'DIO/za-warudo'}
    stub_repository! 'DIO/za-warudo', watchers_count: 1, language: '<b>lang</b>'
    allow_any_instance_of(User).to receive(:followings).and_return(['<b>actor</b>'])

    visit feed_path(username: user.username, format: 'atom', token: user.feed_token)

    content = Nokogiri::XML(page.body).remove_namespaces!.at_xpath('//entry/content').text
    expect(content).not_to include('<b>')
    expect(content).to include('[&lt;b&gt;lang&lt;/b&gt;]')
  end

  scenario 'News Feed without a token' do
    visit feed_path(username: user.username, format: 'atom')

    expect(page.status_code).to eq(401)
  end

  scenario 'News Feed with an invalid token' do
    visit feed_path(username: user.username, format: 'atom', token: 'INVALID_TOKEN')

    expect(page.status_code).to eq(401)
  end
end
