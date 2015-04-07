module Carendar
  class TableHeaderCell < NSTextField
    
    def self.cellClass; CustomTextFieldCell; end
    def self.layerClass; CALayer; end
  
    def initWithFrame(frame)
      super.tap do |tf|
        tf.wantsLayer = true 
        tf.layer.backgroundColor = NSColor.colorWithCalibratedWhite(0.961, alpha:1.0).CGColor
      
        tf.bezelStyle = NSTextFieldRoundedBezel      
        tf.font = NSFont.fontWithName('HelveticaNeue-Bold', size: 16)
        tf.editable  = false
        tf.bezeled   = false
        tf.alignment = NSNaturalTextAlignment
      end
    end
  
    class CustomTextFieldCell < NSTextFieldCell
      PADDING_MARGIN = 13.0
  
      def titleRectForBounds(theRect)
        titleFrame = super(theRect)
        # Padding on left side
        titleFrame.origin.x = PADDING_MARGIN
        # Padding on right side
        titleFrame.size.width -= (2 * PADDING_MARGIN)
        titleFrame
      end
  
  
      def selectWithFrame(rect, inView:controlView, editor:editor, delegate:object, start:start, length:length)
        textFrame = rect
    
        textFrame.origin.x += PADDING_MARGIN
        textFrame.size.width -= (2* PADDING_MARGIN)
        super(textFrame, controlView, editor, object, start, length)
      end
  
      def drawInteriorWithFrame(cellFrame, inView:controlView)
        titleRect = self.titleRectForBounds(cellFrame)
        self.attributedStringValue.drawInRect(titleRect)
      end
    end
    
  end
end