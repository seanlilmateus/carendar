module Carendar
  class PopoverController

    def initialize
      @popover_delegate = PopoverDelegate.new WeakRef.new(status_item)
      status_item.button.title  = 'Carendar'
      status_item.button.action = 'show_popover:'
      mask = NSLeftMouseDownMask | NSRightMouseDownMask | NSKeyUpMask
      @event_monitor = EventMonitor.new(mask) do |event|
        view = content_view_controller.view
        point = view.convertPoint(event.locationInWindow, fromView:nil)
        close_popover(event) unless view.mouse(point, inRect:view.bounds)
      end
      @event_monitor.start
    end


    def status_item
      @__status_item__ ||= begin
        sb = NSStatusBar.systemStatusBar
                        .statusItemWithLength(NSVariableStatusItemLength)
        sb.button.imagePosition = NSNoImage
        sb.button.cell.extend(StatusButtonCell)
        sb.highlightMode = true
        sb.button.target = self
        sb.button.sendActionOn(NSLeftMouseDownMask|NSRightMouseDownMask)
        sb
      end
    end


    def popover
      @_popover ||= NSPopover.alloc.init.tap do |pop|
        pop.contentViewController = content_view_controller
        pop.appearance = NSPopoverAppearanceMinimal
        pop.behavior = NSPopoverBehaviorTransient
        pop.animates = true
        pop.delegate = popover_delegate
      end
    end


    def content_view_controller
      @__content_view_controller__ ||= ContentViewController.new
    end


    def toggle_popover(sender=nil)
      if self.popover.shown?
        close_popover(sender)
      else
        show_popover(sender)
      end
    end


    def show_popover(sender)
      status_item.button.cell.instance_variable_set(:@activated, true)
      button, frame = status_item.button, status_item.button.frame
      popover.showRelativeToRect(frame, ofView:button, preferredEdge: NSMaxYEdge)
      @event_monitor.start
    end


    def close_popover(sender)
      @event_monitor.stop
      popover_delegate.instance_variable_set(:@__contract_, true)
      unless popover_delegate.detached_window_visible?
        self.popover.performClose(sender) 
      end
    end

    private
    attr_reader :popover_delegate
  end
end
