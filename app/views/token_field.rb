class TokenField < NSTokenField
  def update_display
    field_editor = self.window.fieldEditor(true, forObject:self)
    selection_range = field_editor.selectedRange
    object_value = self.objectValue
    self.setObjectValue(nil)
    self.setObjectValue(object_value)
    field_editor.setSelectedRange(selection_range) if selection_range
  end


  def performKeyEquivalent(event)
    dev_mask = NSDeviceIndependentModifierFlagsMask
    modifier = event.modifierFlags

    if (modifier & dev_mask) == NSCommandKeyMask
      action = case event.charactersIgnoringModifiers
               when "x" then "cut:"
               when "c" then "copy:"
               when "v" then "paste:"
               when "z" then "undo:"
               when "a" then "selectAll:"
               end
      return NSApp.sendAction(action, to:nil, from:self)
    elsif (modifier & dev_mask) == (NSCommandKeyMask | NSShiftKeyMask)
      if event.charactersIgnoringModifiers == "Z"
        return NSApp.sendAction("redo:", to:nil, from:self)
      end
    end

    super
  end
  
end
