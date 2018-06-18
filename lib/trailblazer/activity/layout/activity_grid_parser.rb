module Trailblazer
  module ActivityLayout
    class ActivityGridParser

      def run graph
        self.grid = DynamicGrid.new graph.start_event

        parse_successors graph.start_event

        finalize_grid

      end

      private

      def parse_successors activity
        activity.successors.each{ |successor| parse_activity successor }
      end

      def parse_activity activity

        return unless all_predecessors_placed?( activity )

        if activity.can_be_placed_straight?
          place_next_in_row activity
        elsif activity.is_join?
          place_join activity
        else
          place_after_split activity
        end

        parse_successors activity
      end

      def finalize_grid
        align_end_events
        interleave_grid
      end


      def all_predecessors_placed? activity
        activity.predecessors.all?{ |element| grid.contains? element }
      end

      def place_next_in_row activity
        place_centered_after_predecessors activity
      end

      def place_join activity
        activity.predecessors.any?(&:is_split?) ?
          place_join_after_split( activity )
        :
          place_centered_after_predecessors( activity )
      end

      def place_join_after_split activity
        # TODO special case where a join has multiple split predecessors unhandled; layout will overlap. cbuggle, 1.6.2018
        previous_split = activity.predecessors.select(&:is_split?).first

        current_row = grid.row_of( previous_split )
        place_in_next_column(row: current_row, column: current_column + 1, element: activity)
      end

      def place_centered_after_predecessors activity
        current_row = grid.middle_row_of( activity.predecessors )
        place_in_next_column(row: current_row, element: activity)
      end

      def place_after_split activity
        predecessing_split = activity.predecessors.select(&:is_split?).first
        grid.append_row_below predecessing_split

        current_row = grid.row_of predecessing_split
        place_in_next_column( row: current_row + 1, activity: element)
      end

      def place_in_next_column row:, activity: activity
        next_column = grid.next_column_after( activity.predecessors )
        grid.place(row: row, column: next_column, element: activity)
      end

      def align_end_events
        graph.activities.select{ |e| e.end_event? }.tap{ |e| grid.align_right e }
      end

      def interleave_grid
        grid.interleave_grid
      end
    end
  end
end
