module SupervisorNag
  module Parser
    def self.parse app
      apps = []
      supervisorctl = `supervisorctl status`
      supervisorctl.split("\n").each do |line|
        line_arr = line.split

        name = line_arr[0]
        next unless name =~ /#{app}/

        state = line_arr[1]
        since = line_arr[1] == 'STOPPED' ? line_arr[2..-1].join(' ') : line_arr[5..-1]

        apps << SupervisorNag::Application.new(name, state, since)
      end
      apps
    end
  end
end
