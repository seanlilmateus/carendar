module Carendar
  module Token
    class Component

      def self.automaticallyNotifiesObserversForKey(key)
        true
      end


      def initialize(name = nil, type = nil, items = [], index = 0)
        self.name, self.type, self.index = name, type, index
        #timezone = NSTimeZone.timeZoneWithAbbreviation()
        self.attributes = NSArray.arrayWithArray(items)
      end
      attr_accessor :name, :type, :attributes, :index


      def initWithCoder(decoder)
        self.tap do |instance|
          instance.name = decoder.decodeObjectOfClass(NSString, forKey: "name")
          instance.type = decoder.decodeObjectOfClass(NSString, forKey: "type")
          instance.attributes = decoder.decodeObjectOfClass(NSArray, forKey: "attributes")
          instance.index = decoder.decodeObjectOfClass(NSNumber, forKey: "index") || 0
        end
      end


      def to_s
        self.attributes[self.index]
      end


      def encodeWithCoder(encoder)
        encoder.encodeObject(self.name, forKey: "name")
        encoder.encodeObject(self.type, forKey: "type")
        encoder.encodeObject(self.attributes, forKey: "attributes")
        encoder.encodeObject(self.index, forKey: "index")
      end


      def ==(other)
        self.class == other.class && self.name == other.name && self.index == other.index
      end


      def value
        fmt = Token::Provider.date_formatter
        fmt.dateFormat = self.to_s
        fmt.stringFromDate(Provider.date)
      end

    end
  end
end
