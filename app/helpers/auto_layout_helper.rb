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
    def left(priority=1000)
      operand(NSLayoutAttributeLeft, priority)
    end

    def right(priority=1000)
      operand(NSLayoutAttributeRight, priority)
    end

    def top(priority=1000)
      operand(NSLayoutAttributeTop, priority)
    end

    def bottom(priority=1000)
      operand(NSLayoutAttributeBottom, priority)
    end

    def leading(priority=1000)
      operand(NSLayoutAttributeLeading, priority)
    end

    def trailing(priority=1000)
      operand(NSLayoutAttributeTrailing, priority)
    end
    
    def width(priority=1000)
      operand(NSLayoutAttributeWidth, priority)
    end
    
    def height(priority=1000)
      operand(NSLayoutAttributeHeight, priority)
    end

    def centerX(priority=1000)
      operand(NSLayoutAttributeCenterX, priority)
    end

    def centerY(priority=1000)
      operand(NSLayoutAttributeCenterY, priority)
    end

    def baseline(priority=1000)
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
