require 'spec_helper'
require 'github/auth/cli'

describe Github::Auth::CLI do
  let(:argv) { [] }

  subject { described_class.new argv }

  describe '#execute' do
    shared_examples_for 'a method that prints usage' do
      it 'prints the usage' do
        subject.should_receive(:print_usage)
        subject.execute
      end
    end

    context 'when missing a command' do
      let(:argv) { [] }
      it_should_behave_like 'a method that prints usage'
    end

    context 'with an invalid command' do
      let(:argv) { ['invalid'] }
      it_should_behave_like 'a method that prints usage'
    end

    context 'when no usernames are provide' do
      let(:argv) { ['add'] }
      it_should_behave_like 'a method that prints usage'
    end

    context 'with a valid action and usernames' do
      let(:action) { 'add' }
      let(:argv) { [action, 'chrishunt'] }

      it 'calls the method matching the action name' do
        subject.should_receive(action)
        subject.execute
      end
    end

    context 'with the --version command' do
      let(:argv) { ['--version'] }

      it 'prints version information' do
        subject.should_receive(:print_version)
        subject.execute
      end
    end
  end
end
