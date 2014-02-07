require 'spec_helper'

describe DevFlow::RoadMap do
  describe "#parse" do
    context "valid file" do
      subject (:roadmap) do
        DevFlow::RoadMap.new('examples/ROADMAP', {}).parse
      end

      it "should be a Roadmap object" do
        roadmap.is_a?(DevFlow::RoadMap).should be_true
      end

      it "should assign parents well" do
        roadmap.ln_tasks[28].parent.is_a?(DevFlow::Task)
        roadmap.ln_tasks[28].level.should eq(2)
        roadmap.ln_tasks[28].parent.branch_name.should eq("scope")
        roadmap.ln_tasks[28].parent.level.should eq(1)
      end

      it "should assign dependencies well" do
        roadmap.ln_tasks[70].dependencies.size.should eq(2)
        roadmap.ln_tasks[70].dependencies[0].branch_name.should eq("release_api_design_0.1")
        roadmap.ln_tasks[70].dependencies[1].branch_name.should eq("model_spec")
      end

      it "return a list of team members" do
        %w[huangw  xuyc liudx cuibg wangqh].each do |m|
          roadmap.team_member_names.include?(m).should be_true
        end
        roadmap.team_member_names.include?('sunyr').should be_false
      end
    end
  end
end
