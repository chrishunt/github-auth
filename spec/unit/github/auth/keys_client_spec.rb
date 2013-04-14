require 'spec_helper'
require 'github/auth/keys_client'

describe Github::Auth::KeysClient do
  subject { described_class.new username: username }

  let(:username) { 'chrishunt' }
  let(:http_client) { stub('HttpClient', get: response) }
  let(:response) { stub('HttpResponse').as_null_object }

  before { subject.stub(http_client: http_client) }

  describe '#initialize' do
    it 'requires a username' do
      expect {
        described_class.new
      }.to raise_error Github::Auth::KeysClient::UsernameRequiredException

      expect {
        described_class.new username: nil
      }.to raise_error Github::Auth::KeysClient::UsernameRequiredException
    end

    it 'saves the username' do
      keys_client = described_class.new username: username
      expect(keys_client.username).to eq username
    end
  end

  describe '#keys' do
    it 'requests keys from the Github API' do
      http_client.should_receive(:get).with(
        "https://api.github.com/users/#{username}/keys"
      )
      subject.keys
    end

    it 'memoizes the response' do
      http_client.should_receive(:get).once
      2.times { subject.keys }
    end

    context 'when the github user has keys' do
      let(:response) {[
        { 'id' => 123, 'key' => 'BLAHBLAH' },
        { 'id' => 456, 'key' => 'FLARBBLU' }
      ]}

      it 'returns the keys' do
        expected_keys = response.map { |entry| entry.fetch 'key' }
        expect(subject.keys).to eq expected_keys
      end
    end

    context 'when the github user does not have keys' do
      let(:response) { [] }

      it 'returns an empty array' do
        expect(subject.keys).to eq []
      end
    end

    context 'when there is an issue connecting to Github' do
      [SocketError, Errno::ECONNREFUSED].each do |exception|
        before { http_client.stub(:get).and_raise exception }

        it 'raises a GithubUnavailableException' do
          expect {
            subject.keys
          }.to raise_error Github::Auth::KeysClient::GithubUnavailableException
        end
      end
    end
  end
end
