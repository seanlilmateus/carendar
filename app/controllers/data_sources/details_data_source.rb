module Carendar

  class DetailsDataSource

    def initialize
      @events = NSDictionary.dictionary
    end
    attr_reader :events


    def events=(items)
      groups = items.group_by { |event| event.startDate.day }
      @events = NSDictionary.dictionaryWithDictionary(groups)
      @sorted_keys = @events.keys.sort #.sortedArrayUsingSelector('compare:')
      @events
    end


    def eventAtIndexPath(index_path)
      key = @sorted_keys[index_path.section]
      @events[key][index_path.item]
    end


    def [](value)
      eventAtIndexPath(value)
    end


    # TODO: change according to events instancce
    def indexPathsOfEventsBetweenMinDayIndex(min_day_index, maxDayIndex:max_day_index, minStartHour:min_start_hour, maxStartHour:max_start_hour)
      @events.flat_map.with_index do |(section, items), i|
        section = @events.keys.index(section)
        items.flat_map.with_index do |event, item|
          e = event.startDate
          if e.day >= min_day_index && e.day <= max_day_index && 
             e.hour >= min_start_hour && e.hour <= max_start_hour
            NSIndexPath.indexPathForItem(item, inSection:section)
          end
        end.compact
      end.compact
    end


    def numberOfSectionsInCollectionView(clv)
      @events.keys.count
    end


    def collectionView(clv, numberOfItemsInSection:section)
      key = @sorted_keys[section]
      @events.fetch(key, []).count
    end


    def collectionView(clv, itemForRepresentedObjectAtIndexPath:index_path)
      cell = clv.makeItemWithIdentifier(CollectionViewItem::IDENTIFIER, forIndexPath:index_path)
      event = self[index_path]
      cell.view.backgroundColor = event.calendar.color
      start_date = event.startDate
      cell.double_click do
        Dispatch::Queue.concurrent.async do
          calendar_app = SBApplication.applicationWithBundleIdentifier('com.apple.ical')
          calendar_app.activate
          cal = calendar_app.calendars.find { |c| c.name == event.calendar.title }
          cal.events.objectWithID(event.UUID).show
        end
      end
      cell.textField.stringValue =  event.title
      cell.descriptionLabel.stringValue = event.calendar.title
      cell.timeLabel.stringValue = duration(start_date, event.endDate)
      cell.view.toolTip = event.title
      cell
    end


    def collectionView(clv, viewForSupplementaryElementOfKind:kind, atIndexPath:index_path)
      identifier = DetailsHeaderView::IDENTIFIER
      clv.makeSupplementaryViewOfKind(kind, withIdentifier:identifier, forIndexPath:index_path).tap do |header|
        event = self[index_path]
        header.detailsField.hidden = true
        header.separators.each { |s| s.hidden = false }
        if clv.collectionViewLayout.is_a?(StickyHeaderDaily)
          header.textField.alignment = NSCenterTextAlignment
          header.stack.alignment = NSLayoutAttributeCenterX
          header.detailsField.hidden = false
          header.textField.stringValue = "%02d" % (event.startDate.day)
          header.detailsField.stringValue = event.startDate.month_short_name.upcase
        end
      end
    end


    def collectionView(clv, layout:_, sizeForItemAtIndexPath:_)
      NSSize.new(clv.frame.size.width - 2.0, 60.0)
    end


    def duration(start_date, end_date)
      opts = NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute
      components = NSCalendar.currentCalendar
                             .components(opts, fromDate: start_date, toDate: end_date, options: 0)
      days, hours, minutes = components.day, components.hour, components.minute
      
      duration_string = ""
      if days > 0
        duration_string = days > 1 ? "#{days} days" : localized_string('all-day', 'all-day')
      end
      
      if hours > 0
        value = hours > 1 ? "#{hours} hours" : "#{hours} hour"
        duration_string = duration_string.empty? ? value : (duration_string += " and #{value}")
      end
      
      if minutes > 0
        value = minutes > 1 ? "#{minutes} minutes" : "#{minutes} minute"
        duration_string = duration_string.empty? ? value : (duration_string += " and #{value}")
      end
      
      duration_string
    end
    
  end
end
