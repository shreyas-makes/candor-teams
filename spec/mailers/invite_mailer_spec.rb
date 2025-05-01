require "rails_helper"

RSpec.describe InviteMailer, type: :mailer do
  # Set ActiveJob queue adapter to test mode for testing delivery_later
  before do
    ActiveJob::Base.queue_adapter = :test
    # Mock credentials for testing
    allow(Rails.application.credentials).to receive(:base_url).and_return("http://test.example.com")
  end

  describe "new_invite" do
    let(:team) { create(:team, name: "Test Team") }
    let(:invite) { create(:invite, team: team, email: "new_user@example.com") }
    let(:mail) { InviteMailer.new_invite(invite) }

    it "renders the headers" do
      expect(mail.subject).to eq("You've been invited to join Test Team on Candor Teams")
      expect(mail.to).to eq(["new_user@example.com"])
      expect(mail.from).to include("support@speedrail.com")
    end

    it "renders the body with invitation details" do
      expect(mail.body.encoded).to include("You've been invited to join Test Team")
      expect(mail.body.encoded).to include(invite.token)
      expect(mail.body.encoded).to include("This invitation will expire on")
      expect(mail.body.encoded).to include("http://test.example.com/invites/claim/#{invite.token}")
    end

    it "enqueues the email delivery job when using deliver_later" do
      expect {
        InviteMailer.new_invite(invite).deliver_later
      }.to have_enqueued_job.on_queue("default")
    end
  end

end
