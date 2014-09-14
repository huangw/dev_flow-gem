# encoding: utf-8

require 'spec_helper'

describe DevFlow::Command::Base do
  subject(:base) { DevFlow::Command::Base.new(nil, nil) }

  describe '#git_config_key' do
    it 'convert string to git config key' do
      expect(base.git_config_key('dw.user')).to eq('dw.user')
      expect(base.git_config_key('user')).to eq('dw.user')
      expect(base.git_config_key('gitlab.host')).to eq('dw.gitlab.host')
      expect(base.git_config_key('dw.gitlab.host')).to eq('dw.gitlab.host')
    end
  end
end
