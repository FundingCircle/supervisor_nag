module SupervisorNag
  class Application
    attr_reader :name, :state, :since

    def initialize name, state, since
      @name  = name
      @state = state.downcase.to_sym
      @since = since
    end
  end
end
