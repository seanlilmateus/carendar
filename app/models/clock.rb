module Carendar
  CURRENT_FORMAT = NSString.stringWithString("current_format")
  
  class Clock


    def initialize(secs=1.0, &block)
      raise ArgumentError, "Missing block" unless block_given?
      @queue  = Dispatch::Queue.new 'carendar.timer'
      @action = block.weak!
      register_as_observer
      @flash_sepatators = false
      @blink = true
      timer
    end
    attr_reader :queue


    def register_as_observer
      opts = NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial
      defaults = DEFAULTS
      defaults.addObserver( self,
                forKeyPath: CURRENT_FORMAT,
                   options: opts,
                   context: nil)
    end

    def deregister_as_observer
      defaults = DEFAULTS
      defaults.removeObserver(self, forKeyPath: CURRENT_FORMAT)
    end


    def cancel
      timer.cancel!
      @timer = nil
      deregister_as_observer
    end

    def dealloc
      deregister_as_observer
      super
    end


    def tick(time)
      Dispatch::Queue.main.sync do
        value = if @flash_sepatators && @blink
          @blink = false
          output.gsub(":", " ")
        else
          @blink = true
          output
        end
        @action.call(value)
      end
    end


    private
    def timer
      @timer ||= Dispatch::Source.timer(0, 1, 0, queue, &method(:tick))
    end


    def format
      @__format__ ||= "HH:mm"
    end


    def formatter
      @formatter ||= NSDateFormatter.new
      @formatter.dateFormat = format
      @formatter
    end


    def observeValueForKeyPath(keyPath, ofObject:obj, change:change, context:ctxt)
      if keyPath == CURRENT_FORMAT
        new_value = change[NSKeyValueChangeNewKey]
        if new_value
          values = NSKeyedUnarchiver.unarchiveObjectWithData(new_value)
          func = Proc.new { |c| c.is_a?(String) ? "'#{c}'" : c.to_s }
          @__format__ = values.map(&func).join
        end
      else
        super
      end
    end


    def output
      formatter.stringFromDate NSDate.date
    end

  end
end
