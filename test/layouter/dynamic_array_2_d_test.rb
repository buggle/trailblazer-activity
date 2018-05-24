require "test_helper"
require 'trailblazer/activity/layout/dynamic_array_2_d'


class DynamicArray2DTest < Minitest::Spec

  let(:grid) { DynamicArray2D.new }

  it "initializes with empty cell" do
    grid.content.must_equal [[nil]]
  end

  it "knows column_count & row_count" do
    grid.column_count.must_equal 1
    grid.row_count.must_equal 1
  end

  it "has row_cursor" do
    grid.row_cursor(0).must_equal 0
  end

  describe "appending rows" do

    before do
      grid.append_row
    end

    it "enhances grid" do
      grid.content.must_equal [[nil], [nil]]
    end

    it "keeps column_count" do
      grid.column_count.must_equal 1
    end

    it "increases row_count" do
      grid.row_count.must_equal 2
    end
  end

  describe "appending column" do

    before do
      grid.append_column
    end

    it "enhances grid" do
      grid.content.must_equal [[nil, nil]]
    end

    it "increases column_count" do
      grid.column_count.must_equal 2
    end

    it "keeps row_count" do
      grid.row_count.must_equal 1
    end
  end

  describe "row cursor" do
    let(:grid) { DynamicArray2D.new( [[nil, nil, "anything"], [nil, "something", nil], [nil, nil, nil]] )}

    it "initializes with grid" do
      grid.content.must_equal [[nil, nil, "anything"], [nil, "something", nil], [nil, nil, nil]]
    end

    it "appends row with index" do
      grid.append_row(1)
      grid.content.must_equal [[nil, nil, "anything"], [nil, nil, nil], [nil, "something", nil], [nil, nil, nil]]
    end

    it "finds last element" do
      grid.row_cursor(0).must_equal 2
    end

    it "finds last element" do
      grid.row_cursor(1).must_equal 1
    end

    it "handles empty columns" do
      grid.row_cursor(2).must_equal 0
    end

    it "defaults to 0" do
      grid.row_cursor(3).must_equal 0
    end

  end

end
