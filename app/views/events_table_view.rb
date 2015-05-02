module Carendar
  class EventsTableView < NSTableView

    def self.new(frame)
      alloc.initWithFrame(frame).tap do |tbv|
        tbv.backgroundColor = NSColor.clearColor
        tbv.opaque = false
        column = NSTableColumn.with(identifier: 'Events')
        tbv.addTableColumn column
        column.width = frame.size.width - 3.0
        column.headerCell.stringValue = localized_string('Events', 'Events')
        column.headerCell.alignment = NSCenterTextAlignment
        column.resizingMask = NSTableColumnAutoresizingMask
        tbv.columnAutoresizingStyle = NSTableViewFirstColumnOnlyAutoresizingStyle
      end
    end

    def has_rows_to_display?
      self.numberOfRows > 0
    end

    def reloadData
      super
      update_empty_view
    end

    def layoutSubviews
      super
      update_empty_view
    end

    def empty_view
      @empty_view || default_empty_view
    end

    def empty_view=(nv)
      if self.empty_view && self.empty_view.superview
        self.empty_view.removeFromSuperview
      end
      @empty_view = nv
      update_empty_view
    end

    def date_label
      @__date_label__ ||= create_label do |sf|
        sf.stringValue = "Date Come here"
        sf.font = NSFont.systemFontOfSize(18)
        sf.textColor = NSColor.disabledTextColor
      end
    end

    private
    
    def update_empty_view
      return unless self.empty_view
      if self.empty_view.superview != self
        self.addSubview(self.empty_view)
      end
      
      # setup empty view frame
      frame = self.bounds
      frame.origin = NSPoint.new
      height = frame.size.height - self.headerView.frame.size.height
      frame = NSRect.new(frame.origin, [frame.size.width, height])
      self.empty_view.frame = frame
      mask = NSViewWidthSizable | NSViewHeightSizable
      self.empty_view.autoresizingMask = mask
      
      # check available data
      empty_view_should_be_shown = (self.has_rows_to_display? == false)
      # check bypassing
      response = self.dataSource.respond_to?('tableViewShouldBypassEmptyView:')
      if empty_view_should_be_shown && response
        by_passed = self.dataSource.tableViewShouldBypassEmptyView(self)
        empty_view_should_be_shown = empty_view_should_be_shown && !by_passed
      end
      self.empty_view.hidden = !empty_view_should_be_shown
    end

    def default_empty_view
      @__default_empty_view__ ||= NSView.alloc.initWithFrame(self.frame).tap do |v|
        v.addSubview empty_label
        v.addSubview date_label
        v.extend(Layout::View)
        v.addConstraints([
          date_label.centerX == v.centerX,
          date_label.centerY(1000) == v.centerY - 35,
          empty_label.centerX == v.centerX,
          empty_label.top == date_label.bottom + 5,
        ])
      end
    end

    def empty_label
      @__empty_label__ ||= create_label do |sf|        
        attributes = { 
          NSForegroundColorAttributeName => NSColor.redColor,
          NSForegroundColorAttributeName => NSColor.redColor,
          NSFontAttributeName => NSFont.systemFontOfSize(20),
        }
        msg = localized_string('No Events', 'No Events')
        attr_string = NSAttributedString.alloc.initWithString(msg, attributes:attributes)
        sf.attributedStringValue = attr_string
      end
    end

    def create_label
      NSTextField.alloc.init.tap do |sf|
        sf.translatesAutoresizingMaskIntoConstraints = false
        yield(sf) if block_given?
        sf.selectable = false
        sf.bordered = false
        sf.editable = false
        sf.enabled = true
        sf.backgroundColor = NSColor.clearColor
        sf.extend(Layout::View)
      end
    end
  end
  
end
