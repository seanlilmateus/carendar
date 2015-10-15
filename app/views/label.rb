module Carendar
  class Label < NSTextField
    def self.create(text, frame=NSRect.new)
      alloc.initWithFrame(frame).tap do |lbl|
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.stringValue = text
        lbl.enabled = true
        lbl.editable = false
        lbl.selectable = true
        lbl.bordered = false
        lbl.bezeled = false
        lbl.lineBreakMode = NSLineBreakByWordWrapping
        lbl.usesSingleLineMode = true
        lbl.backgroundColor = NSColor.clearColor
        yield(lbl) if block_given?
        lbl.extend(Layout::View)
      end
    end
  end
end