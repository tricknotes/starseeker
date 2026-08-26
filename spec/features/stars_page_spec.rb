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

    expect(page).to have_caption('USER')
    expect(page).to have_sub_title('Repositories USER starred recently:')
    expect(page).to have_list('github/octocat')
    expect(page).to have_list('[25]')
    expect(page).to have_link('#GitHub')
  end

  scenario 'Show 404 page for an unknown user' do
    github_client = instance_double(Octokit::Client)
    allow(github_client).to receive(:user).and_raise(Octokit::NotFound)
    allow(Settings).to receive(:github_client).and_return(github_client)

    visit stars_path(username: 'unknown-user')

    expect(page.status_code).to eq(404)
  end
end
