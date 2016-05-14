module Carendar
  module Token
    class Component < Struct.new(:name, :type, :attributes, :index)
      def initialize(name = nil, type = nil, items = [], index = 0)
        items = NSArray.arrayWithArray(items)
        super(name, type, items, index)
      end


      def initWithCoder(decoder)
        self.tap do |instance|
          instance.name = decoder.decodeObjectOfClass(NSString, forKey: "name")
          instance.type = decoder.decodeObjectOfClass(NSString, forKey: "type")
          instance.attributes = decoder.decodeObjectOfClass(NSArray, forKey: "attributes")
          instance.index = decoder.decodeObjectOfClass(NSNumber, forKey: "index") || 0
        end
      end


      def current_string
        self.attributes[self.index]
      end


      def encodeWithCoder(encoder)
        encoder.encodeObject(self.name, forKey: "name")
        encoder.encodeObject(self.type, forKey: "type")
        encoder.encodeObject(self.attributes, forKey: "attributes")
        encoder.encodeObject(self.index, forKey: "index")
      end


      def current_index=(number)
        self.index = number
      end


      def ==(other)
        self.class == other.class && self.name == other.name && self.index == other.index
      end


      def current_value
        fmt = Token::Provider.date_formatter
        fmt.dateFormat = self.current_string
        fmt.stringFromDate(Provider.date)
      end
      alias to_s current_string
    end
  end
  
end
