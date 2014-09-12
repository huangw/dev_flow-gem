module DevFlow
  # Helper methods all command use
  module Helpers
    # show debug messages
    def dd(msg)
      say "|#{clean_caller(caller[0]).white}| #{msg}" if DevFlow.options.debug
    end

    private

    def clean_caller(tc)
      tc.sub(%r{\A.+/lib/dev_flow/}, '').sub(/\:in .+\Z/, '')
    end
  end
end
