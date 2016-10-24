module Carendar
  class CollectionViewItem < NSCollectionViewItem
    IDENTIFIER = "CollectionViewItem"


    def textField
      self.view.textField
    end


    def method_missing(meth, *args, &blk)
      if self.view.respond_to?(meth)
        self.view.send(meth, *args, &blk)
      else
        super
      end
    end


    def applyLayoutAttributes(attributes)
      super
    end


    def backgroundColor= color
      self.view.backgroundColor = color#.CGColor
    end


    def loadView
      self.view = DetailsItemView.new
    end


    def setHighlightState(state)
      self.view.highlightState = state
      super
    end


    def setSelected(selected)
      super
      self.view.selected = selected
    end
  end

end