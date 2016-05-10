module Carendar
  class Clock
    include Dispatch
    def initialize(secs=1.0, &block)
      raise ArgumentError, "Missing block" unless block_given?
      @queue ||= Queue.new 'carendar.timer'
      @action = block.weak!
      register_as_observer
      @flash_sepatators = true
      @blink, @secs = true, secs
      start
    end
    attr_reader :queue


    def register_as_observer
      settings = SettingsModel.instance
      opts = NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
      settings.addObserver(self, forKeyPath: "current_format", options:opts, context:nil)
    end


    def start; timer; end
    
    def cancel
      timer.cancel!
      @timer = nil
    end
    
    def tick(_)
      value = output
      Queue.main.sync { @action.call(value) }
    end
    
    private
    def timer
      @timer ||= Source.timer(0, @secs, 0, queue, &method(:tick))
    end


    def formatter
      @formatter ||= NSDateFormatter.new
      @formatter.dateFormat = format
      @formatter
    end


    def format
      @__format__ ||= "HH:mm"
    end


    def observeValueForKeyPath(keyPath, ofObject:object, change:change, context:context)
      if keyPath == "current_format"
        @__format__ = object.current_format
                            .map { |c| c.is_a?(String) ? "'#{c}'" : c.to_s }
                            .join
        Dispatch::Queue.main.after(0.1) {
          length = calculate_width(formatter.stringFromDate(NSDate.new)) + 4
          NSApp.delegate.popover_controller.status_item.length = length
        }
      else
        super
      end
    end


    def output
      if @flash_sepatators && @blink
        formatter.dateFormat = format
        @__current_blink__ = !@__current_blink__
        formatter.dateFormat = @__current_blink__ ? format : format.gsub(":", " ")
      end
      formatter.stringFromDate NSDate.date
    end


    def calculate_width(string)
      font = NSApp.delegate.popover_controller.status_item.button.font
      attributes = { NSFontAttributeName => font }
      NSAttributedString.alloc
                        .initWithString(string, attributes:attributes)
                        .size
                        .width
    end
  end
end
