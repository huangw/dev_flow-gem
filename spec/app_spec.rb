require "spec_helper"

describe DevFlow::App do
  describe "#all_member_names" do
    subject (:app) do
      DevFlow::App.new({members_file:"examples/members.yml", roadmap:"examples/ROADMAP"}, "info")
    end

    it "should read 7 members" do
      app.all_member_names.size.should eq(7)
      app.all_member_names.include?("huangw").should be_true
      app.all_member_names.include?("wangqh").should be_true
      app.all_member_names.include?("sunyr").should be_true
    end
  end
end
