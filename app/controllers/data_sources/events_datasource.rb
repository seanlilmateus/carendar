module Carendar
  class EventsDataSource

    def initialize
      @events = NSArray.array
    end
    attr_reader :events

    # Delegate
    def tableView(tbv, viewForTableColumn:column, row:row)
      event = @events[row]
      if event.is_a?(String)
        identifier = "Group Title"
        cell = tbv.makeViewWithIdentifier(identifier, owner:self) 
        cell ||= TableHeaderCell.with(frame:[[0, 0], [278.0, 25]])
        cell.identifier, cell.stringValue = identifier, event
        if @events[row+1] && @events[row+1].is_a?(EKObject)
          cell.textColor = @events[row+1].calendar.color
        end 
        cell
      elsif event
        cell = tbv.makeViewWithIdentifier(column.identifier, owner:self) 
        cell ||= EventCell.with(frame:[[0, 0], [278.0, 35]]).tap do |c|
          c.identifier = column.identifier
        end
        # Ruby's own if let version :-P
        if title = event.title
          cell.textField.stringValue = title 
          cell.textField.textColor = NSColor.blackColor
        end
        cell
      end
    end

    # DataSource
    def numberOfRowsInTableView(tbv)
      @events.count
    end
    
    def events=(items)
      groups = items.group_by { |event| event.calendar.title }
                    .to_a.flatten
      @events = NSArray.arrayWithArray(groups)
    end

    def tableView(tbv, heightOfRow:row)
      @events[row].is_a?(String) ? 25.0 : 35.0
    end

    def tableView(tableView, isGroupRow:row)
      @events[row].is_a?(String)
    end

  end
end
