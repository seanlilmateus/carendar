module Carendar
  class PopoverController
    
    def initialize
      @popover_delegate = PopoverDelegate.new WeakRef.new(status_item)
      status_item.button.title  = 'Tue. 9:41'
      status_item.button.action = 'show_popover:'
    end
    
    
    def status_item
      @__status_item__ ||= begin
        sb = NSStatusBar.systemStatusBar.statusItemWithLength(IMAGE_VIEW_WIDTH)
        sb.button.image = NSImage.imageNamed('icon_normal').tap do |img|
          img.template = true
          img.size = NSSize.new(20, 20)
        end
        sb.button.cell.extend(StatusButtonCell)
        sb.highlightMode = true
        sb.button.target = self
        sb.button.imagePosition = NSImageLeft
        sb.button.sendActionOn(NSLeftMouseDownMask|NSRightMouseDownMask)
        sb
      end
    end
    
    
    def popover
      @_popover ||= NSPopover.alloc.init.tap do |pop|
        #pop.appearance = NSAppearance.appearanceNamed(NSAppearanceNameAqua)
        pop.contentViewController = content_view_controller
        pop.appearance = NSPopoverAppearanceMinimal
        pop.behavior = NSPopoverBehaviorTransient # NSPopoverBehaviorSemitransient
        pop.animates = true
        pop.delegate = popover_delegate
      end
    end
    
    
    def content_view_controller
      @__content_view_controller__ ||= ContentViewController.new
    end
    
    
    def show_popover sender
      flags, type = [NSApp.currentEvent.modifierFlags, NSApp.currentEvent.type]
      lhs_opts = (flags & NSAlternateKeyMask)
      ctrl_click = lhs_opts == NSAlternateKeyMask ||(type == NSRightMouseDown)
      popover_presenter
    end
    
    
    def hide_popover
      if self.popover.shown?
        NSEvent.removeMonitor(@__monitor__)
        @__monitor__ = nil
        popover_delegate.instance_variable_set(:@__contract_, true)
        self.popover.close        
      end
    end
    
    private
    attr_reader :popover_delegate
    
    def popover_presenter
      unless self.popover.shown?
        status_item.button.cell.instance_variable_set(:@activated, true)
        button, frame = status_item.button, status_item.button.frame
        popover.showRelativeToRect(frame, ofView:button, preferredEdge: NSMaxYEdge)
        make_popover_transient
      end
    end
    
    def make_popover_transient
      mask = NSLeftMouseDownMask | NSRightMouseDownMask | NSKeyUpMask
      @__monitor__ ||= NSEvent.addGlobalMonitorForEventsMatchingMask(mask, handler:-> event {
        view = content_view_controller.view
        point = view.convertPoint(event.locationInWindow, fromView:nil)
        hide_popover unless view.mouse(point, inRect:view.bounds)
      })
    end
    
  end
  
end
