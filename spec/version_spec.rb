require 'spec_helper'

def new_version branch_name, git_tags
  if branch_name =~ /^release\_v/
    return branch_name.gsub('release_v', 'version-')
  elsif branch_name =~ /^hotfix\_/
    last_v = ''
    git_tags.each do |t|
      if /^version\-\d+\.\d+\.(?<nm_>\d+)$/ =~ t # with fix number
        last_v = t.gsub(/\d+$/, (nm_.to_i + 1).to_s)
      elsif /^version\-\d+\.\d+$/ =~ t # without fix number
        last_v = t + '.1'
      end
    end
    return last_v
  else
    return ''
  end
end

describe "new_version" do
  context "release versions" do
    it "should return the version tag the first time" do
      new_version('release_v1.0', []).should eq('version-1.0')
    end
    
    it "should return the version tag the second time" do
      new_version('release_v1.0.2', ['version-1.0']).should eq('version-1.0.2')
    end
  end

  context "hotfix versions" do
    it "should return noting if no previous version" do
      new_version('hotfix_somebug', []).should eq('')
    end
  
    it "should return new version after a major version tag" do
      new_version('hotfix_somebug2', ['version-1.2']).should eq('version-1.2.1')
    end

    it "should return new version after a minor version tag" do
      new_version('hotfix_somebug3', ['version-1.2', 'version-1.3.2']).should eq('version-1.3.3')
    end

    it "will not broken by a prepare tag" do
      new_version('hotfix_somebug3', ['version-1.2', 'version-1.3.2', 'version-2.0a']).should eq('version-1.3.3')
    end

  end
end
