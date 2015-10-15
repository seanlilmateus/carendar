module Carendar
  module Token
    class Component
      def initialize(name=nil, type=nil, items)
        @name = name
        @type = type
        @attributes = items
        @current_string = items.first
      end
      attr_accessor :name, :type, :attributes, :current_string
    
      def initWithCoder(decoder)
        self.tap do |instance|
          instance.name = decoder.decodeObjectOfClass(NSString, forKey: "name")
          instance.type = decoder.decodeObjectOfClass(NSString, forKey: "type")
          instance.attributes = decoder.decodeObjectOfClass(NSArray, forKey: "attributes")
          instance.current_string = decoder.decodeObjectOfClass(NSString, forKey: "current_string")
        end
      end
   
      def encodeWithCoder(encoder)
        encoder.encodeObject(self.name, forKey: "name")
        encoder.encodeObject(self.type, forKey: "type")
        encoder.encodeObject(self.attributes, forKey: "attributes")
        encoder.encodeObject(self.current_string, forKey: "current_string")
      end
      
      def current_index=(index)
        @current_string = attributes[index] || attributes.first
      end
      
      def ==(another)
        self.class == another.class &&  self.name == another.name
      end
    
      def current_value
        fmt = Token::DateTokenizer.date_formatter
        fmt.dateFormat = self.current_string
        fmt.stringFromDate(DateTokenizer.date)
      end
      alias to_s current_string
    end
  end
  
end
