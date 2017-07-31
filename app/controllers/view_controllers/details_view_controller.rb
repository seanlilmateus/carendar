module Carendar
  class DetailsViewController < BaseViewController
    attr_accessor :data_source
    
    def loadView
      @data_source = DetailsDataSource.new
      self.view = container
      viewDidLoad
    end


    def viewDidLoad
      super
      collectionView.registerClass(DetailsHeaderView, 
        forSupplementaryViewOfKind: NSCollectionElementKindSectionHeader,
                    withIdentifier: DetailsHeaderView::IDENTIFIER)
    
      # collectionView.registerClass( CellSeparator,
      #   forSupplementaryViewOfKind: NSCollectionElementKindSectionFooter,
      #               withIdentifier: "Footer")

      self.view.translatesAutoresizingMaskIntoConstraints = false
      collectionView.registerClass( CollectionViewItem,
        forItemWithReuseIdentifier: CollectionViewItem::IDENTIFIER)
      
      collectionView.dataSource = self.data_source
      collectionView.collectionViewLayout = sticky_layout
      
      
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
        rect = NSRect.new([0, 0], [280.0, 250.0])
        CollectionView.with(frame: rect).tap do |clv|
          clv.autoresizingMask = NSViewHeightSizable|NSViewWidthSizable
          clv.backgroundColors = [ NSColor.clearColor ]
          clv.delegate = self
          clv.selectable = true
          clv.backgroundView = empty_view
        end
      end
    end
    alias_method :tableView, :collectionView


    def dataSource
      @datasource ||= DetailsDataSource.new
    end


    def collectionView(clv, shouldSelectItemAtIndexPath:indexpath)
      true
    end


    def empty_view
      @background ||= NSView.new.tap do |bgv|
        attr_string = NSAttributedString.alloc.initWithString(localized_string('No Events', 'No Events'), attributes:{ 
          NSForegroundColorAttributeName => NSColor.redColor,
          NSForegroundColorAttributeName => NSColor.redColor,
          NSFontAttributeName => NSFont.systemFontOfSize(20),
        })
        detail = NSTextField.labelWithAttributedString(attr_string)
                            .tap { |label| label.translatesAutoresizingMaskIntoConstraints = false }
        date = NSTextField.wrappingLabelWithString("Date Placeholder")
                          .tap do |label| 
                            label.translatesAutoresizingMaskIntoConstraints = false
                            label.font = NSFont.systemFontOfSize(18)
                            label.textColor = NSColor.disabledTextColor
                          end
        bgv.addSubview(date)
        bgv.addSubview(detail)
        NSLayoutConstraint.activateConstraints([
          detail.centerXAnchor.constraintEqualToAnchor(bgv.centerXAnchor),
          detail.centerYAnchor.constraintEqualToAnchor(bgv.centerYAnchor, constant: -30),
          date.centerXAnchor.constraintEqualToAnchor(bgv.centerXAnchor),
          date.centerYAnchor.constraintEqualToAnchor(bgv.centerYAnchor, constant: -55),
        ])
      end
    end


    def sticky_layout
      @layout ||= StickyHeaderDaily.new.tap do |instance|
        instance.sectionInset = NSEdgeInsets.with(top:0.0, left:0.0, bottom:-30.0, right:0.0)
        width = self.view.frame.size.width - 1
        section_inset = instance.sectionInset
        fixed_width = width - (section_inset.left + section_inset.right)
        instance.itemSize = CGSize.new(fixed_width, 60.0)
        instance.headerReferenceSize = NSSize.new(50.0, 50.0)
        # instance.footerReferenceSize = NSSize.new(300, 10.0)
        instance.scrollDirection = NSCollectionViewScrollDirectionVertical
        instance.minimumInteritemSpacing = 2.0
        instance.minimumLineSpacing = 2.0
      end
    end


    private
    def container
      @container ||= begin
        rect = NSRect.new([0, 0], [280.0, 250.0])
        NSScrollView.alloc.initWithFrame(rect).tap do |scrv|
          scrv.autoresizingMask = NSViewHeightSizable|NSViewWidthSizable
          scrv.documentView = self.collectionView
          scrv.drawsBackground = true
          scrv.scrollerStyle = NSScrollerStyleOverlay
        end
      end
    end


  end
end
