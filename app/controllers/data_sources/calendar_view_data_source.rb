module Carendar
  class CalendarViewDataSource
    def initialize(date=NSDate.date)
      self.current_date = date
      @calendar = NSCalendar.autoupdatingCurrentCalendar
    end
    attr_reader :current_date


    def month
      @current_date.month
    end


    def title
      self.current_date.month_name_full
    end
    

    def year
      @current_date.year
    end


    def current_date=(date)
      @current_date = NSDate.with(year: date.year, month: date.month, day: 1)
      CATransaction.begin
      CATransaction.setValue(KCFBooleanTrue, forKey:KCATransactionDisableActions)
      section = NSIndexSet.indexSetWithIndex(0)
      @collection_view&.reloadSections(section)
      CATransaction.commit
    end


    def next_month!
      add_month(1)
      change_to_date
    end


    def previous_month!
      add_month(-1)
      change_to_date
    end



    def change_to_date(date=@current_date)
      self.current_date = date
    end


    def add_month(value)
      date_compts = NSDateComponents.new.tap { |dc| dc.month = value }
      @current_date = calendar.dateByAddingComponents(date_compts, 
                        toDate:@current_date,
                       options:NSCalendarMatchFirst)
      @collection_view&.viewController&.month_changed
    end


    def numberOfSectionsInCollectionView(clv)
      1
    end


    def collectionView(clv, numberOfItemsInSection: section)
      @weeks = NSMutableOrderedSet.orderedSet
      @collection_view ||= WeakRef.new(clv)
      components = NSDateComponents.new
      components.month = section
      start_date = calendar.dateByAddingComponents(components, 
                     toDate:current_date, options:0)
      prefix_and_suffix(start_date).reduce(:+)
    end


    def collectionView(clv, itemForRepresentedObjectAtIndexPath: indexPath)
      id = CalendarViewItem::IDENTIFIER
      cell = clv.dequeueReusableItemWithReuseIdentifier(id, forIndexPath: indexPath)
    
      # this allow to create multiple Sections
      components = NSDateComponents.new
      components.month = indexPath.section
      date = calendar.dateByAddingComponents(components, toDate:@current_date, options:0)
    
      first_day_of_this_month = date.firstDayOfMonth
      prefix_days = prefix_and_suffix(first_day_of_this_month).first
    
    
      date = if indexPath.item >= prefix_days
        first_day_of_this_month.dateByAddingDays(indexPath.item - prefix_days)
      else # previous month
        day = -(prefix_days - indexPath.item)
        first_day_of_this_month.dateByAddingDays(day)
      end
    
      cell.representedObject = date
      @weeks.addObject(date.weekNumber)
      if @weeks.count >= 5 && clv.respond_to?(:viewController) && clv&.viewController&.respond_to?(:update_weeks)
        clv.viewController.update_weeks(@weeks)
      end
      cell.active = cell.representedObject.month == @current_date.month
      cell
    end


    def collectionView(clv, viewForSupplementaryElementOfKind: kind, atIndexPath: indexPath)
      case kind
      when NSCollectionElementKindSectionHeader
        cell = clv.dequeueReusableSupplementaryViewOfKind( kind, 
                              withReuseIdentifier: CalendarHeader::IDENTIFIER, 
                                     forIndexPath: indexPath)
        cell.titleLabel.text = current_month_full_name(indexPath.section)
        buttons = [cell.next_button, cell.prev_button]
        actions = [:next_month!, :previous_month!]
        actions.zip(buttons) { |sel, b| b.target, b.action = self, sel }
        cell
      end
    end


    def current_month_full_name(section=0)
      components = NSDateComponents.new
      components.month = section
      components.day = 2
      components.hour = 23
      date = calendar.dateByAddingComponents(components, toDate:current_date, options:0)
      date.month_name_full
    end


    private
    def prefix_and_suffix(date)
      weekday_of_date = calendar.ordinalityOfUnit(NSWeekdayCalendarUnit, 
                          inUnit:NSWeekCalendarUnit, forDate:date)
      prefix = weekday_of_date - 1
      comps = NSDateComponents.new
      comps.month = 1
      comps.day = -1

      last_day_of_month = calendar.dateByAddingComponents(comps, 
                            toDate:date, options:0)
      weekday_of_date = calendar.ordinalityOfUnit(NSWeekdayCalendarUnit,
                          inUnit:NSWeekCalendarUnit, 
                         forDate:last_day_of_month)
      suffix = 7 - weekday_of_date
      [prefix, last_day_of_month.day, suffix]
    end
    attr_reader :calendar

  end
end