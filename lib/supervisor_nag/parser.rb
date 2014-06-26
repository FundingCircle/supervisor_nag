module SupervisorNag
  module Parser
    def self.parse app=nil
      apps = []
      supervisorctl = `supervisorctl status #{app}`
      supervisorctl.split("\n").each do |line|
        line.split!

        name = line[0]
        state = line[1]
        since = line[1] == 'STOPPED' ? line[2..-1].join(' ') : line[5..-1]

        app << SupervisorNag::Application.new(name, state, since)
      end
      app
    end
  end
end
