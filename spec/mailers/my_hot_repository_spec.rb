describe MyHotRepository do
  let!(:user) { create(:user) }
  let!(:starred_user_data) { {'login' => 'Buccellati', 'avatar_url' => 'http://example.com/icon.png'} }

  describe '#notify' do
    subject { MyHotRepository.notify(user) }

    before do
      allow(user).to receive(:followings).and_return([starred_user_data['login']])

      stub_star_event! actor: starred_user_data, repo: {name: 'Giorno/gold-experience'}
      stub_repository!(
        'Giorno/gold-experience',
        watchers_count: 8,
        description: 'The endless is end. It is the Gold Experience Requiem.'
      )
    end

    it 'should have multipart contents' do
      expect(subject.body.parts.length).to eq(2)
    end

    it 'should contains username' do
      subject.body.parts.each do |part|
        expect(part.body).to match('USER')
      end
    end

    it 'should contains star count' do
      subject.body.parts.each do |part|
        expect(part.body).to match('[8]')
      end
    end

    it 'should contains starred reposotories' do
      subject.body.parts.each do |part|
        expect(part.body).to match('Giorno/gold-experience')
      end
    end

    it 'should contains repository description' do
      subject.body.parts.each do |part|
        expect(part.body).to match('The endless is end. It is the Gold Experience Requiem.')
      end
    end

    describe 'the delivered HTML part' do
      let(:html) do
        subject.deliver_now
        ActionMailer::Base.deliveries.last.html_part.body.decoded
      end

      it 'should fit on mobile screens' do
        expect(html).to include('name="viewport"')
        expect(html).to include('max-width:650px')
        expect(html).not_to match(/min-width|float:/)
      end

      it 'should keep the stargazers beside the repository name' do
        expect(html).to match(/class="repo_stargazers"[^>]*text-align:right/)
      end

      it 'should not rely on CSS that mail clients drop' do
        expect(html).not_to match(/var\(|calc\(|@font-face/)
      end
    end
  end
end
