require 'spec_helper'
require 'github/auth/key'
require 'github/auth/keys_client'

describe Github::Auth::KeysClient do
  subject { described_class.new username: username }

  let(:username) { 'chrishunt' }
  let(:http_client) { double('HttpClient', get: response) }
  let(:response_code) { 200 }
  let(:parsed_response) { nil }
  let(:response) {
    double('HTTParty::Response', {
      code: response_code,
      parsed_response: parsed_response
    })
  }

  before { subject.stub(http_client: http_client) }

  describe '#initialize' do
    it 'requires a username' do
      expect {
        described_class.new
      }.to raise_error Github::Auth::KeysClient::UsernameRequiredError

      expect {
        described_class.new username: nil
      }.to raise_error Github::Auth::KeysClient::UsernameRequiredError
    end

    it 'saves the username' do
      keys_client = described_class.new username: username
      expect(keys_client.username).to eq username
    end
  end

  describe '#keys' do
    it 'requests keys from the Github API' do
      http_client.should_receive(:get).with(
        "https://api.github.com/users/#{username}/keys",
        { headers: { 'User-Agent' => "github_auth-#{Github::Auth::VERSION}" } }
      )
      subject.keys
    end

    it 'memoizes the response' do
      http_client.should_receive(:get).once
      2.times { subject.keys }
    end

    context 'when the github user has keys' do
      let(:parsed_response) {[
        { 'id' => 123, 'key' => 'abc123' },
        { 'id' => 456, 'key' => 'def456' }
      ]}

      it 'returns the keys' do
        expected_keys = parsed_response.map do |entry|
          Github::Auth::Key.new username, entry.fetch('key')
        end

        expect(subject.keys).to eq expected_keys
      end
    end

    context 'when the github user does not have keys' do
      let(:parsed_response) { [] }

      it 'returns an empty array' do
        expect(subject.keys).to eq []
      end
    end

    context 'when the github user does not exist' do
      let(:response_code) { 404 }

      it 'raises GithubUserDoesNotExistError' do
        expect {
          subject.keys
        }.to raise_error Github::Auth::KeysClient::GithubUserDoesNotExistError
      end
    end

    context 'when there is an issue connecting to Github' do
      [SocketError, Errno::ECONNREFUSED].each do |exception|
        before { http_client.stub(:get).and_raise exception }

        it 'raises a GithubUnavailableError' do
          expect {
            subject.keys
          }.to raise_error Github::Auth::KeysClient::GithubUnavailableError
        end
      end
    end
  end
end
