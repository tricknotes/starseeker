require 'spec_helper'

describe DailyMailSender do
  let!(:user) { create(:user, authentications: [build(:github)]) }

  # TODO I want to use `around`. But it doesn't warks... Hmm :<
  before do
    subject.clear!
  end

  describe '.schedule' do
    it 'should schedule users' do
      subject.schedule([user])

      subject.scheduled_users.should eq [user]
    end
  end

  describe '.send_mail_to_scheduled_users' do
    let(:io) { StringIO.new }
    let(:logger) { Logger.new(io) }

    before do
      subject.logger, @original = logger, DailyMailSender.logger
    end

    after do
      subject.logger = @original
    end

    context 'When user has stars to be notified' do
      before do
        user.activate!

        User.any_instance.stub(:followings).and_return([{'login' => 'Jeseph'}])
        stub_star_event!(actor: {login: 'Jeseph'}, repo: {name: 'DIO/the-world'})
        stub_repository!('DIO/the-world', watchers_count: 21)

        subject.schedule([user])

        subject.send_mail_to_scheduled_users
      end

      it 'should send mail to scheduled users' do
        mail = ActionMailer::Base.deliveries.first
        mail.should_not be_nil
      end

      it 'should clear schedule' do
        subject.scheduled_users.should be_empty
      end

      it 'should puts log' do
        log = io.string.split("\n").first

        log.should match('Send hot repositories mail to')
        log.should match("USER")
        log.should match(user.email)
      end
    end

    context 'When user has no stars' do
      before do
        user.activate!

        User.any_instance.stub(:followings).and_return([{'login' => 'Jeseph'}])

        subject.schedule([user])

        subject.send_mail_to_scheduled_users
      end

      it 'should skip mail seding' do
        mail = ActionMailer::Base.deliveries.first
        mail.should be_nil
      end

      it 'should clear schedule' do
        subject.scheduled_users.should be_empty
      end

      it 'should puts log' do
        log = io.string.split("\n").first

        log.should match('Skip sending mail to')
        log.should match("USER")
        log.should match(user.email)
      end
    end

    context 'When error occurred' do
      let(:error) { StandardError }

      before do
        subject.should_receive(:user_has_starred?).and_raise(error)

        subject.schedule([user])

        subject.send_mail_to_scheduled_users
      end

      it 'should keep schedule' do
        subject.scheduled_users.should eq [user]
      end

      it 'should puts log' do
        log = io.string.split("\n").first

        log.should match(error.name)
      end
    end
  end
end
