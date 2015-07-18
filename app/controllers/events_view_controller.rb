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
      self.tableView.target = @data_source
      self.tableView.doubleAction = 'double_clicked:'
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
