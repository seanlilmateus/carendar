module Carendar
  class VerticallyCenteredTextFieldCell < NSTextFieldCell
    def drawingRectForBounds(the_rect)
      new_rect = super(the_rect)
      text_size = self.cellSizeForBounds(the_rect)
      height_delta = new_rect.size.height - text_size.height
      if height_delta > 0
        new_rect.size.height -= height_delta
        new_rect.origin.y    += (height_delta / 2.0)
      end
      new_rect
    end


    def editWithFrame(frameRect, inView:controlView, editor:textObject, delegate:delegateObject, event:theEvent)
      super(drawingRectForBounds(frameRect), controlView, textObject, delegateObject, theEvent)
    end


    def selectWithFrame(frameRect, inView:controlView, editor:textObject, delegate:delegateObject, start:selStart, length:selLength)
      super(drawingRectForBounds(frameRect), controlView, textObject, delegateObject, selStart, selLength)
    end


    def drawWithFrame(cellFrame, inView:controlView)
      super(drawingRectForBounds(cellFrame), controlView)
    end
  end
  
  class Label < NSTextField
    class << self
      def cellClass
        VerticallyCenteredTextFieldCell
      end
    
      def create(text, frame=NSRect.new)
        alloc.initWithFrame(frame).tap do |instance|
          instance.stringValue = text
          instance.translatesAutoresizingMaskIntoConstraints = false
          yield(instance) if block_given?
        end
      end
    end


    def initWithFrame(frame)
      super.tap do |i|
        i.bezeled = false
        i.editable = false
        i.selectable = false
        i.drawsBackground = false
        i.textColor = NSColor.labelColor
        i.backgroundColor = NSColor.controlColor
        i.cell.lineBreakMode = NSLineBreakByClipping
      end
    end
    alias text stringValue
    alias text= setStringValue

  end
end