module Carendar
  class EventsFetcher
    
    def events_of_the_day(date)
      validate_date?(date).then { allowed? }
                          .then do
                            start_date = beginning_of_day(date)
                            end_date = end_of_day(start_date)
                            events_from(start_date, to:end_date)
                          end

    end
    
    def events_of_the_month(date)
      validate_date?(date).then { allowed? }
                          .then do
                            start_date = beginning_of_mounth(date)
                            end_date = end_of_mounth(date)
                            events_from(start_date, to:end_date)
                          end
    end
    
    private
    
    def events_from(start_date, to:end_date)
      predicate = storage.predicateForEventsWithStartDate( start_date,
                                        endDate: end_date,
                                      calendars: nil)
      storage.eventsMatchingPredicate(predicate)
    end
    
    def storage
      @__storage__ ||= EKEventStore.new
    end
    
    def allowed?
      promise = Promise.new
      completion = Proc.new do |flag, error|
        flag ? promise.fulfill(flag) : promise.reject(error)
      end
      type = EKEntityTypeEvent # | EKEntityTypeReminder
      storage.requestAccessToEntityType(type, completion:completion)
      promise
    end
    
    def beginning_of_day(date)
      calendar = CalendarController.calendar
      opts = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
      components = calendar.components(opts, fromDate:date)
      calendar.dateFromComponents(components)
    end
    
    def end_of_day(date)
      calendar = CalendarController.calendar
      components = NSDateComponents.new
      components.day = 1
      date = calendar.dateByAddingComponents(components, toDate:date, options:0)
      date.dateByAddingTimeInterval(-1)
    end
    
    def beginning_of_month(date)
      calendar = CalendarController.calendar
      opts = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
      components = calendar.components(opts, fromDate:date)
      components.day = 1
      beginning_of_day calendar.dateFromComponents(components)
    end
    
    def end_of_month(date)
      calendar = CalendarController.calendar
      opts = NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit
      comps = calendar.components(opts, fromDate:date)
      # set last of month
      comps.month = comps.month + 1
      comps.day = 0      
      end_of_day calendar.dateFromComponents(comps)
    end
    
    def validate_date?(date)
      promise = Promise.new
      date.nil? ? promise.reject : promise.fulfill
      promise
    end
    
  end
end
