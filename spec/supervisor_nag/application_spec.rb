require 'spec_helper'
require 'supervisor_nag/application'

RSpec.describe SupervisorNag::Application do
  describe '#initialize' do
    describe 'input arguments' do
      context 'when arguments are nil' do
        specify { expect { described_class.new }.to raise_error(ArgumentError) }
      end

      context 'when arguments are nil' do
        let(:name) { nil }
        let(:since) { nil }
        let(:state) { 'some_state' }

        subject { described_class.new(name, state, since) }

        specify { expect(subject.name).to be_nil }
        specify { expect(subject.since).to be_nil }
        specify { expect(subject.state).to eq(:some_state) }
      end
    end
  end
end
