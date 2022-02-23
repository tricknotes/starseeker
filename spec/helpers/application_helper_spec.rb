describe ApplicationHelper do
  describe '#github_url' do
    it 'should contains name' do
      expect(github_url('ACTOR')).to eq('https://github.com/ACTOR')
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
