module Carendar
  class ColoredLayoutAttributes < NSCollectionViewLayoutAttributes
    def init
      super.tap do
        @color = NSColor.clearColor
        @backgroundColor = NSColor.clearColor
      end
    end
  
    attr_accessor :color
    attr_accessor :backgroundColor
  end
end