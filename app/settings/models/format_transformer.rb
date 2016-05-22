module Carendar
  class FormatTransformer < NSValueTransformer
    class << self
      def allowsReverseTransformation
        true
      end
      
      def transformedValueClass
        NSData
      end
    end


    def transformedValue(value)
      NSKeyedUnarchiver.unarchiveObjectWithData(value)
    end


    def reverseTransformedValue(value)
      NSKeyedArchiver.archivedDataWithRootObject(value)
    end

  end
end