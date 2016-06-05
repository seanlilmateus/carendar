module Carendar
  class CalendarCell < NSView
    include Style
    def initWithFrame(frame)
      super.tap do |instance|
        instance.wantsLayer = true
      end
    end


    def prepareForReuse
      super
      @selected = false
      @active = true
    end


    def active?; @active; end
    def active=(value)
      @active = value
      self.needsDisplay = true
    end


    def title
      self.representedObject.to_s
    end
    attr_accessor :highlightState


    def selected?; @selected; end
    def selected=(value)
      return if value == @selected
      @selected = value
      self.needsDisplay = true
    end


    def today?
      self.representedObject.isDateSameDay(NSDate.date)
    end


    def pulse
      self.layer.contentsGravity = "center";
      animation = CABasicAnimation.animationWithKeyPath("transform.scale")
      animation.toValue = 1.05
      animation.duration = 0.25
      timing = KCAMediaTimingFunctionEaseInEaseOut
      animation.timingFunction = CAMediaTimingFunction.functionWithName(timing)
      animation.autoreverses = true
      animation.repeatCount = 2.0
      animation.removedOnCompletion = true
      self.layer.addAnimation(animation, forKey: "transform.scale")
    end


    def representedObject=(value)
      @representedObject = value
      self.needsDisplay = true
    end
    attr_reader :representedObject


    def drawRect(dirty)
      if self.representedObject
        NSGraphicsContext.saveGraphicsState
        # Stroke Section
        case
        when self.today? && self.selected?
          draw_today_selected_label
        when self.today?
          draw_today_label
        when self.selected?
          draw_selected_label
        when !self.active?
          draw_inactive_label
        else
          draw_normal_label
        end
      
        NSGraphicsContext.restoreGraphicsState
      end
    end


    private
    def weekend?
      self.representedObject.weekend?
    end


    # create attribute for text
    def create_attributes(color)
      if weekend? && !(self.selected? || self.today?)
        color = TODAY_BACKGROUND_COLOR
        color = color.colorWithAlphaComponent(0.2) unless self.active?
      end
      {
        NSFontAttributeName => DEFAULT_FONT,
        NSForegroundColorAttributeName => color,
        NSParagraphStyleAttributeName  => PARAGRAPH_STYLE
      }
    end



    #### NORMAL TODAY LABEL
    def draw_today_label
      # Oval Drawing
      draw_border(BORDER_COLOR, TODAY_BACKGROUND_COLOR)
      # Text Drawing
      attributes = create_attributes(NORMAL_BACKGROUND)
      draw_text(attributes)
    end


    ### SELECTED LABEL
    def draw_selected_label
      # Oval Drawing
      draw_border(BORDER_COLOR, STRONG_SELECTED_BACKGROUND)
      # title_label Drawing
      attributes = create_attributes(NSColor.whiteColor)
      draw_text(attributes)
    end


    ###### NORMAL LABEL TITLE
    def draw_normal_label
      # Oval Drawing
      draw_border(BORDER_COLOR)
      attributes = create_attributes(NSColor.labelColor)
      draw_text(attributes)
    end


    def draw_inactive_label
      draw_border(BORDER_COLOR)
      text_color = NSColor.labelColor.colorWithAlphaComponent(0.2)
      attributes = create_attributes(text_color)
      draw_text(attributes)
    end


    #### SELECTED TODAY LABEL
    def draw_today_selected_label
      # General Declarations
      context = NSGraphicsContext.currentContext.CGContext
      # Oval Drawing
      #rect = NSRect.new([1.5, 1.5], [35, 35])
      bounds = self.bounds
      circe_rect = NSInsetRect(bounds, 1.0, 1.0)
      oval_path = NSBezierPath.bezierPathWithOvalInRect(circe_rect)
      STRONG_SELECTED_BACKGROUND.setFill
      oval_path.fill
    
      # draw_border(TODAY_BACKGROUND_COLOR, STRONG_SELECTED_BACKGROUND)
      # Oval Inner Shadow
      NSGraphicsContext.saveGraphicsState
      NSRectClip(oval_path.bounds)
      CGContextSetShadowWithColor(context, CGSize.new, 0, nil)

      CGContextSetAlpha(context, DEFAULT_SHADOW.shadowColor.alphaComponent)
      CGContextBeginTransparencyLayer(context, nil)
      begin
        opaque_shadow = NSShadow.new
        opaque_shadow.shadowColor = DEFAULT_SHADOW.shadowColor
                                                  .colorWithAlphaComponent(1)
        opaque_shadow.shadowOffset = DEFAULT_SHADOW.shadowOffset
        opaque_shadow.shadowBlurRadius = DEFAULT_SHADOW.shadowBlurRadius
        opaque_shadow.set
        CGContextSetBlendMode(context, KCGBlendModeSourceOut)
        CGContextBeginTransparencyLayer(context, nil)
        opaque_shadow.shadowColor.setFill
        oval_path.fill
        CGContextEndTransparencyLayer(context)
      end

      CGContextEndTransparencyLayer(context)
      NSGraphicsContext.restoreGraphicsState

      TODAY_BACKGROUND_COLOR.setStroke
      oval_path.lineWidth = 0.8
      oval_path.stroke

      # Text Drawing
      attributes = create_attributes(NORMAL_BACKGROUND)
      draw_text(attributes)
    end


    # Draw Border
    def draw_border(border_color, fill_color=nil)
      bounds = self.bounds
      circe_rect = NSInsetRect(bounds, 1.5, 1.5)
      circe_rect.origin.y += 1
      bzc = NSBezierPath.bezierPathWithOvalInRect(circe_rect)
      unless fill_color.nil?
        fill_color.setFill
        bzc.fill
      end
      bzc_color = border_color.colorWithAlphaComponent(0.3)
      border_color.set
      bzc.lineWidth = 0.3
      bzc.stroke
    end


    # Text Drawing
    def draw_text(attributes)
      # Text Drawing
      text = representedObject.day.to_s
      text_rect = NSRect.new([0, 7], [35, 22])
      opts = NSStringDrawingUsesLineFragmentOrigin
      calc = text.boundingRectWithSize(text_rect.size, 
                               options:opts, attributes: attributes)
      height = NSHeight(calc)
      origin = [
        NSMinX(text_rect), 
        NSMinY(text_rect) + (NSHeight(text_rect) - height) / 2.0
      ]
      tmp_rect = NSRect.new(origin, [NSWidth(text_rect), height])
      NSGraphicsContext.saveGraphicsState
      NSRectClip(text_rect)
      rect = NSOffsetRect(tmp_rect, 0, 1)
      text.drawInRect(rect, withAttributes: attributes)
      NSGraphicsContext.restoreGraphicsState
    end
  end
end
