module Carendar
  class CellSeparator < NSView
    include ViewBackGround

    IDENTIFIER = NSString.stringWithString("CellSeparator")

    def initWithFrame(frame)
      super.tap do |instance|
        instance&.backgroundColor = DetailsHeaderView::SEP_COLOR
      end
    end


    def backgroundColor=(color)
      self.wantsLayer = true
      self.layer&.backgroundColor = color&.CGColor
    end


    def viewDidMoveToSuperview
      super
    end


    def applyLayoutAttributes(attributes)
      self.frame = attributes.frame
      self.backgroundColor = attributes.color if attributes.respond_to?(:color)
    end
  end


  class Line < NSView
    IDENTIFIER = NSString.stringWithString("LINE")
    def drawRect(dirty_rect)
      NSColor.controlHighlightColor.set
      NSBezierPath.fillRect(dirty_rect)
      super
    end
  end
end