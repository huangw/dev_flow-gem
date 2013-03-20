module DevFlow
  attr_accessor :config
  class App
    def initialize config
      @config = config
    end
  end
end
