module Arel
  module Nodes
    class Contained < InfixOperation
      def initialize left, right
        super :'<@', left, right
      end
    end
  end
end
