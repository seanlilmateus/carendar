module Carendar
  DAY_HEADER_VIEW = NSCollectionElementKindSectionHeader #"DayHeaderView"
  HOUR_HEADER_VIEW = "HourHeaderView"
  HEADER_VIEW = DetailsHeaderView::IDENTIFIER

  class DetailsViewController < BaseViewController
    attr_accessor :data_source
    
    def loadView
      @data_source = DetailsDataSource.new
      super
    end


    def viewDidLoad
      super
      self.view.addSubview(container)
      self.view.translatesAutoresizingMaskIntoConstraints = false
      collectionView.registerClass( CollectionViewItem,
        forItemWithReuseIdentifier: CollectionViewItem::IDENTIFIER)
      
      collectionView.registerClass( DetailsHeaderView, 
        forSupplementaryViewOfKind: NSCollectionElementKindSectionHeader,
                    withIdentifier: DetailsHeaderView::IDENTIFIER)
    
      collectionView.registerClass( CellSeparator,
        forSupplementaryViewOfKind: NSCollectionElementKindSectionFooter,
               withReuseIdentifier: "Footer")
      collectionView.dataSource = self.data_source
      collectionView.collectionViewLayout = daily_layout
    end


    def update_layout
      current_layout = case @layout_kind
                       when :daily then daily_layout
                       when :details then sticky_layout
                       end
      if NSAnimationContext.currentContext.duration > 0.0
        NSAnimationContext.currentContext.duration = 0.5
      end
      collectionView.animator.collectionViewLayout = current_layout
      collectionView.reloadData
    end


    def daily_layout
      @daily_layout = DayCalendarViewLayout.new
    end


    def change_layout
      @layout_kind = @layout_kind == :details ? :daily : :details
      @data_src = DetailsDataSource.new
      self.collectionView.dataSource = @data_src
      update_layout
    end


    def collectionViewContentSize
      container.documentView.frameSize
    end


    def willMoveToParentViewController(vc)
      super
    end


    def updateViewConstraints
      super
    end


    def collectionView
      @collection_view ||= begin
        frame = self.view.frame
        frame.size.height -= 25
        CollectionView.with(frame: frame).tap do |clv|
          clv.autoresizingMask = NSViewHeightSizable|NSViewWidthSizable
          clv.backgroundColors = [ NSColor.clearColor ]
          clv.delegate = self
          clv.selectable = true
        end
      end
    end


    def dataSource
      @datasource ||= DetailsViewDataSource.new
    end


    def collectionView(clv, shouldSelectItemAtIndexPath:indexpath)
      true
    end


    def collectionView(clv, layout:layout, sizeForItemAtIndexPath:indexPath)
      case layout
      when StickyHeaderDaily
        NSSize.new(clv.frame.size.width - 50.0, 60.0)
      else
        NSSize.new
      end
    end


    def collectionView(clv, layout:layout, referenceSizeForHeaderInSection:section)
      case layout
      when StickyHeaderDaily then NSSize.new(50.0, 50.0)
      else
        NSSize.new
      end
    end


    def __collectionView(clv, layout:layout, referenceSizeForFooterInSection:section)
      case layout
      when StickyHeaderDaily
        NSSize.new(clv.frame.size.width - 10.0, 0.0)
      else
        NSSize.new
      end
    end


    private
    def container
      @container ||= begin
        NSScrollView.with(frame:self.view.frame) do |scrv|
          scrv.autoresizingMask = NSViewHeightSizable|NSViewWidthSizable
          scrv.documentView = collectionView
          scrv.drawsBackground = false
          scrv.scrollerStyle = NSScrollerStyleOverlay
        end
      end
    end


    def sticky_layout
      @layout ||= StickyHeaderDaily.new.tap do |instance|
        instance.sectionInset = NSEdgeInsets.with(top:0.0, left:0.0, bottom:-30.0, right:0.0)
        width = self.view.frame.size.width - 1
        section_inset = instance.sectionInset
        fixed_width = width - (section_inset.left + section_inset.right)
        instance.itemSize = CGSize.new(fixed_width, 60.0)
        instance.headerReferenceSize = NSSize.new(50.0, 60.0)
        instance.scrollDirection = NSCollectionViewScrollDirectionVertical
        instance.minimumInteritemSpacing = 2.0
        instance.minimumLineSpacing = 2.0
      end
    end
    
  end
end
