module Carendar
  class NoScrollerView < NSScrollView
    def initWithFrame(frame)
      super.tap { hide_scrollers }
    end


    def hide_scrollers
      self.hasHorizontalScroller = false
      self.hasVerticalScroller = false
    end


    def scrollWheel(event); end
  end
end