module DevFlow
  # Configuration with Git
  module GitConfig
    # Those git configuration key saves `~/.git/config` first,
    # and then if different
    def global_keys
      %w(user gitlab.host gitlab.private_key)
    end

    # Those git configuration keys only saves under the
    # project's `.git/config` file.
    def local_keys
      %w(backbone)
    end

    def known_keys
      global_keys + local_keys
    end

    def get_config(arg)
      key = config_key(arg)
      git.config(key) || Git.global_config(key)
    end

    def set_global_config(arg, value)
      git.config(config_key(arg), value)
    end

    def set_local_config(arg, value)
      Git.global_config(config_key(arg), value)
    end

    def config_key(arg)
      key = arg.sub(/\Adw\./, '')
      fail "unknown config key #{arg}" unless known_keys.include?(key)
      "dw.#{key}"
    end

    def global_key?(arg)
      global_keys.include?(arg.sub(/\Adw\./, ''))
    end

    def local_key?(arg)
      local_keys.include?(arg.sub(/\Adw\./, ''))
    end
  end
end
