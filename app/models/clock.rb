module Carendar
  class Clock

    include Dispatch

    def initialize(secs=1.0, &block)
      raise ArgumentError, "Missing block" unless block_given?
      @action = block.weak!
      @flash_sepatators = true
      @blink = true
      @secs = secs
      start
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

    def queue
      @queue ||= Queue.new 'carendar.timer'
    end

    def formatter
      @formatter ||= NSDateFormatter.new.tap do |df|
        df.dateFormat = format
      end
    end

    def format
      @__format__ ||= "HH:mm" #"HH:mm:ss"
    end

    def output
      if @flash_sepatators && @blink
        formatter.dateFormat = format
        @__current_blink__   = !@__current_blink__
        formatter.dateFormat = @__current_blink__ ? format : format.gsub(":", " ")
      end
      formatter.stringFromDate NSDate.date
    end

    def output_width
      formatter.format.length * 4.5
    end
  end
end
