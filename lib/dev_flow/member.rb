module DevFlow
  class Member
    attr_accessor :name, :display_name, :email

    def initialize name, display_name, email
      @name, @display_name, @email = name, display_name, email
    end

  end
end
