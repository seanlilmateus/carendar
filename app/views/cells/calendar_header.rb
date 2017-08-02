module Carendar
  class CalendarHeader < NSView
    IDENTIFIER = "CalendarHeader"


    def self.requiresConstraintBasedLayout
      true
    end


    def initWithFrame(frame)
      super.tap do |instance|
        instance.addSubview stacker
        update_week_days
        @constrs = create_constraints
      end
    end


    def header_stacker
      @header_stacker ||= NSStackView.stackViewWithViews([prev_button, titleLabel, next_button]).tap do |st|
        st.orientation = NSUserInterfaceLayoutOrientationHorizontal
        st.huggingPriorityForOrientation NSLayoutConstraintOrientationHorizontal
        st.setHuggingPriority(1.0, forOrientation: NSLayoutConstraintOrientationHorizontal)
        st.spacing = 10.0
      end
    end


    def stacker
      @stacker ||= NSStackView.stackViewWithViews([header_stacker, week_days]).tap do |st|
        st.orientation = NSUserInterfaceLayoutOrientationVertical
        st.translatesAutoresizingMaskIntoConstraints = false
        st.distribution = NSStackViewDistributionGravityAreas
      end
    end


    def titleLabel
      @title_label ||= Label.create("January 2016").tap do |l|
        l.alignment = NSCenterTextAlignment
        l.font = NSFont.fontWithName('.HelveticaNeueDeskInterface-Regular', size:17.0)
      end
    end


    def week_days
      @days ||= begin
        days = Array.new(7) { create_label }
        NSStackView.stackViewWithViews(days).tap do |st|
          st.orientation = NSUserInterfaceLayoutOrientationHorizontal
          st.translatesAutoresizingMaskIntoConstraints = false
          st.spacing = 0# NSEdgeInsets.new(0.0, 10.0, 0.0, 0.0)
          st.distribution = NSStackViewDistributionFillEqually
        end
      end
    end


    def update_week_days
      cal  = NSCalendar.autoupdatingCurrentCalendar
      fst  = cal.firstWeekday - 1
      fst  = cal.firstWeekday - 1
      days_with_indexes = cal.shortWeekdaySymbols
                             .each_with_index.to_a.rotate(fst)
      week_days.views.zip(days_with_indexes) do |label, (title, index)|
        label.font = NSFont.fontWithName('.HelveticaNeueDeskInterface-Regular', size:15.5)
        if [0, 6, 7, 13].include?(index)
          label.textColor = NSColor.redColor
        end
        label.alignment = NSTextAlignmentCenter
        label.text = title.upcase[0..1]
      end    
    end


    def next_button
      @next_btn ||= create_button('NSRightFacingTriangleTemplate') do |btn|
        btn.identifier = 'Next Month'
      end
    end


    def prev_button
      @prev_btn ||= create_button('NSLeftFacingTriangleTemplate') do |btn|
        btn.identifier = 'Previous Month'
      end
    end


    def viewDidMoveToSuperview
      super
      unless @constrs.all? { |c| c.active? }
        NSLayoutConstraint.activateConstraints(@constrs)
      end
    end


    def create_constraints
      [
        next_button.heightAnchor.constraintEqualToConstant(18),
        prev_button.heightAnchor.constraintEqualToConstant(18),
        next_button.widthAnchor.constraintEqualToConstant(18),
        prev_button.widthAnchor.constraintEqualToConstant(18),
        prev_button.leftAnchor
                   .constraintEqualToAnchor(self.leftAnchor, constant: 10),
        next_button.rightAnchor
                   .constraintEqualToAnchor(self.rightAnchor, constant: -10),
        week_days.widthAnchor.constraintEqualToAnchor(self.widthAnchor),
        stacker.centerXAnchor
               .constraintEqualToAnchor(self.centerXAnchor),
        stacker.centerYAnchor
               .constraintEqualToAnchor(self.centerYAnchor, constant: 10),
        stacker.widthAnchor.constraintEqualToAnchor(self.widthAnchor),
        stacker.heightAnchor.constraintEqualToAnchor(self.heightAnchor),
      ]
    end


    private
    def create_button(image_named=nil)
      NSButton.new.tap do |b|
        b.cell.backgroundStyle = NSBackgroundStyleLight
        b.cell.controlTint = NSBlueControlTint
        b.bezelStyle = NSRegularSquareBezelStyle
        b.buttonType = NSMomentaryLightButton
        b.alignment = NSTextAlignmentCenter
        b.enabled = true
        if image_named
          b.imagePosition = NSImageOnly # 1
          b.imageScaling = NSImageScaleProportionallyUpOrDown
          b.bordered = false
          b.image = NSImage.imageNamed(image_named)
        end
        yield b if block_given?
      end
    end


    def create_label(title="0")
      label = NSTextField.labelWithString(title)
      label.alignment = NSTextAlignmentCenter
      label.font = NSFont.monospacedDigitSystemFontOfSize(12, weight: NSFontWeightSemibold)
      label
    end
  end
end