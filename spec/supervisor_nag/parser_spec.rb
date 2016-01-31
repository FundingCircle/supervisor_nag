require 'spec_helper'
require 'supervisor_nag/parser'

RSpec.describe SupervisorNag::Parser do
  let(:app) { 'some-app' }
  let(:reported_app) { app }
  let(:output) { <<-END
crashmail                        RUNNING   pid 32773, uptime 20:25:27
pi:asyncDaemon                   RUNNING   pid 25154, uptime 20:29:53
pi:asyncPaymentDaemon            RUNNING   pid 25153, uptime 20:29:53
pi:batchDaemon                   RUNNING   pid 25156, uptime 20:29:53
pi:piLog                         RUNNING   pid 25155, uptime 20:29:53
riemann-postgresql               RUNNING   pid 23683, uptime 20:32:11
#{reported_app.ljust(25)}        RUNNING   pid 12345, uptime 20:32:11
END
  }
  let(:supervisorctl_output) { double(:supervisorctl, success?: supervisorctl_success) }
  let(:supervisorctl_success) { nil }

  describe '.parse' do
    before do
      allow(Open3).to receive(:capture3).
        with('supervisorctl', stdin_data: 'status').
        and_return([output, nil, supervisorctl_output])
    end

    let(:supervisorctl_success) { true }

    subject { described_class.parse(app) }

    specify { expect(subject).to be_a(Array) }
    specify { expect(subject.first.name).to eq('some-app') }
    specify { expect(subject.first.state).to eq(:running) }
    specify { expect(subject.first.since).to eq('20:32:11') }

    context 'when supervisorctl exits with failure' do
      let(:app) { nil }
      let(:supervisorctl_success) { false }
      let(:output) { nil }

      before do
        allow(Open3).to receive(:capture3).
          with('supervisor', ).
          and_return([nil, 'some error', supervisorctl_output])
      end

      specify { expect { subject }.to raise_error(SupervisorNag::CommandExecutionError) }
    end
  end
end
