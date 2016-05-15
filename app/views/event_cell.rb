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
        NSLayoutConstraint.activateConstraints([
          textField.widthAnchor.constraintEqualToAnchor(self.widthAnchor, constant:-20),
          textField.heightAnchor.constraintEqualToAnchor(self.heightAnchor, constant:-10),
          textField.centerXAnchor.constraintEqualToAnchor(self.centerXAnchor),
          textField.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor),
        ])
        @__layout__ = true
      end
    end

  end
end
