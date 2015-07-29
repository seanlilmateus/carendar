module Carendar
  class EventsViewController < BaseViewController

    def init
      super.tap { @data_source = EventsDataSource.new }
    end
    attr_reader :data_source
    
    def loadView
      self.view = table_container
    end
    
    def viewDidLoad
      super
      self.tableView.delegate = @data_source
      self.tableView.dataSource = @data_source
      self.tableView.target = self
      self.tableView.doubleAction = 'double_clicked:'
    end
    
    def show_event(event)
      calendar_app = SBApplication.applicationWithBundleIdentifier('com.apple.ical')
      # *cal = calendar_app.calendars.find { |c| c.name == event.calendar.title }
      #found_event = cal.events.find do |e| 
      #  event.startDate == e.startDate && e.properties[:uid] == event.eventIdentifier
      #end if cal
      #found_event.show if found_event
      calendar_app.activate
      calendar_app.viewCalendarAt(event.startDate)
    end
    
    def double_clicked sender
      item = @data_source.events[sender.clickedRow]
      if item.is_a?(EKEvent)
        show_event(item)
      else
        return false
      end
    end
    
    
    def tableView
      @__tableView__ ||= EventsTableView.new NSRect.new([0, 0], [280.0, 200])
    end
    
    private
    def table_container
      @__table_container__ ||= begin
        rect = NSRect.new([0, 0], [280.0, 250.0])
        NSScrollView.alloc.initWithFrame(rect).tap do |scv|
          scv.backgroundColor = NSColor.clearColor
          scv.contentView.backgroundColor = NSColor.clearColor
          scv.documentView = tableView
          scv.hasHorizontalScroller = false
          scv.horizontalLineScroll = 0.0
          scv.drawsBackground = true
        end
      end
    end
    
  end
end
