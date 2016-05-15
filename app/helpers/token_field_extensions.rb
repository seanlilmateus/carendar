class NSTokenField
  def update_display
    field_editor = self.window.fieldEditor(true, forObject:self)
    selection_range = field_editor.selectedRange
    object_value = self.objectValue
    self.setObjectValue(nil)
    self.setObjectValue(object_value)
    field_editor.setSelectedRange(selection_range)
  end
end
