module Carendar
  class ContentViewModel

    def initialize(controller)
      @controller = controller
    end


    def content_loaded
      controller.today_button.enabled = current_month?
      events_for_the_month(calendar_controller.date)
    end


    def calendar_controller
      controller.calendar_view_controller
    end


    def didChangeMonth(date)
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
      events_for_the_day(date)
      today_button_selected?
    end


    # Buttons Actions
    def select_date(sender) # previous go to date
      date = NSDate.date
      calendar_controller.select_date(date)
      didSelectDate(date)
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
      flag = calendar.subviews
                     .none? { |sbv| sbv.is_a?(CalendarCell) && sbv.today? && sbv.selected? }
      controller.today_button.enabled = flag
    end


    def deselect_rows(sender=nil)
      collectionView = controller.events_view_controller.collectionView
      collectionView.deselectAll(sender)
    end


    def update_empty_view(events=[], selected_date=calendar_controller.data_source.title)
      subject = Promise.new
      Dispatch::Queue.main.async do
        clv = controller.events_view_controller.collectionView
        clv.backgroundView.subviews.first.stringValue = selected_date
        clv.backgroundView.alphaValue = events.empty? ? 1.0 : 0.0
        subject.fulfill(events)
      end
      subject
    end


    def events_for_the_month(date)
      events_controller = controller.events_view_controller
      controller.events_fetcher
                .events_of_the_month(date)
                .then { |items| update_empty_view(items) }
                .then { |items| events_controller.data_source.events = items }
                .on_queue(Dispatch::Queue.main)
                .then { events_controller.collectionView.reloadData }
    end


    def events_for_the_day(date)
      events_controller = controller.events_view_controller
      controller.events_fetcher
                .events_of_the_day(date)
                .then { |items| update_empty_view(items, date_formatter.stringFromDate(date)) }
                .then { |items| events_controller.data_source.events = items }
                .on_queue(Dispatch::Queue.main)
                .then { events_controller.collectionView.reloadData }
    end

  end
end