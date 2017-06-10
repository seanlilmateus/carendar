module Carendar
  class CalendarViewItem < NSCollectionViewItem
    IDENTIFIER = "CalendarViewItem"
    ACCE_DATE_FORMATER = NSDateFormatter.new.tap do |df|
      df.formatterBehavior = NSDateFormatterBehavior10_4
      df.dateStyle = NSDateFormatterFullStyle
      df.timeStyle = NSDateFormatterNoStyle
    end


    def representedObject=(value)
      self.title = value.to_s
      self.view.representedObject = value
    end


    def method_missing(meth, *args, &blk)
      if self.view.respond_to?(meth)
        self.view.send(meth, *args, &blk)
      else
        super
      end
    end


    def representedObject
      self.view.representedObject
    end

    def prepareForReuse
      self.view.prepareForReuse
    end


    def applyLayoutAttributes(attributes)
      super
    end


    def loadView
      self.view = CalendarCell.new.tap do |instance|
        instance.translatesAutoresizingMaskIntoConstraints = false
      end
    end


    def setHighlightState(state)
      super
      self.view.highlightState = state
    end


    def setSelected(selection)
      self.view.selected = selection
      super
    end


    def active?
      self.view.active?
    end


    def selected?
      self.view.selected
    end
    
    
    def conformsToProtocol(protocol)
      super
    end


    # Accessibility
    # accessibilityLabel -> String
    def accessibilityLabel
      date = self.view.representedObject
      ACCE_DATE_FORMATER.stringFromDate(date)
    end


    def accessibilityValue
      self.view.representedObject.day.to_s
    end


    def accessibilityTitle
      date = self.view.representedObject
      ACCE_DATE_FORMATER.stringFromDate(date)
    end


    def accessibilityRole
      NSAccessibilityButtonRole
    end


    # Required
    # accessibilityPerformPress -> (TrueClass | FalseClass)
    def accessibilityPerformPress
      select!
      true
    end


    def accessibilityContentSiblingBelow
      indexPath = collectionView.indexPathForItem(self)
      collectionView.itemAtIndex(indexPath.item + 7)
    end


    def accessibilityContentSiblingAbove
      indexPath = collectionView.indexPathForItem(self)
      indexPath.item < 6 ? nil : collectionView.itemAtIndex(indexPath.item - 7)
    end


    def canBecomeFirstResponder
      true
    end


    private
    def collectionView
      self.view.superview
    end


    def select!
      controller = collectionView.delegate
      indexPath  = collectionView.indexPathForItem(self)
      indexPaths = NSSet.setWithArray([indexPath])
      controller.collectionView(collectionView, didSelectItemsAtIndexPaths:indexPaths)
      controller.select_date(self.view.representedObject)
    end
    
  end

end