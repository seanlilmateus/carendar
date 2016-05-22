module Carendar
  class SwitchControl < NSControl

    def initWithFrame(frame)
      super
      self
    end


    def init
      super.tap { commonInitializer }
    end


    attr_reader :rootLayer, :backgroundLayer, :knobLayer, :knobInsideLayer
    attr_accessor :active, :isOn
    alias_method :active?, :active


    def dragged?
      @dragged
    end


    def draggingTowardsOn?
      @draggingTowardsOn
    end


    KNOB_BACKGROUND_COLOR = NSColor.colorWithCalibratedWhite(1.0, alpha:1.0)
    DISABLED_BORDER_COLOR = NSColor.colorWithCalibratedWhite(0.0, alpha:0.2)
    DEFAULT_TINT_COLOR = NSColor.colorWithCalibratedRed(0.27, green:0.86, blue:0.36, alpha:1.0)
    DISABLED_BACKGROUND_COLOR = NSColor.clearColor
    DECREASED_GOLDEN_RATIO = 1.38
    GOLDEN_RATIO = 1.61803398875
    ANIMATION_DURATION = 0.4
    BORDER_LINE_WIDTH = 1.0


    def acceptsFirstMouse(_)
      true
    end


    def acceptsFirstResponder
      true
    end


    def mouseDown(_)
      self.active = true
      updateLayer
    end


    def mouseDragged(event)
      @dragged = true
      draggingPoint = self.convertPoint(event.locationInWindow, fromView:nil)
      @draggingTowardsOn = draggingPoint.x <= NSWidth(self.bounds) / 2.0
      updateLayer
    end


    def mouseUp(_)
      self.active = false
      is_on = !self.dragged? ? !self.isOn? : self.draggingTowardsOn?
      invoke = (is_on != self.isOn?)
      
      self.on = is_on
      
      if self.target && self.action && invoke
        self.target.send(self.action, self)
      end
      
      updateLayer
      # reset
      @dragged = false
      @draggingTowardsOn = false
    end


    def setIsOn(flag)
      if @isOn != flag
        self.willChangeValueForKey('isOn')
        @isOn = flag
        self.didChangeValueForKey('isOn')
      end
      updateLayer
    end
    alias on= setIsOn
    alias isOn? isOn


    def tintColor=(tint)
      @tintColor = tint
      self.setNeedsDisplay(true)
    end


    def tintColor
      @tintColor || DEFAULT_TINT_COLOR
    end


    def layoutSublayersOfLayer(_)
      animation_transaction do
        CATransaction.setDisableActions true
      
        self.backgroundLayer.cornerRadius = self.backgroundLayer.bounds.size.height / 2.0
        self.knobLayer.cornerRadius = self.knobLayer.bounds.size.height / 2.0
        self.knobInsideLayer.cornerRadius = self.knobLayer.bounds.size.height / 2.0
      end
    end


    def setFrame(frame)
      super
      animation_transaction do
        CATransaction.setDisableActions true
        self.knobLayer.frame = rectForKnob
        self.knobInsideLayer.frame = self.knobLayer.bounds
      end
    end


    private
    def updateLayer
      animation_transaction do
        CATransaction.animationDuration = ANIMATION_DURATION
        if (self.dragged? && self.draggingTowardsOn?) || (!self.dragged? && self.isOn?)
          self.backgroundLayer.borderColor = self.tintColor.CGColor
          self.backgroundLayer.backgroundColor = self.tintColor.CGColor
        else
          self.backgroundLayer.borderColor = DISABLED_BORDER_COLOR.CGColor
          self.backgroundLayer.backgroundColor = DISABLED_BACKGROUND_COLOR.CGColor
        end
        
        animation_transaction do
          CATransaction.animationDuration = ANIMATION_DURATION
          unless dragged?
            # bug http://hipbyte.myjetbrains.com/youtrack/issue/RM-123
            #function = CAMediaTimingFunction.functionWithControlPoints(0.25, 1.5, 0.5, 1.0)
            args = [0.25, 1.5, 0.5, 1.0]
            fn = CAMediaTimingFunction.objc_send('functionWithControlPoints::::', '@@:ffff', *args)
            CATransaction.setAnimationTimingFunction(fn)
          end
          
          self.knobLayer.frame = rectForKnob
          self.knobInsideLayer.frame = self.knobLayer.bounds
        end
      end
    end


    def knobHeightForSize(size)
      size.height - (BORDER_LINE_WIDTH * 2.0)
    end


    def rectForKnob
      height = knobHeightForSize(self.backgroundLayer.bounds.size)
      ratio = (NSWidth(@backgroundLayer.bounds) - 2.0 * BORDER_LINE_WIDTH) * 1.0 
      width = self.active? ? ratio / GOLDEN_RATIO : ratio / DECREASED_GOLDEN_RATIO
      
      x = if (!self.dragged? && !self.isOn?) || (self.dragged? && !self.draggingTowardsOn?)
        BORDER_LINE_WIDTH
      else
        NSWidth(self.backgroundLayer.bounds) - width - BORDER_LINE_WIDTH
      end
      
      CGRect.new([x, BORDER_LINE_WIDTH], [width, height])
    end


    def commonInitializer
      self.wantsLayer = true
      @isOn, @dragged, @draggingTowardsOn = false, false, false
      setupsLayers
    end


    def setupsLayers
      # Root Layer
      @rootLayer = CALayer.layer
      @rootLayer.delegate = self
      self.layer = @rootLayer
      
      # Background Layer
      @backgroundLayer = CALayer.layer.tap do |l|
        l.autoresizingMask = KCALayerWidthSizable | KCALayerHeightSizable
        l.bounds = @rootLayer.bounds
        l.anchorPoint = CGPoint.new
        l.borderWidth = BORDER_LINE_WIDTH
        l.backgroundColor = NSColor.redColor.CGColor
      end
      @rootLayer.addSublayer @backgroundLayer
      
      # Knob Layer
      @knobLayer = CALayer.layer.tap do |l|
        l.frame = rectForKnob
        l.autoresizingMask = KCALayerHeightSizable;
        l.backgroundColor = KNOB_BACKGROUND_COLOR.CGColor
        l.shadowOffset = CGSize.new(0.0, -2.0)
        l.shadowRadius = 1.0
        l.shadowColor = NSColor.blackColor.CGColor
        l.shadowOpacity = 0.3
      end
      @rootLayer.addSublayer @knobLayer
      
      @knobInsideLayer = CALayer.layer.tap do |l|
        l.frame = @knobLayer.bounds
        l.autoresizingMask = KCALayerWidthSizable | KCALayerHeightSizable
        l.shadowColor = NSColor.blackColor.CGColor
        l.shadowOffset = CGSize.new
        l.backgroundColor = NSColor.whiteColor.CGColor
        l.shadowRadius = 1.0
        l.shadowOpacity = 0.35
      end
      @knobLayer.addSublayer @knobInsideLayer
      updateLayer
    end


    def animation_transaction
      CATransaction.begin
      yield
      CATransaction.commit
    end

  end
end
