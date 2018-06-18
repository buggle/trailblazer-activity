require "test_helper"
require 'trailblazer/activity/layout/activity_cell_decorator'


class ActivityCellDecoratorTest < Minitest::Spec

  let(:activity) { Activity.new }
  let(:cell) { Trailblazer::ActivityLayout::ActivityCellDecorator.new activity }


  it "initializes default" do
    Trailblazer::ActivityLayout::ActivityCellDecorator.new.activity.must_equal nil
  end

  it "initializes with element" do
    cell.activity.must_equal activity
  end

  describe "activity" do
    let(:activity) { Activity.new } # operation
  end

  describe "start_event" do
    let(:start_event) { Activity.new } # operation with no predecessor

    it "is start_event?" do
      start_event.must_be start_event?
    end

    it "is no end_event?" do
      start_event.must_not_be end_event?
    end

    it "is no connection?" do
      end_event.must_not_be connection?
    end
  end

  describe "end_event" do
    let(:end_event) { } # operation with no successor

    it "is end_event?" do
      end_event.must_be end_event?
    end

    it "is no start_event?" do
      end_event.must_not_be start_event?
    end

    it "is no connection?" do
      end_event.must_not_be connection?
    end
  end

  describe "connection" do
    let(:activity) {  } # connection, not operation

    it "is no end_event?" do
      end_event.must_not_be end_event?
    end

    it "is no start_event?" do
      end_event.must_not_be start_event?
    end

    it "is connection?" do
      end_event.must_be connection?
    end
  end

  describe "split" do
    let(:split) { } # activity with >1 successors

  end

  describe "join" do
    let(:join) { } # activity with >1 predecessors
  end

end
