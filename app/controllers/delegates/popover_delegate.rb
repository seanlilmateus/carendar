module Carendar
  class PopoverDelegate

    def initialize(status_item)
      @status_button_cell = status_item.button.cell
    end

    def popoverWillShow(_)
      NSApp.unhide(nil)
      NSApp.activateIgnoringOtherApps(true)
      window = NSApp.windows.first
      def window.canBecomeKeyWindow; true; end
      window.becomeKeyWindow
    end

    # Without this the button cell will deactivate after the
    # status bar item was clicked, but we want it to keep 
    # highlighted as long as the Popover is visible
    def popoverWillClose(_)
      NSApp.activateIgnoringOtherApps(false)     
      status_button_cell.instance_variable_set(:@activated, false)
      status_button_cell.highlighted = false
      window = NSApp.windows.last
      def window.canBecomeKeyWindow; false; end
      window.resignKeyWindow
    end

    # Without this the animation acts weird...
    # In addition to that, we hide our app in order to bring
    # the previous application to the front
    def popoverDidClose(notif)
      popover = notif.object
      popover.animates = true
      windows = NSApp.windows
      if windows.count > 2
        window = windows.last
        def window.canBecomeKeyWindow; true; end
        window.becomeKeyWindow
      else
        NSApp.hide(nil) unless @__contract_
      end
      @__contract_ = false
    end

    def popoverDidShow(notif)
      popover = notif.object
      popover.animates = false
    end
        
    private
    attr_reader :status_button_cell
  end
end
