# encoding: utf-8
require 'spec_helper'

class MockGitConfig
  include DevFlow::GitConfig
end

describe DevFlow::GitConfig do
  subject(:mgc) { MockGitConfig.new }

  describe '#config_key' do
    it 'convert string to git config key' do
      expect(mgc.config_key('dw.user')).to eq('dw.user')
      expect(mgc.config_key('user')).to eq('dw.user')
      expect(mgc.config_key('gitlab.host')).to eq('dw.gitlab.host')
      expect(mgc.config_key('dw.gitlab.host')).to eq('dw.gitlab.host')
    end
  end

  describe '#global_key?' do
    it 'return true for global keys' do
      expect(mgc.global_key?('user')).to be_truthy
      expect(mgc.global_key?('dw.user')).to be_truthy
    end

    it 'return false for non-existing keys' do
      expect(mgc.global_key?('ng')).to be_falsey
      expect(mgc.global_key?('dw.ng')).to be_falsey
    end

    it 'return false for local keys' do
      expect(mgc.global_key?('backbone')).to be_falsey
      expect(mgc.global_key?('dw.backbone')).to be_falsey
    end
  end

  describe '#local_key?' do
    it 'return true for local keys' do
      expect(mgc.local_key?('backbone')).to be_truthy
      expect(mgc.local_key?('dw.backbone')).to be_truthy
    end

    it 'return false for non-existing keys' do
      expect(mgc.local_key?('ng')).to be_falsey
      expect(mgc.local_key?('dw.ng')).to be_falsey
    end

    it 'return false for global keys' do
      expect(mgc.local_key?('user')).to be_falsey
      expect(mgc.local_key?('dw.user')).to be_falsey
    end
  end
end
