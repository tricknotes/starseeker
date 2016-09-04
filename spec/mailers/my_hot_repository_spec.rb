require 'spec_helper'

describe MyHotRepository do
  let!(:user) { create(:user) }
  let!(:starred_user_data) { {'login' => 'Buccellati', 'avatar_url' => 'http://example.com/icon.png'} }

  describe '#notify' do
    subject { MyHotRepository.notify(user) }

    before do
      allow(user).to receive(:followings).and_return([starred_user_data])

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
  end
end
