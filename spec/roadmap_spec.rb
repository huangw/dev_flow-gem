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
        roadmap.ln_tasks[23].parent.is_a?(DevFlow::Task)
        roadmap.ln_tasks[23].parent.branch_name.should eq("scope")
      end

      it "should assign dependencies well" do
        roadmap.ln_tasks[64].dependencies.size.should eq(2)
        roadmap.ln_tasks[64].dependencies[0].branch_name.should eq("release_api_design_0.1")
        roadmap.ln_tasks[64].dependencies[1].branch_name.should eq("model_spec")
      end
    end
  end
end
