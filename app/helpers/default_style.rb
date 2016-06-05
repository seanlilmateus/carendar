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