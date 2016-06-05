module Carendar
  class CalendarViewItem < NSCollectionViewItem
    IDENTIFIER = "CalendarViewItem"


    def representedObject=(value)
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
  end

end