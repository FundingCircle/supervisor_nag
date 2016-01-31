require 'open3'
require 'supervisor_nag'

module SupervisorNag
  CommandExecutionError = Class.new(RuntimeError)
  NoActiveApplicationsError = Class.new(RuntimeError)

  module Parser
    def self.parse app
      apps = nil

      output.split("\n").each do |line|
        l = parse_line(line)

        next unless l.name =~ /#{app}/

        since = if l.status == 'STOPPED'
                  [l.pid_title, l.pid, l.uptime_title, l.uptime].join(' ')
                else
                  l.uptime
                end

        apps = [] if apps.nil?
        apps << SupervisorNag::Application.new(l.name, l.status, since)
      end
      raise NoActiveApplicationsError if apps.nil?
      return apps
    end

    class << self
      private

      def parse_line line
        Struct.new(:name, :status, :pid_title, :pid, :uptime_title, :uptime).new(*line.strip.split)
      end

      def output
        Open3.capture3('supervisorctl',  :stdin_data => 'status').tap do |out, err, status|
          raise CommandExecutionError, err unless status.success?
        end.first
      end
    end
  end
end
