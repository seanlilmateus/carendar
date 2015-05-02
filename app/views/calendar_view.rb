module Carendar
  class CalendarView < NSView

    def initWithFrame(frame)
      super.tap { common_init }
    end

    def next_button
      @__next_button__ ||= create_button([[245, 275], [16, 16]], 'NSRightFacingTriangleTemplate') do |btn|
        btn.identifier = 'Next Month'
      end
    end

    def prev_button
      @__prev_button__ ||= create_button([[17, 275], [16, 16]], 'NSLeftFacingTriangleTemplate') do |btn|
        btn.identifier = 'Previous Month'
      end
    end

    def calendarTitle
      @__month__ ||= create_text_field(NSRect.new([39, 271], [200, 25])) do |tf| 
        tf.stringValue = "January, 2015"
        tf.alignment = NSCenterTextAlignment
        tf.font = NSFont.fontWithName('.HelveticaNeueDeskInterface-Regular', size:17.0)
        # NSFont.fontWithName('HelveticaNeue-Light', size:17.0)
      end
    end

    def week_days
      @__day_buttons__ ||= begin
        width = 38.0
        [*0...7].zip(%W[SUN MON TUE WED THU FRI SAT]).map do |idx, day|
          x = 6.0 + (width * idx)
          create_text_field(NSRect.new([x, 243.0], [width, 21.0])) do |tf|
            tf.stringValue, tf.identifier = "#{day}", "day#{idx}"
            tf.textColor = NSColor.disabledControlTextColor
            tf.font = NSFont.fontWithName('.HelveticaNeueDeskInterface-Regular',
                                     size:15.5)
          end
        end
        
      end
    end

    def calendar_days
      @__other_buttons__ ||= begin
        width, row, column = 38.0, 6.0, 200
        Array.new(49) do |idx|
          rect = NSRect.new([row, column], [width, width])
          cell = CalendarCell.alloc.initWithFrame(rect)
          cell.identifier = "c#{idx+1}"
          cell.title = "#{idx+1}"
          column, row = ((idx+1) % 7) == 0 ? [column - width, 6] : [column, row + width]
          cell
        end
      end
    end

    def populate_subviews
      self.addSubview(calendarTitle)
      self.addSubview(next_button)
      self.addSubview(prev_button)
      week_days.each { |day| self.addSubview(day) }
      calendar_days.each { |bts| self.addSubview(bts) }
    end

    private
    def common_init
      @backgroundColor = NSColor.whiteColor
      next_button
      prev_button
      calendarTitle
      week_days
      calendar_days
    end

    def create_button(frame, image_named=nil)
      NSButton.alloc.initWithFrame(frame).tap do |b|
        if image_named
          b.imagePosition = NSImageOnly # 1
          b.imageScaling = NSImageScaleProportionallyUpOrDown
          b.bordered = false
          b.image = NSImage.imageNamed(image_named)
        end
        yield b if block_given?
        b.bezelStyle = NSRoundedBezelStyle
        b.buttonType = NSMomentaryPushInButton
        b.enabled = true
      end
    end

    def create_text_field(frame=NSRect.new) 
      NSTextField.with(frame:frame).tap do |tf|
        tf.backgroundColor = NSColor.controlColor
        tf.textColor = NSColor.labelColor
        tf.editable = false
        tf.bordered = false
        tf.bezeled = false
        tf.enabled = false
        tf.stringValue = ""
        tf.alignment = NSCenterTextAlignment
        tf.font = NSFont.fontWithName('.HelveticaNeueDeskInterface-Thin', size:14.0)
        # NSFont.fontWithName('HelveticaNeue-Thin', size:13.0)
        yield tf if block_given?
      end
    end
  end
end
