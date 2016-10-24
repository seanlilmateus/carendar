module Carendar
  class DayCalendarViewLayout < NSCollectionViewFlowLayout
  
    HORIZONTAL_SPACING = 10
    DAY_HEADER_HEIGHT = 40
    HOUR_HEADER_WIDTH = 100
    HEIGHT_PER_HOUR = 40
    DAYS_PER_WEEK = 1
    HOURS_PER_DAY = 25


    def self.layoutAttributesClass
      ColoredLayoutAttributes
    end


    def init
      super.tap do |instance| 
        instance.registerClass(Line, forDecorationViewOfKind:Line::IDENTIFIER)
      end
    end


    def collectionViewContentSize
      width = self.collectionView.bounds.size.width
      height = DAY_HEADER_HEIGHT + (HEIGHT_PER_HOUR * HOURS_PER_DAY)
      CGSize.new(width, height)
    end


    def layoutAttributesForElementsInRect(rect)
      visible_index_paths = indexPathsOfItemsInRect(rect)
    
      attributes = visible_index_paths.map do |index_path| 
        layoutAttributesForItemAtIndexPath(index_path)
      end
      #dected = detect_overflow(attributes)
      #dected.each {|k,v| puts "#{k} => #{v.allObjects}"}
      @day_header_view_attributes ||= indexPathsOfDayHeaderViewsInRect(rect).map do |index_path|
        item = self.layoutAttributesForSupplementaryViewOfKind(HeaderView::IDENTIFIER, atIndexPath:index_path)
        y = self.collectionView.contentOffset.y
        origin = y > 0 ?  [0, y] : [0, 0]
        item.frame = NSRect.new(origin, item.frame.size)
        item.zIndex = 18
        item
      end
    
      @lines_attributes ||= Array.new(HOURS_PER_DAY) do |idx|
        index_path = NSIndexPath.indexPathForItem(idx, inSection:0)
        self.layoutAttributesForDecorationViewOfKind(Line::IDENTIFIER, atIndexPath:index_path)
      end
    
      @hour_header_view_attributes ||= indexPathsOfHourHeaderViewsInRect(rect).map do |index_path|
        self.layoutAttributesForSupplementaryViewOfKind(HOUR_HEADER_VIEW, atIndexPath:index_path)
      end
    
    
      NSArray.arrayWithArray(attributes + @day_header_view_attributes + @hour_header_view_attributes + @lines_attributes)
    end


    def invalidateLayout
      super
      @day_header_view_attributes = nil
      @hour_header_view_attributes = nil
      @lines_attributes = nil
    end


    def layoutAttributesForItemAtIndexPath(index_path)
      data_source = self.collectionView.dataSource
      event = data_source[index_path]
      attributes = ColoredLayoutAttributes.layoutAttributesForItemWithIndexPath(index_path)
      attributes.backgroundColor = NSColor.blueColor
      attributes.frame = frameForEvent(event) || attributes.frame
      attributes.zIndex = 8
      attributes
    end


    def layoutAttributesForSupplementaryViewOfKind(kind, atIndexPath:index_path)
      attributes = ColoredLayoutAttributes.layoutAttributesForSupplementaryViewOfKind(kind, withIndexPath:index_path)
      total_width = self.collectionViewContentSize.width
      case kind
      when HeaderView::IDENTIFIER
        available_width = total_width - HOUR_HEADER_WIDTH
        width_per_day = (available_width / DAYS_PER_WEEK) * 0.60
        origin = [0, 0]
        #size = [width_per_day, 30]
        size = [total_width, 30]
        #origin = [HOUR_HEADER_WIDTH - (width_per_day * index_path.item), 0]
        attributes.frame = CGRect.new(origin, size)
        attributes.zIndex = -9
      when HOUR_HEADER_VIEW
        origin = [
          0, (DAY_HEADER_HEIGHT + HEIGHT_PER_HOUR * index_path.item) - 20.0
        ]
        attributes.frame = CGRect.new(origin, [total_width, HEIGHT_PER_HOUR])
        attributes.zIndex = - 10
      end

      attributes
    end


    def layoutAttributesForDecorationViewOfKind(kind, atIndexPath:index_path)
      case kind
      when Line::IDENTIFIER
        total_width = self.collectionViewContentSize.width * 0.8
        attributes = super || ColoredLayoutAttributes.layoutAttributesForDecorationViewOfKind(kind, 
                  withIndexPath:index_path)
        y = 40.0 + (index_path.item * 40)
        attributes.frame = CGRect.new([55.0, y], [total_width, 1.0])
        attributes.zIndex = -7
        attributes
      end
    end


    def shouldInvalidateLayoutForBoundsChange(_)
      true
    end


    # HELPERS
    def indexPathsOfItemsInRect(rect)
      min_visible_day  = dayIndexFromXCoordinate CGRectGetMinX(rect)
      max_visible_day  = dayIndexFromXCoordinate CGRectGetMaxX(rect)
      min_visible_hour = hourIndexFromYCoordinate CGRectGetMinY(rect)
      max_visible_hour = hourIndexFromYCoordinate CGRectGetMaxY(rect)
    
      data_source = self.collectionView.dataSource
      data_source.indexPathsOfEventsBetweenMinDayIndex(min_visible_day, 
                               maxDayIndex:max_visible_day, 
                              minStartHour:min_visible_hour, 
                              maxStartHour:max_visible_hour)
    end


    def dayIndexFromXCoordinate(xposition)
      width = self.collectionViewContentSize.width - HOUR_HEADER_WIDTH
      width_per_day = width / DAYS_PER_WEEK
      [0, ((xposition - HOUR_HEADER_WIDTH) / width_per_day).to_i].max
    end


    def hourIndexFromYCoordinate(yposition)
      [0, ((yposition - DAY_HEADER_HEIGHT) / HEIGHT_PER_HOUR).to_i].max
    end


    def indexPathsOfDayHeaderViewsInRect(rect)
      return NSArray.array if (CGRectGetMinY(rect) > DAY_HEADER_HEIGHT)
      min_day_index = dayIndexFromXCoordinate CGRectGetMinX(rect)
      max_day_index = dayIndexFromXCoordinate CGRectGetMaxX(rect)
      Array.new(max_day_index) do |idx|
        NSIndexPath.indexPathForItem(idx, inSection:0)
      end[0..24]
    end


    def indexPathsOfHourHeaderViewsInRect rect
      return NSArray.array if CGRectGetMinX(rect) > HOUR_HEADER_WIDTH
      min_hour_index = hourIndexFromYCoordinate CGRectGetMinY(rect)
      max_hour_index = hourIndexFromYCoordinate CGRectGetMaxY(rect)
      min_hour_index.upto(max_hour_index).map do |idx|
        NSIndexPath.indexPathForItem(idx, inSection:0)
      end[0..24]
    end


    def frameForEvent(event)
      return nil unless event
      total_Width = self.collectionViewContentSize.width - HOUR_HEADER_WIDTH
      width_per_day = total_Width / DAYS_PER_WEEK
      frame = CGRect.new
      frame.origin.x = 60.0 #(width_per_day * event.day) - HOUR_HEADER_WIDTH;
      minutes = ((HEIGHT_PER_HOUR / 60.0) * event.minutes)
      frame.origin.y = DAY_HEADER_HEIGHT + (HEIGHT_PER_HOUR * event.startHour) + (minutes)
      frame.size.width = self.collectionViewContentSize.width * 0.75
      frame.size.height = event.durationInHours * HEIGHT_PER_HOUR;
      CGRectInset(frame, HORIZONTAL_SPACING/2.0, 0)
    end
  
  
    MARGIN_LEFT = 20.0
    MARGIN_RIGHT = 2.0
    def adjust(attributes, section=1, section_min=100)
      section_indexz, section_width = 10, 200
      adjusted_attributes = NSMutableSet.new
      attributes.each do |item|
        next if adjusted_attributes.containsObject(item)
        overlapping_items = []
        item_frame = item.frame

        predicate = NSPredicate.predicateWithBlock(Proc.new do |attrs, bindings|
          attrs == item ? CGRectIntersectsRect(item_frame, attrs.frame) : false
        end)
        #overlapping_items = attributes.select do |attrs| 
        #  attrs ==  item_frame ? false : CGRectIntersectsRect(item_frame, attrs.frame)
        #end
        filtered = attributes.filteredArrayUsingPredicate(predicate)
        overlapping_items.addObjectsFromArray(filtered)
    
        unless overlapping_items.count.zero?
          overlapping_items.insertObject(item, atIndex:0)
          # Find 
          min_y, max_y = Float::MIN, 400.0
      
          overlapping_items.each do |overlap_item|
            if CGRectGetMinY(overlap_item.frame) < min_y
              min_y = CGRectGetMinY(overlap_item.frame)
            end
            if CGRectGetMaxY(overlap_item.frame) > max_y
              max_y = CGRectGetMaxY(overlap_item.frame)
            end
          end
      
          divisions = 1
          min_y.step(max_y, 1.0) do |current_y|
            number_items_for_current_y = 0
            overlapping_items.each do |attrs|
              if current_y >= CGRectGetMinY(attrs.frame) && current_y < CGRectGetMaxY(attrs.frame)
                number_items_for_current_y += 1
              end
            end
        
            if number_items_for_current_y > divisions
              divisions = number_items_for_current_y
            end
          end
      
          division_width = (section_width / divisions).to_i
          divided_attributes = []
          overlapping_items.each do |div_attrs|
            item_width = division_width - MARGIN_LEFT - MARGIN_RIGHT
        
            unless adjusted_attributes.containsObject(div_attrs)
              division_attributes_frame = div_attrs.frame
              division_attributes_frame.origin.x = (section_min + MARGIN_LEFT)
              division_attributes_frame.size.width = division_width
          
              adjustments = 1
              divided_attributes.each do |attrs|
                if CGRectIntersectsRect(attrs.frame, division_attributes_frame)
                  division_attributes_frame.origin.y = section_min + (division_width * adjustments) + MARGIN_LEFT
                  adjustments += 1
                end
              end
          
          
              div_attrs.zIndex = section_indexz
              section_indexz += 1
              div_attrs.frame = division_attributes_frame
              divided_attributes.addObject(div_attrs)
              adjusted_attributes.addObject(div_attrs)
            end
        
          end
        end
      end
    end


    def detect_overflow(items)
      result = Hash.new { |h, k| h[k] = NSMutableOrderedSet.new }
      items.each do |i1|
        items.each do |i2|
          contained = Proc.new do |set| 
            set.containsObject(i2) || set.containsObject(i1)
          end
          next if i1 == i2 || result.values.any?(&contained)
          if CGRectIntersectsRect(i1.frame, i2.frame)
            result[i1.object_id].addObject(i1)
            result[i1.object_id].addObject(i2)
          end
        end
      end
      result
    end
  end
  
end