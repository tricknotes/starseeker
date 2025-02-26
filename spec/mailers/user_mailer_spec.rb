describe UserMailer do
  let(:user) { create(:user) }

  describe '#activation_needed_email' do
    subject { UserMailer.activation_needed_email(user) }

    it 'should contains username' do
      expect(subject.body).to match('USER')
    end

    it 'should contains activation url' do
      expect(user.activation_token).not_to be_blank
      expect(subject.body).to match(URI.join('http://example.com/sessions/activate/', user.activation_token).to_s)
    end
  end

  describe '#activation_success_email' do
    subject { UserMailer.activation_success_email(user) }

    it 'should contains username' do
      expect(subject.body).to match('USER')
    end

    it 'should contains login url' do
      expect(subject.body).to match(settings_email_url)
    end
  end
end
