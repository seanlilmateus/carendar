module Carendar
  class DetailsDataSource
    def initialize
      @events = NSArray.array
    end
    attr_reader :events


    def events=(items)
      groups = items.group_by { |event| [event.startDate.day, event.startDate.month_short_name] }
      @events = NSDictionary.dictionaryWithDictionary(groups)
    end


    def eventAtIndexPath(index_path)
      key = @events.keys[index_path.section]
      @events[key][index_path.item]
    end


    def [](value)
      eventAtIndexPath(value)
    end


    # TODO: change according to events instancce
    def indexPathsOfEventsBetweenMinDayIndex(min_day_index, maxDayIndex:max_day_index, minStartHour:min_start_hour, maxStartHour:max_start_hour)
      @events.flat_map.with_index do |(section, items), i|
        section = @events.keys.index(section)
        items.flat_map.with_index do |e, item|
          if e.day >= min_day_index && e.day <= max_day_index && 
             e.startHour >= min_start_hour && e.startHour <= max_start_hour
            NSIndexPath.indexPathForItem(item, inSection:section)
          end
        end.compact
      end.compact
    end


    def numberOfSectionsInCollectionView(clv)
      @events.keys.count
    end


    def collectionView(clv, numberOfItemsInSection:section)
      key = @events.keys[section]
      @events[key].count
    end


    def collectionView(clv, itemForRepresentedObjectAtIndexPath:index_path)
      id = CollectionViewItem::IDENTIFIER
      cell = clv.dequeueReusableItemWithReuseIdentifier(id, forIndexPath:index_path)
      cell.view.backgroundColor = NSColor.magentaColor
      event = self[index_path]
    
      xcross = "%02d:%02d" % [event.hour, event.minute]
      value = '%02d:%02d duration - %04d' % [event.hour, event.minute, event.duration]
      cell.textField.stringValue =  event.title
      cell.descriptionLabel.stringValue = xcross
      cell.timeLabel.stringValue = value
      cell.view.setToolTip event.title
      cell
    end


    def collectionView(clv, viewForSupplementaryElementOfKind:kind, atIndexPath:index_path)
      id = DetailsHeaderView::IDENTIFIER
      clv.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier:id, forIndexPath:index_path).tap do |header|
        header.detailsField.hidden = true
        header.separators.each { |s| s.hidden = false }
        if index_path.item == 0 && clv.collectionViewLayout.is_a?(DayCalendarViewLayout) && kind == id
          header.stack.alignment = NSLayoutAttributeCenterX
          text = "SUNDAY #{index_path.item + 1}st January 2016"
          header.textField.stringValue = text
        elsif clv.collectionViewLayout.is_a?(StickyHeaderDaily)
          header.textField.alignment = NSCenterTextAlignment
          header.stack.alignment = NSLayoutAttributeCenterX
          header.detailsField.hidden = false
          header.textField.stringValue = "%02d" % (index_path.section + 1)
          header.detailsField.stringValue = "DEZ"
        elsif clv.collectionViewLayout.is_a?(DayCalendarViewLayout)
          header.stack.alignment = NSLayoutAttributeLeft
          header.separators.each { |s| s.hidden = true }
          header.textField.stringValue = "10:00"
          text = "#{'%.2i:00' % (index_path.item == 24 ? 0 : index_path.item)}"
          header.textField.stringValue = text
        end
      end
    end


    def collectionView(clv, layout:_, sizeForItemAtIndexPath:_)
      NSSize.new(clv.frame.size.width - 2.0, 60.0)
    end

  end
end
