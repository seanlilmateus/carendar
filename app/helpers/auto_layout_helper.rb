module Layout
  class Item
    attr_reader :view, :attribute, :multiplier, :constant
    def initialize(view, attribute, multiplier=1.0, constant=0.0)
      @view, @multiplier = view, multiplier
      @attribute, @constant = attribute, constant
    end
    
    def == (other)
      if other.is_a?(Numeric)
        relate_to_constant(other, NSLayoutRelationEqual)
      elsif other.is_a?(Item)
        relate_to(other, NSLayoutRelationEqual)
      end
    end
    
    def >= other
      if other.is_a?(Numeric)
        greater_than_or_equal_to_constant(other)
      else
        greater_than_or_equal_to(other)
      end
    end
    
    def <= other
      if other.is_a?(Numeric)
        less_than_or_equal_to_constant(other)
      else
        less_than_or_equal_to(other)
      end
    end
    
    def + rhs
      Item.new(self.view, self.attribute, self.multiplier, self.constant + rhs)
    end
    
    def - rhs
      Item.new(self.view, self.attribute, self.multiplier, self.constant - rhs)
    end
    
    def * rhs
      Item.new(self.view, self.attribute, self.multiplier * rhs, self.constant)
    end
    
    def / rhs
      Item.new(self.view, self.attribute, self.multiplier / rhs, self.constant)
    end
    
    private
    def relate_to(rhs, relation)
      NSLayoutConstraint.constraintWithItem(self.view,
                                  attribute: attribute,
                                  relatedBy: relation,
                                     toItem: rhs.view, 
                                  attribute: rhs.attribute, 
                                 multiplier: rhs.multiplier,
                                   constant: rhs.constant).tap { |cons| cons.priority = @priority }
    end
    
    def relate_to_constant(rhs, relation)
      NSLayoutConstraint.constraintWithItem(self.view,
                                  attribute: self.attribute,
                                  relatedBy: relation,
                                     toItem: nil,
                                  attribute: NSLayoutAttributeNotAnAttribute,
                                 multiplier: 1.0,
                                   constant: rhs).tap { |cons| cons.priority = @priority }
    end
    
    def greater_than_or_equal_to_constant(rhs)
      relate_to_constant(rhs, NSLayoutRelationGreaterThanOrEqual)
    end
    
    def greater_than_or_equal_to(other)
      relate_to(other, NSLayoutRelationGreaterThanOrEqual)
    end
    
    def less_than_or_equal_to_constant(rhs)
      relate_to_constant(rhs, NSLayoutRelationLessThanOrEqual)
    end
    
    def less_than_or_equal_to(other)
      relate_to(other, NSLayoutRelationLessThanOrEqual)
    end
  end
end

module Layout
  module View
    REQUIRED = NSLayoutPriorityRequired  
    def left(priority=REQUIRED)
      operand(NSLayoutAttributeLeft, priority)
    end
    
    def right(priority=REQUIRED)
      operand(NSLayoutAttributeRight, priority)
    end
    
    def top(priority=REQUIRED)
      operand(NSLayoutAttributeTop, priority)
    end
    
    def bottom(priority=REQUIRED)
      operand(NSLayoutAttributeBottom, priority)
    end
    
    def leading(priority=REQUIRED)
      operand(NSLayoutAttributeLeading, priority)
    end
    
    def trailing(priority=REQUIRED)
      operand(NSLayoutAttributeTrailing, priority)
    end
    
    def width(priority=REQUIRED)
      operand(NSLayoutAttributeWidth, priority)
    end
    
    def height(priority=REQUIRED)
      operand(NSLayoutAttributeHeight, priority)
    end
    
    def centerX(priority=REQUIRED)
      operand(NSLayoutAttributeCenterX, priority)
    end
    
    def centerY(priority=REQUIRED)
      operand(NSLayoutAttributeCenterY, priority)
    end
    
    def baseline(priority=REQUIRED)
      operand(NSLayoutAttributeBaseline, priority)
    end
    
    private
    def operand(attribute, priority)
      item = Item.new(self, attribute)
      item.instance_variable_set(:@priority, priority)
      item
    end
  end
end
