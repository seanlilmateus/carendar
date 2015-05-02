module Carendar
  class EventsFetcher

    def initialize
      @storage = EKEventStore.new
    end

    def events_of_the_day(date)
      allowed?.then { validate_date?(date) }
              .then { DateOffset.new(date, DateOffset::DAY, 1) }
              .then { |offset| events_from(offset.start_date, to:offset.end_date) }
    end

    def events_of_the_month(date)
      allowed?.then { validate_date?(date) }
              .then { DateOffset.new(date, DateOffset::MONTH, 1) }
              .then { |offset| events_from(offset.start_date, to:offset.end_date) }
    end

    private
    attr_reader :storage

    def events_from(start_date, to:end_date)
      predicate = storage.predicateForEventsWithStartDate( start_date,
                                        endDate: end_date,
                                      calendars: nil)
      storage.eventsMatchingPredicate(predicate)
    end

    def validate_date?(date)
      promise = Promise.new
      if date.is_a?(NSDate)
        promise.fulfill(date)
      else
        info = { NSLocalizedDescriptionKey => "Invalid Date" }
        error = NSError.errorWithDomain("Carendar", code:-5, userInfo:info)
        promise.reject(error)
      end
      promise
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
  end
end
