module Carendar
  class DetailsItemView < NSView

    def initWithFrame(frame)
      super.tap do |instance|
        @highlightState = NSCollectionViewItemHighlightNone
        instance.addSubview(stack_view)
        instance.addSubview(sideView)
        weights = [NSFontWeightRegular, NSFontWeightSemibold, NSFontWeightLight ]
        stack_view.views.zip(weights) do |label, weight|
          label.font = NSFont.systemFontOfSize(12, weight:weight)
        end
      end
    end


    def sideView
      @side ||= NSView.new.tap do |instance|
        instance.wantsLayer = true
      end
    end


    def textField
      stack_view.views.last.stringValue = "14:00 - 15:00" 
      stack_view.views[1]
    end


    def descriptionLabel
      stack_view.views[0]
    end
  
    def timeLabel
      stack_view.views.last
    end


    def toolTip
      "#{stack_view.views[1].stringValue || 'Nothing to see here'}"
    end


    def stack_view
      @stack_view ||= begin
        labels = Array.new(3) do |text| 
          label = Label.create("Label #{text}")
          label.cell.lineBreakMode = NSLineBreakByTruncatingMiddle
          label.alignment = NSTextAlignmentLeft
          label
        end
        NSStackView.stackViewWithViews(labels).tap do |stack|
          stack.alignment = NSLayoutAttributeLeading
          stack.orientation = NSLayoutConstraintOrientationVertical
          stack.setHuggingPriority(NSLayoutPriorityRequired, forOrientation:NSLayoutConstraintOrientationVertical)
          stack.setHuggingPriority(NSLayoutPriorityRequired, forOrientation:NSLayoutConstraintOrientationHorizontal)
          priority = NSStackViewVisibilityPriorityMustHold
          stack.views.each do |view| 
            stack.setVisibilityPriority(priority, forView:view)
            stack.setCustomSpacing(2, afterView:view)
          end
          stack.edgeInsets = NSEdgeInsets.new(2.0, 5.0, 2.0, 5.0)
          stack.distribution = NSStackViewDistributionFillEqually
        end
      end
    end


    def viewWillMoveToSuperview(v)
      stack_view.translatesAutoresizingMaskIntoConstraints = false
      sideView.translatesAutoresizingMaskIntoConstraints = false
      [ 
        sideView.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor),
        sideView.heightAnchor.constraintEqualToAnchor(self.heightAnchor, multiplier:1.0),
        sideView.leftAnchor.constraintEqualToAnchor(self.leftAnchor),
        sideView.widthAnchor.constraintEqualToConstant(5.0),
        stack_view.centerXAnchor.constraintEqualToAnchor(self.centerXAnchor),
        stack_view.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor),
        stack_view.widthAnchor
          .constraintEqualToAnchor(self.widthAnchor, multiplier:0.95),
      ].map { |c|  c.active = true }
    end


    def setHighlightState(state)
      unless @highlightState == state
        @highlightState = state
        self.setNeedsDisplay(true)
      end
    end
    alias_method :highlightState=, :setHighlightState
    attr_reader :highlightState


    def isSelected
      @selected
    end
    alias_method :selected?, :isSelected


    def setSelected(flag)
      unless @selected == flag
        @selected = flag
        self.setNeedsDisplay(true)
      end
    end
    alias_method :selected=, :setSelected


    def backgroundColor=(color)
      @main_color = color
      sideView.backgroundColor = color
      stack_view.views.each do |label|
        label.textColor = color #NSColor.whiteColor
      end #unless Colorify.light?(color)
      super(color.colorWithAlphaComponent(0.25))
    end


    def updateLayer
      super
      text_color = Colorify.light?(@main_color) ? NSColor.blackColor : NSColor.whiteColor
      color = if self.selected?
        stack_view.views.each { |label| label.textColor = text_color }
        @main_color
      else
        stack_view.views.each { |label| label.textColor = @main_color }
        @main_color&.colorWithAlphaComponent(0.25)
      end
    
      self.layer.backgroundColor = (color || NSColor.clearColor).CGColor
    end
  
    def wantsUpdateLayer
      true
    end
  
  end

end