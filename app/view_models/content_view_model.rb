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
      today_button_selected?
    end


    def didSelectDate(date)
      if date.nil?
        didChangeMonth(calendar_controller.date)
        return
      end
      update_empty_view date_formatter.stringFromDate(date)
      events_for_the_day(date)
      today_button_selected?
    end


    # Buttons Actions
    def select_date(sender) # previous go to date
      date = NSDate.date
      calendar_controller.select_date(date)
      events_for_the_day(date)
      deselect_rows(sender)
      sender.enabled = false
    end


    private
    attr_reader :controller

    def current_month?
      calendar_controller.collectionView
                         .subviews
                         .select { |sbv| sbv.is_a?(CalendarCell) && sbv.today? }
    end


    def date_formatter
      # default short date format from somewhere???
      @__date_formatter__ ||= NSDateFormatter.new.tap do |df|
        df.timeStyle = NSDateFormatterNoStyle
        df.dateStyle = NSDateFormatterFullStyle
        df.locale = NSLocale.autoupdatingCurrentLocale
      end
    end


    def today_button_selected?
      calendar = calendar_controller.collectionView
      flag = calendar.subviews.none? { |sbv| sbv.is_a?(CalendarCell) && sbv.today? && sbv.selected? }
      controller.today_button.enabled = flag
    end


    def deselect_rows(sender=nil)
      table_view = controller.events_view_controller.tableView
      table_view.deselectAll(sender)
    end


    def update_empty_view(date_string=calendar_controller.data_source.title)
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