describe DailyMailScheduler do
  let!(:user) { create(:user, :with_authentication) }

  before do
    subject.clear!
  end

  after do
    subject.clear!
  end

  describe '.schedule' do
    before do
      subject.schedule [user]
    end

    its(:scheduled_users) { is_expected.to eq([user]) }
  end

  describe '.send_mail_to_scheduled_users' do
    let(:io)     { StringIO.new }
    let(:logger) { Logger.new(io) }

    let(:starred_user_data) { {'login' => 'Jeseph', 'avatar_url' => 'http://example.com/icon.png'} }

    around do |example|
      subject.logger, @original = logger, DailyMailScheduler.logger

      example.run

      subject.logger = @original
    end

    context 'When user has stars to be notified' do
      before do
        user.activate!

        allow_any_instance_of(User).to receive(:followings).and_return([starred_user_data])
        stub_star_event! actor: starred_user_data, repo: {name: 'DIO/the-world'}
        stub_repository! 'DIO/the-world', watchers_count: 21

        subject.schedule [user]

        subject.send_mail_to_scheduled_users
      end

      it 'should send mail to scheduled users' do
        mail = ActionMailer::Base.deliveries.first
        expect(mail).not_to be_nil
      end

      it 'should clear schedule' do
        expect(subject.scheduled_users).to be_empty
      end

      it 'should puts log' do
        log = io.string.split("\n").first

        expect(log).to match('Send hot repositories mail to')
        expect(log).to match('USER')
        expect(log).to match(user.email)
      end
    end

    context 'When user has no stars' do
      before do
        user.activate!

        allow_any_instance_of(User).to receive(:followings).and_return([starred_user_data])

        subject.schedule [user]

        subject.send_mail_to_scheduled_users
      end

      it 'should skip mail seding' do
        mail = ActionMailer::Base.deliveries.first
        expect(mail).to be_nil
      end

      it 'should clear schedule' do
        expect(subject.scheduled_users).to be_empty
      end

      it 'should puts log' do
        log = io.string.split("\n").first

        expect(log).to match('Skip sending mail to')
        expect(log).to match('USER')
        expect(log).to match(user.email)
      end
    end

    context 'When error occurred' do
      let(:error) { StandardError }

      before do
        allow(subject).to receive(:user_has_starred?).and_raise(error)

        subject.schedule [user]

        subject.send_mail_to_scheduled_users
      end

      it 'should keep schedule' do
        expect(subject.scheduled_users).to eq([user])
      end

      it 'should puts log' do
        log = io.string.split("\n").first

        expect(log).to match(error.name)
      end
    end
  end
end
