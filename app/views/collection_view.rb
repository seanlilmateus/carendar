module Carendar
  class CollectionView < NSCollectionView
    def contentOffset
      if scroll = checkedSuperview
        scroll.documentVisibleRect.origin
      else
        NSPoint.new#(10, 10)
      end
    end


    def setContentOffset(point)
      if scroll = checkedSuperview
        scroll.documentView.scrollPoint point
      end
    end
    alias_method :contentOffset=, :setContentOffset


    def setContentSize(size)
      if scroll = checkedSuperview
        scroll.documentView.setFrameSize = size
      end
    end
    alias_method :contentSize=, :setContentSize


    def contentInsets
      if scroll = checkedSuperview
        scroll.contentInsets
      else
        NSEdgeInsets.new(0.0, 0.0, 0.0, 0.0)
      end
    end


    def setContentInsets(insets)
      if scroll = checkedSuperview
        scroll.setContentInsets insets
      end
    end
    alias_method :contentInsets=, :setContentInsets


    def contentSize
      if scroll = checkedSuperview
        scroll.contentSize
      else
        self.frame.size
      end
    end


    # Mouse events and selection
    def canBecomeKeyView
      true
    end


    def acceptsFirstResponder
      true
    end


    def becomeFirstResponder
      true
    end


    def resignFirstResponder
      true
    end


    def becomeFirstResponder
      true
    end


    def mouseDown(sender)
      super
      # selectFirstItemAndScrollIfNeeded
    end


    private
    def selectFirstItemAndScrollIfNeeded
      return false unless self.selectionIndexPaths.count == 0
      return false if self.indexPathsForVisibleItems.count == 0
    
      indexPath = NSIndexPath.indexPathForItem(0, inSection: 0)
      first_item = NSSet.setWithObject(indexPath)
      scroll_position = NSCollectionViewScrollPositionCenteredVertically
      if self.indexPathsForVisibleItems.intersectsSet(first_item)
        scroll_position = NSCollectionViewScrollPositionNone
      end
    
      self.selectItemsAtIndexPaths(first_item, scrollPosition: scroll_position)
      true
    end


    def checkedSuperview
      if superview&.superview && superview.superview.is_a?(NSScrollView)
        return superview.superview
      end
    end
    
  end
end