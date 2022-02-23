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
end
