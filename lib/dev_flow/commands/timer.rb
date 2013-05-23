module DevFlow
  class Timer < App

    def process!

      ms = ARGV[1] ? ARGV[1].to_i : 25

      b = File.expand_path(File.dirname(__FILE__) + '/../../../bin/ot.exe')
      `#{b} #{ms}`
    end

  end # class
end
