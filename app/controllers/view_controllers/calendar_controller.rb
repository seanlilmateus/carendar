module Carendar
  class CalendarController < BaseViewController
    
    attr_accessor :textColor, :selectionColor, :dayMarkerColor
    attr_accessor :todayMarkerColor, :backgroundColor, :date
    attr_reader :delegate
    
    def delegate=(d); @delegate = WeakRef.new(d); end


    class << self
      def calendar
        @__calendar__ ||= NSCalendar.currentCalendar.tap do |cal|
          cal = NSCalendar.currentCalendar
          cal.timeZone = NSTimeZone.timeZoneWithAbbreviation("UTC")
        end
      end


      def isSameDate(d1, date:d2)
        return false if d2.nil? || d1.nil?
        calendar.isDate(d1, inSameDayAsDate:d2)
      end


      def dd(dt)
        dt ||= NSDate.date
        unit_flags = NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMonth
        comps = calendar.components(unit_flags, fromDate:dt)
        "#{comps.year}-#{comps.month}-#{comps.day}"
      end
    end


    def init
      super.tap { common_init }
    end


    def loadView
      rect = NSRect.new([0, 0], [280.0, 332.0])
      self.view = CalendarView.alloc.initWithFrame(rect)
      self.view.populate_subviews
    end


    def viewDidLoad
      super
      self.view.calendar_days
          .each do |cell| 
            cell.target = self
            cell.action = 'cellClicked:'
            cell.owner = WeakRef.new(self)
          end
      [ self.view.next_button, 
        self.view.prev_button
      ].zip(%W[nextMonth: prevMonth:]) { |vw, action| vw.target, vw.action = self, action }
      
      @df ||= NSDateFormatter.new
      day_labels = self.view.week_days
      @df.shortStandaloneWeekdaySymbols
         .each_with_index {|day, i| day_labels[colForDay(i+1)].stringValue = day.upcase[0..1]}
      bv = self.view
      bv.backgroundColor = self.backgroundColor
      self.date = NSDate.date
    end


    def viewWillAppear
      super
      self.layoutCalendar
    end


    def date=(dt)
      dt ||= NSDate.date
      @date = self.toUTC(dt)
      self.layoutCalendar
      unit_flags = NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMonth
      components = self.class.calendar.components(unit_flags, fromDate:self.date)
      
      month, year = components.month, components.year
      month_name = @df.standaloneMonthSymbols[month-1].capitalize
      self.view.calendarTitle.stringValue = "#{month_name} #{year}"
    end


    def toUTC(dt)
      dt ||= NSDate.date
      unit_flags = NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMonth
      components = self.class.calendar.components(unit_flags, fromDate:dt)
      self.class.calendar.dateFromComponents(components)
    end


    def selectedDate=(dt)
      @selectedDate = toUTC(dt)
      self.view.calendar_days
          .each { |cell| cell.selected = self.class.isSameDate(cell.representedDate, date:@selectedDate) }
    end


    def cellClicked(sender)
      self.view.subviews
          .select { |sbv| sbv.is_a?(CalendarCell) }
          .each   { |sbv| sbv.selected = (sender == sbv) }
            
      @selectedDate = sender.representedDate
      if self.delegate && self.delegate.respond_to?('didSelectDate:')
        self.delegate.didSelectDate(@selectedDate)
      end
    end


    def monthDay(day)
      unit_flags = NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMonth
      components = self.class.calendar.components(unit_flags, fromDate:(@date || NSDate.date))
      comps = NSDateComponents.new
      comps.day, comps.year, comps.month = day, components.year, components.month
      self.class.calendar.dateFromComponents(comps)
    end


    def lastDayOfTheMonth
      opts, unit = NSCalendarUnitMonth, NSCalendarUnitDay
      days_range = self.class.calendar
                       .rangeOfUnit(unit, inUnit:opts, forDate:self.date)
      days_range.length
    end


    def colForDay(day)
      idx = day - self.class.calendar.firstWeekday
      idx = 7 + idx if idx < 0
      idx 
    end


    def layoutCalendar
      return unless self.view
      cells = self.view.subviews
                  .select { |sbv| sbv.is_a?(CalendarCell) }
      cells.each { |sbv| sbv.representedDate, sbv.selected = nil, false }
      unit_flags = NSCalendarUnitWeekday
      components = self.class.calendar.components(unit_flags, fromDate: monthDay(1))
      first_day = components.weekday
      last_day = lastDayOfTheMonth
      col = colForDay(first_day)
      day = 1
      
      cells.each_slice(7) do |rows|
        rows[col..-1].each do |cell| # this is necessary to start on the correct day
          if day <= last_day
            dt = monthDay(day)
            cell.representedDate = dt
            cell.selected = self.class.isSameDate(dt, date:@selectedDate)
            day += 1
          end
          col = 0
        end
      end
    end


    def stepMonth(dm)
    	unit_flags = NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMonth
      components = self.class.calendar.components(unit_flags, fromDate:self.date)
      month = components.month + dm
      year = components.year
      
      if month > 12
        month = 1
        year += 1
      end
    
      if month < 1
        month = 12
        year -= 1
      end
      
      components.year = year
      components.month = month
      self.date = self.class.calendar.dateFromComponents(components)
      if self.delegate && self.delegate.respond_to?('didChangeMonth:')
          self.delegate.didChangeMonth(self.date)
      end
    end


    def nextMonth(sender)
      stepMonth(1)
    end


    def prevMonth(sender)
      stepMonth(-1)
    end


    private
    def common_init
      @todayMarkerColor = NSColor.greenColor
      @backgroundColor = NSColor.clearColor
      @selectionColor = NSColor.redColor
      @dayMarkerColor = NSColor.darkGrayColor
      @textColor = NSColor.blackColor
      @date = NSDate.date
    end

  end
end
