feature 'Activity' do
  given!(:user) { create(:user, :with_authentication) }
  given!(:starred_user_data) { {'login' => 'Jeseph', 'avatar_url' => 'http://example.com/joseph.png'} }

  background do
    allow_any_instance_of(User).to receive(:followings).and_return([starred_user_data['login']])

    stub_star_event! actor: starred_user_data, repo: {name: 'DIO/the-world'}
    stub_repository! 'DIO/the-world', watchers_count: 21, language: 'Stand'

    stub_star_event! actor: starred_user_data, repo: {name: 'Jotaro/star-platinum'}
    stub_repository! 'Jotaro/star-platinum', watchers_count: 3, language: 'Stand'

    allow_any_instance_of(User).to receive(:starred_repository_names) {|_, repo_names|
      repo_names.to_set & ['Jotaro/star-platinum']
    }

    login_as user
  end

  scenario 'Daily Hot Repositories' do
    click_link 'Hot repositories'

    expect(page).to have_caption('Daily hot repositories')
    expect(page).to have_link('[News Feed]')
    expect(page).to have_list('DIO/the-world [21]')
    expect(page).to have_link('#Stand')
  end

  scenario 'Repositories the user has starred are marked' do
    click_link 'Hot repositories'

    expect(page).to have_css('li.repo.starred_by_me', text: 'Jotaro/star-platinum [3] #Stand ★ Starred', count: 1)
    expect(page).to have_css('li.repo:not(.starred_by_me)', text: 'DIO/the-world [21]', count: 1)
    expect(page).to have_no_css('li.repo:not(.starred_by_me) .starred_by_me')
  end

  scenario 'News Feed' do
    click_link 'Hot repositories'
    click_link '[News Feed]'

    expect(page.body).to match(%r{\A<\?xml version="1\.0" encoding="UTF-8"\?>})
    expect(page.body).to match('<title>DIO/the-world</title>')
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
