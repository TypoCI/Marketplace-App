require "rails_helper"

RSpec.describe Github::InstallMailer, type: :mailer do
  describe "#shutdown" do
    let(:github_install) { build(:github_install, :with_email, created_at: Time.zone.now) }
    let(:mail) { described_class.with(install: github_install).shutdown }

    it "renders the headers" do
      expect(mail.subject).to eq("Typo CI's GitHub Integration will be shutdown on the 13th of September")
      expect(mail.to).to eq([github_install.email])
      expect(mail.from).to eq(["support@typoci.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("I regret to inform you that the Typo CI GitHub Integration will be shutdown")
    end
  end
end
