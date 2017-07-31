module Carendar
  class AboutWindowController < NSWindowController

    def self.hide_standard_window_buttons(win)
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
        mv.translatesAutoresizingMaskIntoConstraints = false
        mv.wantsLayer = true
      
        self.window.contentView.addSubview(mv)
        mv.addSubview(information_view)
        mv.addSubview(bottom_view)
        
        NSLayoutConstraint.activateConstraints([
          mv.widthAnchor.constraintEqualToAnchor(self.window.contentView.widthAnchor),
          mv.heightAnchor.constraintEqualToAnchor(self.window.contentView.heightAnchor),
      
          bottom_view.widthAnchor.constraintEqualToAnchor(mv.widthAnchor),
          bottom_view.centerXAnchor.constraintEqualToAnchor(mv.centerXAnchor),
          bottom_view.bottomAnchor.constraintEqualToAnchor(mv.bottomAnchor),
          bottom_view.heightAnchor.constraintEqualToConstant(50.0),
        
          information_view.widthAnchor.constraintEqualToAnchor(mv.widthAnchor),
          information_view.centerXAnchor.constraintEqualToAnchor(mv.centerXAnchor),
          information_view.topAnchor.constraintEqualToAnchor(mv.topAnchor),
          information_view.heightAnchor.constraintEqualToAnchor(mv.heightAnchor, constant: -50),
        ])
      end
    end


    def windowDidLoad
      main_view
      self.window.center
    end


    def information_view
      @__information_view__ ||= NSView.new.tap do |cv|
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.wantsLayer = true
        cv.backgroundColor = NSColor.whiteColor
        cv.addSubview icon_image_view
        cv.addSubview name_text_field
        cv.addSubview version_text_field
        cv.addSubview copyright_text_field
        cv.addSubview credits_text_view
        
        NSLayoutConstraint.activateConstraints([
          icon_image_view.widthAnchor.constraintEqualToConstant(100),
          icon_image_view.topAnchor.constraintEqualToAnchor(cv.topAnchor, constant: 50),
          icon_image_view.leftAnchor.constraintEqualToAnchor(cv.leftAnchor, constant: 50),
          icon_image_view.heightAnchor.constraintGreaterThanOrEqualToConstant(90),
          
          name_text_field.topAnchor.constraintEqualToAnchor(cv.topAnchor, constant: 12),
          version_text_field.topAnchor.constraintEqualToAnchor(name_text_field.bottomAnchor),
          credits_text_view.topAnchor.constraintEqualToAnchor(version_text_field.bottomAnchor),
          copyright_text_field.bottomAnchor.constraintEqualToAnchor(cv.bottomAnchor, constant: -5),
          
          name_text_field.widthAnchor.constraintEqualToConstant(350),
          name_text_field.rightAnchor.constraintEqualToAnchor(cv.rightAnchor),
          
          version_text_field.widthAnchor.constraintEqualToConstant(350),
          version_text_field.rightAnchor.constraintEqualToAnchor(cv.rightAnchor),
          
          credits_text_view.widthAnchor.constraintEqualToConstant(350),
          credits_text_view.rightAnchor.constraintEqualToAnchor(cv.rightAnchor),
          credits_text_view.bottomAnchor.constraintEqualToAnchor(copyright_text_field.topAnchor),
          
          copyright_text_field.leftAnchor.constraintEqualToAnchor(cv.leftAnchor, constant: 12),
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
      end
    end


    def icon_image_view
      @__icon_image_view__ ||= NSImageView.alloc.init.tap do |imgv|
        imgv.translatesAutoresizingMaskIntoConstraints = false
        imgv.imageAlignment = NSImageAlignCenter
        imgv.imageScaling = NSImageScaleProportionallyUpOrDown
        imgv.image = @information.icon
      end
    end


    def segment
      @segment ||= NSSegmentedControl.new.tap do |seg|
        seg.segmentCount = 2
        seg.selectedSegment = 0
        seg.translatesAutoresizingMaskIntoConstraints = false
        seg.trackingMode = NSSegmentSwitchTrackingSelectOne
        seg.segmentStyle = NSSegmentStyleTexturedSquare
        seg.setLabel(localized_string("Acknowledgements"), forSegment: 0)
        seg.setLabel(localized_string("License"), forSegment: 1)
        seg.target = self
        seg.action = 'toggle_credits:'
      end
    end


    def credits_text_view
      @__scroll_view__ ||= AutoScrollingTextView.alloc.init.tap do |scr|
        scr.translatesAutoresizingMaskIntoConstraints = false
        scr.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable
        scr.attributedString = @information.credits
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
        bv.material = NSVisualEffectMaterialDark
        bv.translatesAutoresizingMaskIntoConstraints = false
        bv.addSubview(segment)
        NSLayoutConstraint.activateConstraints([
          segment.rightAnchor.constraintEqualToAnchor(bv.rightAnchor, constant: -10),
          segment.centerYAnchor.constraintEqualToAnchor(bv.centerYAnchor),
        ])
      end
    end
    
  end
end
