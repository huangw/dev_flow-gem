module DevFlow
  class Info < App

    def process!
      self.hello
      self.ask_rebase

      if self.i_am_leader and self.need_to_close.size > 0
        self.display_close_waiting
      else
        self.display_tasks
      end
    end

  end # class
end
