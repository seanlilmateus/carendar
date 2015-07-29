module Carendar
  class AutoScrollingTextView < NSView
    attr_accessor :attributed_string
    attr_writer :background_color
    attr_reader :time, :text_rect
  
    def init
      super.tap do |instance|
        @pause_scrolling = false # don't pause at start up
        @background_color = NSColor.clearColor
      end
    end
  
    def viewWillMoveToSuperview(v)
      super
      @timer = NSTimer.scheduledTimerWithTimeInterval(0.03, 
                                               target: self, 
                                             selector: 'scroll_text:', 
                                             userInfo: nil,
                                              repeats: true)
    
    end
  
    def removeFromSuperview
      @timer.invalidate
      super
    end
  
    def scroll_text(timer)
      return if self.pause_scrolling?
      frame = self.bounds
      unless CGRectIntersectsRect(frame, @text_rect)
        @text_rect.origin.y = NSMaxY(self.bounds)
      end
      @text_rect.origin.y -= 1
      self.setNeedsDisplay(true) 
    end
    
    def attributedString=(attr_string)
      __attributed_string_setter__(attr_string)
    end
    
    def string=(value)
      @pause_scrolling = false
      dict = { 
        NSFontAttributeName => NSFont.fontWithName('Lucida Grande', size:10.0), 
        NSForegroundColorAttributeName => NSColor.colorWithDeviceRed(0.64, green:0.64, blue:0.64, alpha:1.0)
      }
      attributed_string = NSAttributedString.alloc.initWithString(value, attributes:dict)
      __attributed_string_setter__(attributed_string)
    end
  
    def pause_scrolling?
      @pause_scrolling
    end
  
    def drawRect dirty_rect
      frame = self.bounds
    
      # Draw background with backgroundColor
      @background_color.set
      NSRectFill(frame)
    
      # Draw atrtributed string
      @attributed_string.drawInRect(@text_rect)
    end
  
    def isFlipped
      true
    end
  
    def mouseDown(event)
      @pause_scrolling = !@pause_scrolling
    end
    
    private def __attributed_string_setter__(attributed_string)
      @attributed_string = attributed_string
      size = NSSize.new(330, attributed_string.size.height) #
      #opts = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
      #rect = attributed_string.boundingRectWithSize(NSSize.new(320, 10000), options:opts)
      #size = rect.size
      storage = NSTextStorage.alloc.initWithAttributedString(attributed_string)
      container = NSTextContainer.alloc.initWithContainerSize(size)
      manager = NSLayoutManager.new
      manager.addTextContainer(container)
      storage.addLayoutManager(manager)
      manager.glyphRangeForTextContainer(container)
      
      ideal_rect = NSRect.new(NSPoint.new, size)
      @text_rect = ideal_rect
      @text_rect.origin.y = NSMaxY(self.bounds)
      self.setNeedsDisplay(true)
    end
    
  end
end