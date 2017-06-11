module Carendar

  class DetailsDataSource

    def initialize
      @events = NSDictionary.dictionary
    end
    attr_reader :events


    def events=(items)
      groups = items.group_by { |event| event.startDate.day }
      @events = NSDictionary.dictionaryWithDictionary(groups)
      @sorted_keys = NSArray.arrayWithArray(@events.keys.sort)
      @events
    end


    def eventAtIndexPath(index_path)
      key = @sorted_keys[index_path.section]
      events[key][index_path.item]
    end


    def [](index_path)
      eventAtIndexPath(index_path)
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
      events.keys.count
    end


    def collectionView(clv, numberOfItemsInSection:section)
      key = @sorted_keys[section]
      events.fetch(key, []).count
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
      cell.view.toolTip = "#{event.title}\n#{cell.timeLabel.stringValue}"
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
      @timeFormat ||= NSDateFormatter.new.tap {|tf| tf.dateFormat = "HH:mm" }
      times = [start_date, end_date].map do |time|
          @timeFormat.stringFromDate(time)
      end
      
      iterval = NSDateInterval.alloc.initWithStartDate(start_date, endDate:end_date)
      duration_string = TimeIntervalUtils.time_interval(iterval.duration)
      
      if duration_string == localized_string('all-day', 'all-day') 
        duration_string = if times.all? { |time| time == "00:00" }
          localized_string('all-day', 'all-day') 
        else
          localized_string("one.day", "24 HOURS")
        end
      else
        args = [*times, duration_string]
        format = localized_string("%@ to %@ duration: (%@)", "%@ to %@ duration: (%@)")
        NSString.stringWithFormat(format, *args)
      end
    end
    
  end
end
