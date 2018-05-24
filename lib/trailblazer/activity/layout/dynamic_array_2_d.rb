class DynamicArray2D

  attr_accessor :content

  def initialize(content = nil)
    self.content = content || [[nil]]
  end

  def append_row row=-1
     self.content.insert(row, Array.new( column_count ))
  end

  def append_column
    self.content.each{ |c| c.push(nil) }
  end
  #
  def row_cursor row
    return 0 if content[row].nil?
    content[row].rindex { |el| el != nil } || 0
  end

  def row_count
    content.length
  end

  def column_count
    content[0].length
  end

end
