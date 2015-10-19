module Carendar
  class ContentViewModel
    
    def initialize(controller)
      @controller = controller
    end
    
    def content_loaded
      controller.today_button.enabled = current_month?
      events_for_the_month(calendar_controller.date)
      update_empty_view
    end
    
    def calendar_controller
      controller.calendar_view_controller
    end
    
    def didChangeMonth(date)
      update_empty_view
      deselect_rows
      controller.today_button.enabled = current_month?
      events_for_the_month(date)
      controller.today_button.enabled = current_month?
    end
    
    def didSelectDate(date)
      if date.nil?
        didChangeMonth(calendar_controller.date)
        return
      end
      update_empty_view date_formatter.stringFromDate(date)
      events_for_the_day(date)
      controller.today_button.enabled = current_month?
    end
    
    # Buttons Actions
    def select_date(sender) # previous go to date
      calendar_controller.date = NSDate.date
      #events_for_the_month(controller.calendar_view_controller.date)
      deselect_rows(sender)
      select_today
    end
    
    private
    attr_reader :controller
    def current_month?
      calendar_controller.view
                         .subviews
                         .select { |sbv| sbv.is_a?(CalendarCell) && sbv.today? }
                         .none?(&:selected)
    end
    
    def date_formatter
      # default short date format from somewhere???
      @__date_formatter__ ||= NSDateFormatter.new.tap do |df|
        df.timeStyle = NSDateFormatterNoStyle
        df.dateStyle = NSDateFormatterFullStyle
        df.locale = NSLocale.autoupdatingCurrentLocale
      end
    end
    
    def select_today
      today = NSDate.date
      calendar = controller.calendar_view_controller.view
      calendar.subviews
              .select { |sbv| sbv.is_a?(CalendarCell) && sbv.title ==  "#{today.day}" }
              .each   { |sbv| sbv.selected = true }
      events_for_the_day(today)
      controller.today_button.enabled = false
    end
    
    def deselect_rows(sender=nil)
      table_view = controller.events_view_controller.tableView
      calendar = controller.calendar_view_controller.view
      calendar.subviews
              .select { |sbv| sbv.is_a?(CalendarCell) }
              .each   { |sbv| sbv.selected = false }
      table_view.deselectAll(sender)
    end
    
    def update_empty_view(date_string=calendar_controller.view.calendarTitle.stringValue)
      table_view = controller.events_view_controller.tableView
      table_view.date_label.stringValue = date_string
    end
    
    def events_for_the_month(date)
      events_controller = controller.events_view_controller
      controller.events_fetcher
                .events_of_the_month(date)
                .on_queue(Dispatch::Queue.main)
                .then { |items| events_controller.data_source.events = items }
                .then { events_controller.tableView.reloadData }
    end
    
    def events_for_the_day(date)
      events_controller = controller.events_view_controller
      controller.events_fetcher
                .events_of_the_day(date)
                .on_queue(Dispatch::Queue.main)
                .then { |items| events_controller.data_source.events = items }
                .then { events_controller.tableView.reloadData }
    end
    
  end
end