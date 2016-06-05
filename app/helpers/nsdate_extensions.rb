class NSDate
  def self.with(attributes)
    date_comps = NSDateComponents.new.tap do |dc|
      dc.year  = attributes.fetch(:year, NSDate.date.year)
      dc.month = attributes.fetch(:month, 1)
      dc.day   = attributes.fetch(:day, 1)
      dc.hour  = attributes.fetch(:hour, 1)
    end
    dt = NSCalendar.autoupdatingCurrentCalendar
                   .dateFromComponents(date_comps)
    self.dateWithTimeInterval(0, sinceDate: dt)
  end
  
  def firstDayOfMonth
    units = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
    date_comps = unit_component(units).tap { |dc| dc.day = 1 }
    calendario.dateFromComponents(date_comps)
  end


  def dateByAddingMonths(months)
    date_comps = NSDateComponents.new.tap { |dc| dc.month = months }
    calendario.dateByAddingComponents(date_comps, 
        toDate: self, options: NSCalendarMatchNextTime)
  end


  def dateByAddingDays(days)
    date_comps = NSDateComponents.new.tap { |dc| dc.day = days }
    calendario.dateByAddingComponents(date_comps, 
        toDate: self, options: NSCalendarMatchNextTime)
  end


  def hour
    unit_component(NSCalendarUnitHour).hour
  end


  def second
    unit_component(NSCalendarUnitSecond).hour
  end

  def minute 
    unit_component(NSCalendarUnitMinute).minute
  end


  def day
    unit_component(NSCalendarUnitDay).day
  end

  # http://nshipster.com/nscalendar-additions/
  alias today? isInToday # isDateInToday
  alias isDateSameDay isInSameDayAsDate


  def weekday
    unit_component(NSCalendarUnitWeekday).weekday
  end


  def weekNumber
    unit_component(NSCalendarUnitWeekOfYear).weekOfYear
  end


  def numberOfDaysInMonth
    days = calendario.rangeOfUnit(NSCalendarUnitDay, 
               inUnit:NSCalendarUnitMonth, forDate: self)
    days.length
  end


  def dateByIgnoringTime
    opts = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
    compts = unit_component(NSCalendarUnitWeekday)
    calendario.dateFromComponents(compts)
  end


  def month_name_full
    formats = NSDateFormatter.new
    formats.dateFormat = "MMMM YYYY"
    formats.stringFromDate(self)
  end


  def sunday?
    self.weekday == 1
  end


  def monday?
    self.weekday == 2
  end

  def tuesday?
    self.weekday == 3
  end


  def wednesday?
    self.weekday == 4
  end


  def thursday?
    self.weekday == 5
  end


  def friday?
    self.weekday == 6
  end


  def saturday?
    self.weekday == 7
  end


  def weekend?
    calendario.isDateInWeekend(self)
  end


  def unit_component(unit)
    calendario.components(unit, fromDate: self)
  end


  def <=> other
    self.compare(other)
  end

  private
    def calendario
      NSCalendar.currentCalendar
    end
end
