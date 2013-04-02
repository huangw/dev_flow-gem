# encoding: utf-8
require "spec_helper"
require "dev_flow/date_name"

describe DateName do
  describe ".zh" do
    it "can handle yesterday" do
      DateName.zh(DateTime.now-1).should eq('昨天')
    end

    it "can handle next two days" do
      DateName.zh(DateTime.now+2).should eq('后天')
    end

    it "can handle next two days" do
      DateName.zh(DateTime.now+6, DateTime.now+4).should eq('后天')
    end
    
    it "can handle next 6 days" do
      DateName.zh(DateTime.now+6).should eq('6天后')
    end
    
    it "can handle 8 days before" do
      DateName.zh(DateTime.now-6).should eq('6天前')
    end

    it "can handle next 14 days" do
      DateName.zh(DateTime.parse("2012-1-14"), DateTime.parse("2012-1-1")).should eq('01月14日')
    end
    
    it "can handle before 11 days on last year" do
      DateName.zh(DateTime.parse("2011-12-20"), DateTime.parse("2012-1-1")).should eq('2011年12月20日')
    end
  end
end
