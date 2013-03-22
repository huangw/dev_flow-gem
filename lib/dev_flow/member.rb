module DevFlow
  class Member
    attr_accessor :name, :display_name, :email, :role

    def initialize name, display_name, email
      @name, @display_name, @email = name, display_name, email
    end

    def is_leader?
      role and role == 'leader'
    end

    # is a leader, moderator or supervisor
    def has_power?
      %w[leader supervisor moderator].include? role
    end
  end
end
