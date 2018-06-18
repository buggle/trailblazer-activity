require "test_helper"
require 'trailblazer/activity/layout/dynamic_grid'


class DynamicGridTest < Minitest::Spec

  let(:activity) { "something"}
  let(:grid) { Trailblazer::ActivityLayout::DynamicGrid.new activity }

  let(:big_grid) { Trailblazer::ActivityLayout::DynamicGrid.new activity}

  it "initializes default" do
    grid.content.must_equal [[nil]]
  end

  it "initializes with element" do
    grid.content.must_equal [[activity]]
  end

  it "contains? activity" do
    grid.contains?.must_equal true
  end

  it "knows coordinates of activity" do
    grid.coordinates_of(activity).must_equal 0,0
    grid.append_row(-1)
    grid.coordinates_of(activity).must_equal 1,0
    grid.append_column(-1)
    grid.coordinates_of(activity).must_equal 1,1
    grid.append_column(0)
    grid.coordinates_of(activity).must_equal 1,2
    grid.append_row(0)
  end
end
