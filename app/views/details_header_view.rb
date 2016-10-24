module Carendar
  class DetailsHeaderView < NSVisualEffectView # HeaderView
    IDENTIFIER = NSString.stringWithString(self.to_s)

    def initWithFrame(frame)
      super.tap do |instance|
        instance.material = NSVisualEffectMaterialLight
        instance.blendingMode = NSVisualEffectBlendingModeWithinWindow
        instance.state = NSVisualEffectStateFollowsWindowActiveState
        instance.allowsVibrancy = true
      end
    end


    SEP_COLOR = NSColor.colorWithRed(0.682, green:0.676, blue:0.73, alpha:0.5)
    def separators
      @separators ||= Array.new(2) do
        CellSeparator.new.tap { |s| s.backgroundColor = SEP_COLOR }
      end
    end


    def applyLayoutAttributes(attributes)
      super
    end


    def prepareForReuse
      super
      textField.stringValue = ""
    end


    def stack
      @stack ||= NSStackView.stackViewWithViews([textField, detailsField]).tap do |s|
        s.orientation = NSUserInterfaceLayoutOrientationVertical
        s.spacing = 1.0
        s.alignment = NSLayoutAttributeLeft
      end
    end

    def viewWillMoveToSuperview(v)
      super
      self.addSubview(stack)
      separators.each do |sep|
        self.addSubview(sep)
        sep.translatesAutoresizingMaskIntoConstraints = false
      end
      stack.translatesAutoresizingMaskIntoConstraints = false
      stack.centerXAnchor.constraintEqualToAnchor(self.centerXAnchor)
               .active = true
      stack.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor)
               .active = true
      stack.widthAnchor.constraintEqualToAnchor(self.widthAnchor, constant:-24)
               .active = true
      # -------------------------------------------------
      separators.each do |sep|
        sep.centerXAnchor.constraintEqualToAnchor(self.centerXAnchor)
           .active = true
        sep.widthAnchor.constraintEqualToAnchor(self.widthAnchor)
           .active = true
        sep.heightAnchor.constraintEqualToConstant(1).active = true
      end
      separators[1].topAnchor.constraintEqualToAnchor(self.topAnchor)
                    .active = true
      separators[0].bottomAnchor.constraintEqualToAnchor(self.bottomAnchor)
                   .active = true    
    end


    def textField
      @label ||= Label.new.tap do |tf|
        tf.textColor = NSColor.colorWithCalibratedWhite(0.326, alpha:1.0)
        tf.font = NSFont.titleBarFontOfSize(14)
      end
    end
  
    def detailsField
      @detail ||= Label.new.tap do |tf|
        tf.textColor = NSColor.colorWithCalibratedWhite(0.326, alpha:1.0)
        tf.font = NSFont.titleBarFontOfSize(12)
      end
    end
  end
  
end