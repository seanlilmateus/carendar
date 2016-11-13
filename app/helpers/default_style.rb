module Style
  DEFAULT_FONT = NSFont.labelFontOfSize(18.0)
  NORMAL_BACKGROUND = NSColor.colorWithCalibratedRed(1, green:1, blue:1, alpha:1)
  SELECTED_BACKGROUND = NSColor.colorWithCalibratedRed(0.208, green:0.544, blue:0.976, alpha:1)
  TODAY_BACKGROUND_COLOR = NSColor.colorWithCalibratedRed(1, green:0, blue:0, alpha: 1)
  BORDER_COLOR = NSColor.colorWithCalibratedRed(0.333, green:0.333, blue:0.333, alpha:1)
  
  STRONG_SELECTED_BACKGROUND = NSColor.alternateSelectedControlColor
  PARAGRAPH_STYLE = NSMutableParagraphStyle.defaultParagraphStyle
                        .mutableCopy
                        .tap { |para| para.alignment = NSCenterTextAlignment }
  DEFAULT_SHADOW = NSShadow.alloc.init.tap do |shw|
    shw.shadowColor  = TODAY_BACKGROUND_COLOR
    shw.shadowOffset = NSSize.new(0.1, 0.1)
    shw.shadowBlurRadius = 2.0
  end
end

module ReusableView # NSCollectionViewElement
  def prepareForReuse
  end
  
  def applyLayoutAttributes(attributes)
  end
  
  def preferredLayoutAttributesFittingAttributes(attributes)
  end
  
  def willTransitionFromLayout(oldLayout, toLayout:newLayout)
  end
  
  def didTransitionFromLayout(oldLayout, toLayout:newLayout)
  end
end

def NSEdgeInsetsInsetRect(rect, insets)
   rect.origin.x += insets.left
   rect.origin.y += insets.top
   rect.size.width -= (insets.left + insets.right)
   rect.size.height -= (insets.top + insets.bottom)
   rect
end

module ViewBackGround
  def backgroundColor=(color)
    self.wantsLayer = true
    self.layer&.backgroundColor = color&.CGColor
  end
  
  module_function
  def readable_foreground(color)
     count = CGColorGetNumberOfComponents(color.CGColor)
     cpts = CGColorGetComponents(color.CGColor)
     darkness_score = if count == 2
        ((cpts[0]*255 * 299) + (cpts[0]*255 * 587) + (cpts[0] * 255 * 114)) / 1000
     elsif (count == 4)
        ((cpts[0]*255 * 299) + (cpts[1]*255 * 587) + (cpts[2]*255 * 114)) / 1000
     else
        0
     end
   
     return NSColor.blackColor if darkness_score >= 125
     NSColor.whiteColor
  end
end

module BezierPath
  module_function
  def to_CGPath(bezier_path)
    path = CGPathCreateMutable()
    element_count = bezier_path.elementCount
    closed = false
    pts = Pointer.new(NSPoint.type, 3)
    element_count.times do |i|
      case bezier_path.elementAtIndex(i, associatedPoints:p)
      when NSMoveToBezierPathElement then CGPathMoveToPoint(path, nil, pts[0].x, pts[0].y)
      when NSLineToBezierPathElement
        CGPathAddLineToPoint(path, nil, pts[0].x, pts[0].y)
        closed = false
      when NSCurveToBezierPathElement
        CGPathAddCurveToPoint(path, nil, pts[0].x, pts[0].y, pts[1].x, pts[1].y, pts[2].x, pts[2].y)
        closed = false
      when NSClosePathBezierPathElement
        CGPathCloseSubpath(path)
        closed = true
      end
    end

    CGPathCloseSubpath(path) unless closed
    CGPathCreateCopy(path)
  end
end

module Colorify
  DEFAULT_CONTROL = NSColor.colorForControlTint(NSDefaultControlTint)
  GRAPHITECONTROL = NSColor.colorForControlTint(NSGraphiteControlTint)
  BLUE_CONTROL = NSColor.colorForControlTint(NSBlueControlTint)
  CLEAR_CONTROL = NSColor.colorForControlTint(NSClearControlTint)
  LABEL_COLOR = NSColor.labelColor
  
  module_function
  def light?(color)
    components = CGColorGetComponents(color.CGColor)
    brightness = ((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000
    brightness > 0.7
  end
end

module TexturedString
  module_function
  def create(text, font, color=NSColor.colorWithCalibratedWhite(0.326, alpha:1.0))
    shadow = 
    
    attributes = {
      NSFontAttributeName => font,
      NSForegroundColorAttributeName => color,
      NSTextEffectAttributeName => NSTextEffectLetterpressStyle,
      # NSStrokeWidthAttributeName => 3.0,
      # NSShadowAttributeName => NSShadow.new.tap do |s|
      #   s.shadowOffset = CGSize.new(-2.0, -2.0)
      # end,
    }
    NSAttributedString.alloc.initWithString(text, attributes: attributes)
  end
end
#NSColor.labelColor
#NSColor.secondaryLabelColor
#NSColor.tertiaryLabelColor
#NSColor.quaternaryLabelColor
# color#colorWithAlphaComponent(0.25)
# color#highlightWithLevel: -> 0.0 through 1.0
