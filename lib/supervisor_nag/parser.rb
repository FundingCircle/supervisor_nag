module SupervisorNag
  class DaFuq < RuntimeError; end

  module Parser
    def self.parse app
      supervisorctl = `supervisorctl status`
      apps = nil

      supervisorctl.split("\n").each do |line|
        line_arr = line.strip.split

        name = line_arr[0]
        next unless name =~ /#{app}/

        state = line_arr[1]
        since = line_arr[1] == 'STOPPED' ? line_arr[2..-1].join(' ') : line_arr[5..-1].join(' ')

        apps = [] if apps.nil?
        apps << SupervisorNag::Application.new(name, state, since)
      end
      raise DaFuq if apps.nil?
      return apps
   end
  end
end
