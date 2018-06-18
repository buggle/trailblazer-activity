module Trailblazer
  module ActivityLayout
    class DynamicGrid

      attr_accessor :content

      # delegate :append_row, :append_column, to: :content

      def initialize element=nil
        self.content = DynamicArray2D.new( element )
      end

      def contains? element
        row_index_of( element ).present? && column_index_of( element ).present?
      end

      def coordinates_of element
        return row_index_of( element ), column_index_of( element )
      end

      def row_index_of element
        content.find_index{ |row| row.contains?( element ) }
      end

      def column_index_of element
        content.select{ |row| row.contains?( element ) }.find_index( element )
      end

      alias_method :row_of, :row_index_of
      alias_method :column_of, :column_index_of

      def append_row_below element
        content.append_row( row_index_of( element ))
      end

      def place(row:,column:, element:)
        content[row, column] = element
      end

      def middle_row_of elements
        ( row_indices_of_elements(elements).inject(:+).to_f  / row_indices_of_elements.size ).floor
      end

      def row_indices_of_elements elements
        elements.map{ |el| content.row_of( el ) }
      end

      def align_right element
        row, column = content.row_of element
        content[row][column] = nil
        place(row: row, column: last_column, element: element )
      end

      def max_column elements
        elements.map{ |element| column_of( element )}.max
      end

      def next_column_after elements
        max_column(elements) + 1
      end

      def last_column
        content.column_count - 1
      end

      def interleave_grid
        # TODO remove empty cells by merging non-overlapping rows
        content
      end
    end
  end
end
