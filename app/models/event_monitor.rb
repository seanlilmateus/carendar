module Carendar
  class EventMonitor
    def initialize(mask, &handler)
      @mask, @handler = mask, handler.weak!
    end


    def dealloc
      stop
      super
    end


    def start
      @monitor ||= NSEvent.addGlobalMonitorForEventsMatchingMask(@mask, handler:@handler)
    end


    def stop
      unless @monitor.nil?
        NSEvent.removeMonitor(@monitor)
        @monitor = nil
      end
    end
  end
end