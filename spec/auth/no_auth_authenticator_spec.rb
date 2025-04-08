require 'spec_helper'

RSpec.describe ZitadelClient::NoAuthAuthenticator do
  context "when no host is provided" do
    it "returns empty headers and the default host" do
      auth = ZitadelClient::NoAuthAuthenticator.new
      expect(auth.get_auth_headers).to eq({})
      expect(auth.host).to eq("http://localhost")
    end
  end

  context "when a custom host is provided" do
    it "returns empty headers and the custom host" do
      auth = ZitadelClient::NoAuthAuthenticator.new("https://custom-host")
      expect(auth.get_auth_headers).to eq({})
      expect(auth.host).to eq("https://custom-host")
    end
  end
end
