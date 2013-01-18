require 'spec_helper'

describe MyHotRepository do
  let(:user) { create(:user) }

  describe '#notify' do
    subject { MyHotRepository.notify(user) }

    before do
      user.stub!(:followings).and_return([{'login' => 'Buccellati'}])

      stub_star_event!(actor: {login: 'Buccellati'}, repo: {name: 'Giorno/gold-experience'})
      stub_repository!(
        'Giorno/gold-experience',
        watchers_count: 8,
        description: 'The endless is end. It is the Gold Experience Requiem.'
      )
    end

    it 'should have multipart contents' do
      subject.body.parts.length.should eq(2)
    end

    it 'should contains username' do
      subject.body.parts.each do |part|
        part.body.should match('USER')
      end
    end

    it 'should contains star count' do
      subject.body.parts.each do |part|
        part.body.should match('[8]')
      end
    end

    it 'should contains starred reposotories' do
      subject.body.parts.each do |part|
        part.body.should match('Giorno/gold-experience')
      end
    end

    it 'should contains repository description' do
      subject.body.parts.each do |part|
        part.body.should match('The endless is end. It is the Gold Experience Requiem.')
      end
    end
  end
end
