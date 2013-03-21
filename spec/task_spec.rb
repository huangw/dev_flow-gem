# encoding: utf-8
require 'spec_helper'

describe DevFlow::Task do
  context "with full date" do
    subject (:task) do
      DevFlow::Task.new(2, '-', '').parse('ui_unit: 用树状图描述UI单元结构 2013/03/04-2013/03/06 @xuyc;huangw:2013/03/06', 
                                          {"members" => {"xuyc" => ["Xu Yichen"], "huangw" => ["Huang Wei"]}})
    end

    its :branch_name do
      should eq("ui_unit") 
    end

    its :display_name do
      should eq("用树状图描述UI单元结构")
    end

    its :start_date do
      should eq(DateTime.new(2013, 03, 04))
    end

    its :end_date do
      should eq(DateTime.new(2013, 03, 06))
    end

    its :is_completed? do
      should be_true
    end

    its :is_pending? do
      should be_false
    end

    its :is_deleted? do
      should be_false
    end

    its :is_milestone? do
      should be_false
    end

    its :is_parent? do
      should be_false
    end

    its :level do
      should eq(2)
    end

    it "has two resource registed" do
      task.resources[0].should eq('xuyc')
      task.resources[1].should eq('huangw')
    end

    it "has two right resource names" do
      task.resource_names[0].should eq("Xu Yichen")
      task.resource_names[1].should eq("Huang Wei")
    end
  end

  context "short date without end date" do
    subject (:task) do
      DevFlow::Task.new(4, '-', '').parse('action_second_m: action和comment相关的模型 03/11 @huangw:80', 
                                          {"members" => {"xuyc" => ["Xu Yichen"], "huangw" => ["Huang Wei"]}, "year" => 2013})
    end

    its :branch_name do
      should eq("action_second_m") 
    end

    its :display_name do
      should eq("action和comment相关的模型")
    end

    its :start_date do
      should eq(DateTime.new(2013, 03, 11))
    end

    its :end_date do
      should eq(DateTime.new(2013, 03, 11))
    end

    its :is_completed? do
      should be_false
    end

    its :progress do
      should eq(80)
    end

    its :is_pending? do
      should be_false
    end

    its :is_deleted? do
      should be_false
    end

    its :is_parent? do
      should be_false
    end

    its :is_milestone? do
      should be_false
    end

    its :level do
      should eq(4)
    end
    
    it "has two resource registed" do
      task.resources[0].should eq('huangw')
    end

    it "has two right resource names" do
      task.resource_names[0].should eq("Huang Wei")
    end
  end

  context "with dependency" do
    subject (:task) do
      DevFlow::Task.new(1, '-', '').parse('release_v2: 发送新版本 2013/04/04 @xuyc;huangw -> dep1;dep2', 
                                          {"members" => {"xuyc" => ["Xu Yichen"], "huangw" => ["Huang Wei"]}})
    end

    its :branch_name do
      should eq("release_v2") 
    end

    its :display_name do
      should eq("发送新版本")
    end

    its :start_date do
      should eq(DateTime.new(2013, 04, 04))
    end

    its :end_date do
      should eq(DateTime.new(2013, 04, 04))
    end

    its :is_completed? do
      should be_false
    end

    its :is_pending? do
      should be_false
    end

    its :is_deleted? do
      should be_false
    end

    its :is_milestone? do
      should be_true
    end

    its :is_parent? do
      should be_false
    end

    its :level do
      should eq(1)
    end

    it "has two resource registed" do
      task.resources[0].should eq('xuyc')
      task.resources[1].should eq('huangw')
    end

    it "has two right resource names" do
      task.resource_names[0].should eq("Xu Yichen")
      task.resource_names[1].should eq("Huang Wei")
    end

    it "has two dependencie_names" do
      task.dependencie_names[0].should eq("dep1")
      task.dependencie_names[1].should eq("dep2")
    end
  end
end
