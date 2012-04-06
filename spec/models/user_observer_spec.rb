require 'spec_helper'

describe UserObserver do
  subject { UserObserver.instance }
  let(:user) { FactoryGirl.create(:user) }
  let(:mailer) { mock(UserMailer) }

  describe '#after_save' do
    context 'when email have changed' do
      before do
        user.activation_token = 'TOKEN'
        user.email = 'test@example.com'
      end

      it 'should send mail' do
        mailer.should_receive(:deliver)
        UserMailer.should_receive(:activation_needed_email).with(user).and_return(mailer)
        subject.after_save(user)
      end
    end

    context 'when email have not changed' do
      before do
        user # To notify email not change
      end

      it 'should not send mail' do
        UserMailer.should_not_receive(:activation_needed_email).with(user)
        subject.after_save(user)
      end
    end

    context 'when email is empty' do
      before do
        user.email = nil
      end

      it 'should not send mail' do
        UserMailer.should_not_receive(:activation_needed_email).with(user)
        subject.after_save(user)
      end
    end
  end
end
