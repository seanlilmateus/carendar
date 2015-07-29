module Carendar
  class EventCell < NSTableCellView
    
    def textField
      @__textField__ ||= NSTextField.alloc.init.tap do |sf|
        sf.translatesAutoresizingMaskIntoConstraints = false
        sf.selectable = false
        sf.editable = false
        sf.enabled = true
        sf.bordered = false
        sf.cell.usesSingleLineMode = true
        sf.cell.lineBreakMode = NSLineBreakByTruncatingTail
        sf.backgroundColor = NSColor.clearColor
        sf.extend(Layout::View)
      end
    end

    def viewWillMoveToSuperview view
      super
      self.addSubview(textField)
      layout_subviews
    end

    private
    def layout_subviews
      unless @__layout__
        self.extend(Layout::View)
        self.addConstraints([
          textField.width == self.width - 20,
          textField.height == self.height - 10,
          textField.centerX == self.centerX,
          textField.centerY(1000) == self.centerY,
        ])
        @__layout__ = true
      end
    end
  end
end
