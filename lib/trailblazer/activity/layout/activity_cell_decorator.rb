module Trailblazer
  module ActivityLayout
    class ActivityCellDecorator

      attr_reader :activity
      attr_accessor :suggested_column, :suggested_row

      def initialize activity
        self.activity = activity
      end

      def can_be_placed_straight?
        has_sole_predecessor? && is_sole_successor?
      end

      def predecessors
      end

      def successors
      end


      def is_start_event?
      end

      def is_end_event?
      end

      def is_split?
        successor_count > 0
      end

      def is_join?
      end

      def is_operation?
      end

      def is_connection?

      end

      #
      def is_sole_successor?
        predecessor[0].successor_count == 1
      end

      def has_sole_predecessor?
        predecessor_count == 1
      end

      #
      # def has_sole_successor?
      #   successor_count == 1
      # end

      def predecessor_count
        predecessors.length
      end

      def successor_count
        successors.length
      end
    end
  end
end
