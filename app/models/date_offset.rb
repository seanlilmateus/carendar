module Carendar
  # Date Time Offset Units
  # it can be day or months
  class DateOffset
    MONTH, DAY = :month, :day
    
    def initialize(date, unit=DAY, offset=1)
      if unit == DAY
        @start_date = beginning_of_day(date)
        @end_date = end_of_day(start_date, offset)
      elsif MONTH
        @start_date = beginning_of_month(date)
        @end_date = end_of_month(date, offset)
      end
    end
        
    attr_reader :start_date, :end_date

    private
    
    def beginning_of_day(date)
      calendar = CalendarController.calendar
      opts = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
      components = calendar.components(opts, fromDate:date)
      # date.dateForStartOfDayInTimeZone(NSTimeZone.systemTimeZone)
      calendar.dateFromComponents(components)
    end
    
    def end_of_day(date, offset=1)
      calendar = CalendarController.calendar
      components = NSDateComponents.new
      components.day = offset
      date = calendar.dateByAddingComponents(components, toDate:date, options:0)
      # date.dateForEndOfDayInTimeZone(NSTimeZone.systemTimeZone)
      date.dateByAddingTimeInterval(-1)
    end
    
    def beginning_of_month(date)
      calendar = CalendarController.calendar
      opts = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
      components = calendar.components(opts, fromDate:date)
      components.day = 1
      beginning_of_day calendar.dateFromComponents(components)
    end
    
    def end_of_month(date, offset=1)
      calendar = CalendarController.calendar
      opts = NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit
      comps = calendar.components(opts, fromDate:date)
      # set last of month
      comps.month = comps.month + offset
      comps.day = 0      
      end_of_day(calendar.dateFromComponents(comps))
    end
  end
end
