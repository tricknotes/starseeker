# Previews are only registered in development, so load this one by hand.
require_relative 'previews/my_hot_repository_preview'

describe MyHotRepositoryPreview do
  subject(:preview) { described_class.new.notify }

  let!(:user) { create(:user) }
  let(:actor) { {login: 'Buccellati', avatar_url: 'http://example.com/icon.png'} }

  before do
    allow_any_instance_of(User).to receive(:followings).and_return([actor[:login]])

    stub_star_event! actor: actor, repo: {name: 'Giorno/gold-experience'}
    stub_repository!(
      'Giorno/gold-experience',
      watchers_count: 8,
      description: 'The endless is end. It is the Gold Experience Requiem.'
    )
  end

  it 'should show the repositories starred by the followings' do
    expect(preview.html_part.body.decoded).to match('Giorno/gold-experience')
  end

  it 'should inline the stylesheet the way delivery does' do
    html = preview.html_part.body.decoded

    expect(html).to include('style=')
    expect(html).not_to include('rel="stylesheet"')
  end

  it 'should render exactly what delivery renders' do
    MyHotRepository.notify(user).deliver_now

    expect(preview.html_part.body.decoded)
      .to eq(ActionMailer::Base.deliveries.last.html_part.body.decoded)
  end

  context 'with an empty database' do
    before { User.destroy_all }

    it 'should say how to get something to preview' do
      expect { preview }.to raise_error(/star_events:fetch/)
    end
  end
end
