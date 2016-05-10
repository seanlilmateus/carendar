module Carendar
  class TokenField < NSTokenField
    def update_display!
      field_editor = self.window.fieldEditor(true, forObject:self)
      selection_range = field_editor.selectedRange
      old_value = self.objectValue
      self.setObjectValue(nil)
      self.setObjectValue(old_value)
      field_editor.setSelectedRange(selection_range)
    end
    alias_method :format, :objectValue
  end
end
