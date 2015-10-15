module Carendar
  class AboutWindowController < NSWindowController
    def self.hide_standard_window_buttons(win)
      close_button = win.standardWindowButton(NSWindowCloseButton)
      minimize_button = win.standardWindowButton(NSWindowMiniaturizeButton)
      if minimize_button
        minimize_button.hidden = true
      end
      
      zoom_button = win.standardWindowButton(NSWindowZoomButton)
      if zoom_button
        zoom_button.hidden = true
      end
    end
    
    def init
      rect = NSRect.new([196, 240], [560, 320])
      mask = NSTitledWindowMask|NSClosableWindowMask
      window = NSWindow.alloc.initWithContentRect(rect, styleMask:mask, backing:NSBackingStoreBuffered, defer:true)
      window.titleVisibility = NSWindowTitleHidden
      window.titlebarAppearsTransparent = true
      window.styleMask |= NSFullSizeContentViewWindowMask
      
      window.minSize = rect.size
      window.contentSize = rect.size
      window.releasedWhenClosed = true
      #window.releasedWhenClosed = true
      window.collectionBehavior = NSWindowCollectionBehaviorCanJoinAllSpaces
      initWithWindow(window).tap do |instance|
        @information = AppInfo.new
        instance.window.title = "About #{@information.name}"
        AboutWindowController.hide_standard_window_buttons(window)
      end
    end
    
    def main_view
      @__main_view__ ||= NSView.new.tap do |mv|
        mv.extend(Layout::View)
        self.window.contentView.extend(Layout::View)
        mv.translatesAutoresizingMaskIntoConstraints = false
        mv.wantsLayer = true
      
        self.window.contentView.addSubview(mv)
        self.window.contentView.addConstraints([
          mv.width == self.window.contentView.width,
          mv.height == self.window.contentView.height,
        ])
        
        width = CGRectGetWidth(self.window.contentView.frame) + 2.0
        height = CGRectGetHeight(self.window.contentView.frame) + 1.0
        
        mv.addSubview(information_view)
        mv.addSubview(bottom_view)
        mv.addConstraints([
          bottom_view.width == mv.width,
          bottom_view.centerX == mv.centerX,
          bottom_view.bottom == mv.bottom, 
          bottom_view.height == 50.0,
        
          information_view.width == mv.width,
          information_view.centerX == mv.centerX,
          information_view.top == mv.top,
          information_view.height == mv.height - 50,
        ])
      end
    end
    
    def windowDidLoad
      main_view
      self.window.center
    end
    
    def information_view
      @__information_view__ ||= NSView.new.tap do |cv|
        cv.extend(Layout::View)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.wantsLayer = true
        cv.backgroundColor = NSColor.whiteColor
        cv.addSubview icon_image_view
        cv.addSubview name_text_field
        cv.addSubview version_text_field
        cv.addSubview copyright_text_field
        cv.addSubview credits_text_view
        
        cv.addConstraints([
          icon_image_view.width == 100,
          icon_image_view.top == cv.top + 50,
          icon_image_view.left == cv.left + 50,
          icon_image_view.height >= 90,
          
          name_text_field.top == cv.top + 12,
          version_text_field.top == name_text_field.bottom,
          credits_text_view.top == version_text_field.bottom,
          copyright_text_field.bottom == cv.bottom - 5,
          
          name_text_field.width == 350,
          name_text_field.right == cv.right,
          
          version_text_field.width == 350,
          version_text_field.right == cv.right,
          
          credits_text_view.width == 350,
          credits_text_view.right == cv.right,
          credits_text_view.bottom == copyright_text_field.top,
          
          copyright_text_field.left == cv.left + 12,
        ])
      end
    end
    
    def name_text_field
      @__name_text__ ||= NSTextField.alloc.init.tap do |tf|
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.bezeled = false
        tf.editable = false
        tf.selectable = false
        tf.drawsBackground = false
        tf.stringValue = @information.name
        tf.font = NSFont.boldSystemFontOfSize(22)
        tf.extend(Layout::View)
      end
    end
    
    def version_text_field
      @__version__ ||= NSTextField.alloc.init.tap do |tf|
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.textColor = NSColor.disabledControlTextColor
        tf.bezeled = false
        tf.editable = false
        tf.selectable = false
        tf.drawsBackground = false
        tf.stringValue = @information.version
        tf.font = NSFont.boldSystemFontOfSize(NSFont.smallSystemFontSize)
        tf.extend(Layout::View)
      end
    end
    
    def copyright_text_field
      @__copyright__ ||= NSTextField.alloc.init.tap do |tf|
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.bezeled = false
        tf.editable = false
        tf.selectable = false
        tf.drawsBackground = false
        tf.textColor = NSColor.disabledControlTextColor
        tf.stringValue = @information.copyright
        tf.font = NSFont.systemFontOfSize NSFont.smallSystemFontSize
        tf.extend(Layout::View)
      end
    end
    
    def icon_image_view
      @__icon_image_view__ ||= NSImageView.alloc.init.tap do |imgv|
        imgv.extend(Layout::View)
        imgv.translatesAutoresizingMaskIntoConstraints = false
        imgv.imageAlignment = NSImageAlignCenter
        imgv.imageScaling = NSImageScaleProportionallyUpOrDown
        imgv.image = @information.icon #NSApplicationIcon
      end
    end
    
    def segment
      @segment ||= NSSegmentedControl.new.tap do |seg|
        seg.extend(Layout::View)
        seg.segmentCount = 2
        seg.selectedSegment = 0
        seg.translatesAutoresizingMaskIntoConstraints = false
        seg.trackingMode = NSSegmentSwitchTrackingSelectOne
        seg.segmentStyle = NSSegmentStyleTexturedSquare
        seg.setLabel localized_string("Acknowledgements"), forSegment:0
        seg.setLabel localized_string("License"), forSegment:1
        seg.target = self
        seg.action = 'toggle_credits:'
      end
    end
    
    def credits_text_view
      @__scroll_view__ ||= AutoScrollingTextView.alloc.init.tap do |scr|
        scr.translatesAutoresizingMaskIntoConstraints = false
        scr.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable
        scr.attributedString = @information.credits
        scr.extend(Layout::View)
      end
    end
    
    def toggle_credits(sender)
      text = case sender.selectedSegment
        when 0 then @information.credits
        when 1 then @information.license
      end
      credits_text_view.attributedString = text
    end
    
    def bottom_view
      @__bottom_view__ ||= NSVisualEffectView.new.tap do |bv|
        bv.extend(Layout::View)
        bv.material = NSVisualEffectMaterialDark
        bv.translatesAutoresizingMaskIntoConstraints = false
        bv.addSubview(segment)
        bv.addConstraints([
          segment.right == bv.right - 10,
          segment.centerY == bv.centerY,
        ])
      end
    end
    
  end
end