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
    end
  end
end
