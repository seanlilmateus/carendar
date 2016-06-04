module Carendar
  class CalendarCell < NSButton

    attr_reader :selected, :representedDate
    attr_accessor :owner

    def initWithFrame(frame)
      super.tap { common_init }
    end


    def today?
      return false unless self.representedDate
      self.representedDate.isInSameDayAsDate(NSDate.date)
    end


    def selected=(flag)
      @selected = flag
      self.needsDisplay = true
    end


    def representedDate=(represented_date)
      @representedDate = represented_date
      self.title = if @representedDate
        unit_flags = NSCalendarUnitDay
        components = CalendarController.calendar
                                       .components(unit_flags, fromDate: @representedDate)
        "#{components.day}"
      else
        NSString.string
      end
    end


    def drawRect(dirty_rect)
      if self.owner
        NSGraphicsContext.saveGraphicsState
        bounds = self.bounds

        if self.representedDate
        
          paragraph_style = NSMutableParagraphStyle.new
          paragraph_style.lineBreakMode = NSLineBreakByWordWrapping
          paragraph_style.alignment = NSCenterTextAlignment
          
          props = {
            NSParagraphStyleAttributeName  => paragraph_style,
            NSFontAttributeName            => self.font,
            NSForegroundColorAttributeName => NSColor.controlTextColor
          }
          
          circe_rect = NSInsetRect(bounds, 3.5, 3.5)
          circe_rect.origin.y += 1
          bzc = NSBezierPath.bezierPathWithOvalInRect(circe_rect)
          self.owner.dayMarkerColor.set
          bzc.lineWidth = 0.3
          bzc.stroke
          
          if(self.today?) && !self.selected
            props[NSForegroundColorAttributeName] = NSColor.selectedMenuItemTextColor
            self.owner.selectionColor.set
            bzc.fill
          end
          
          if self.selected
            color = NSColor.alternateSelectedControlColor
            color.set
            bzc.fill
            props[NSForegroundColorAttributeName] = NSColor.selectedMenuItemTextColor
            if self.today?
              self.owner.selectionColor.set
              bzc.lineWidth = 1.5
              bzc.stroke
            end
          end
          
          size = self.title.sizeWithAttributes(props)
          y = bounds.origin.y + ((bounds.size.height - size.height)/2.0) + 1
          rect = NSRect.new([bounds.origin.x, y], [bounds.size.width, size.height])
          self.title.drawInRect(rect, withAttributes:props)
        end
        NSGraphicsContext.restoreGraphicsState
      end
    end


    private
    def common_init
      self.bordered = true
      self.title = ""
      self.font = NSFont.fontWithName('.HelveticaNeueDeskInterface-Regular', size:18.0)
      self.representedDate = nil
      self.enabled = true
    end

  end
end
