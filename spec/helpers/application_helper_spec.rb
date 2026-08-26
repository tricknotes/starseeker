describe ApplicationHelper do
  describe '#github_url' do
    it 'should contains name' do
      expect(github_url('ACTOR')).to eq('https://github.com/ACTOR')
    end
  end

  describe '#image_link_to_github_url' do
    context 'with a User' do
      let(:account) { create(:user) }

      it 'links to the GitHub account page' do
        expect(image_link_to_github_url(account)).to include('https://github.com/USER')
      end

      it 'renders the avatar of the account' do
        expect(image_link_to_github_url(account)).to include(account.avatar_url)
      end
    end

    context 'with a Repository::Owner' do
      let(:account) { Repository::Owner.new(login: 'DIO', avatar_url: 'http://example.com/dio.png') }

      it 'links to the GitHub account page' do
        expect(image_link_to_github_url(account)).to include('https://github.com/DIO')
      end

      it 'renders the avatar of the account' do
        expect(image_link_to_github_url(account)).to include('http://example.com/dio.png')
      end
    end
  end

  describe '#html_title_about_user' do
    context 'when user has username and name' do
      let(:user) { create(:user) }

      it 'should contain username' do
        expect(html_title_about_user(user)).to match('USER')
      end

      it 'should contain name' do
        expect(html_title_about_user(user)).to match('starseeker')
      end
    end

    context 'when user has no name' do
      let(:user) { create(:user, name: nil) }

      it 'should not render placeholder' do
        expect(html_title_about_user(user)).to eq('USER')
      end
    end
  end
end
