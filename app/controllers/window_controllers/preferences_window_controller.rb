module Carendar
  class PreferencesWindowController < NSWindowController  
    def init
      rect = NSRect.new([196, 240], [500, 470])
      mask = NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask
      window = NSWindow.alloc.initWithContentRect(rect,styleMask: mask, 
                          backing: NSBackingStoreBuffered, defer: false)
      window.minSize = rect.size
      window.contentSize = rect.size
      window.releasedWhenClosed = true
      window.collectionBehavior = NSWindowCollectionBehaviorCanJoinAllSpaces
      window.title = localized_string("Preferences")
      initWithWindow(window).tap do |instance|
        @content_controller = PreferencesViewController.new
        instance.load_window
      end
    end
    
    def load_window
      @toolbar_delegate = PreferencesToolbarDelegate.new
      toolbar = NSToolbar.alloc.initWithIdentifier('Preferences Toolbar').tap do |tb|
        #tb.allowsUserCustomization = true
        tb.autosavesConfiguration  = true
        tb.showsBaselineSeparator = true
        tb.delegate = @toolbar_delegate
      end
      @content_controller.view.frame = NSRect.new(NSPoint.new, self.window.contentView.frame.size)
      self.window.contentView.addSubview(@content_controller.view)
      @content_controller.update_view_constraints
      toolbar.selectedItemIdentifier = PreferencesToolbarDelegate::GENERAL_IDENTIFIER
      self.window.toolbar = toolbar
      self.window.center
    end
  end
end