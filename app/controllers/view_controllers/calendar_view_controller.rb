module Carendar
  class CalendarViewController < BaseViewController
    def initWithNibName(nib, bundle:bdl)
      super.tap { @data_source = CalendarViewDataSource.new }
    end
    attr_reader :data_source, :delegate


    def loadView
      super
      self.view.addSubview(container)
      self.view.addSubview(stacker)
      self.view.nextResponder = collectionView
      container.contentInsets = NSEdgeInsets.new(0.0, 0.0, 0.0, 0.0)
      self.view.translatesAutoresizingMaskIntoConstraints = false
    end


    def viewWillLayout
      super
      @constraints ||= autolayout
      unless @constraints.all?(&:active?)
        NSLayoutConstraint.activateConstraints(@constraints) 
      end
    end


    def preferredContentSize
      NSSize.new(280.0, 295.0)
    end


    def viewDidLoad
      super
      @constraints ||= autolayout
      collectionView.registerClass( CalendarViewItem, 
             forItemWithIdentifier: CalendarViewItem::IDENTIFIER)
      collectionView.registerClass( CalendarHeader, 
        forSupplementaryViewOfKind: NSCollectionElementKindSectionHeader,  
                    withIdentifier: CalendarHeader::IDENTIFIER)
      collectionView.dataSource = data_source
      collectionView.delegate = data_source
      collectionView.collectionViewLayout = default_layout
      collectionView.delegate = self
    end


    def collectionView
      @collection_view ||= CollectionView.with(frame:NSRect.new).tap do |clv|
        clv.selectable = true
        clv.backgroundColors = [NSColor.clearColor]
        clv.backgroundColor = NSColor.clearColor
        clv.allowsMultipleSelection = false
        clv.allowsEmptySelection = true
        clv&.viewController = self
      end
    end


    def collectionView(clv, shouldSelectItemsAtIndexPaths:indexPaths)
      item = clv.itemAtIndexPath(indexPaths.allObjects.first)
      unless item.active?
        date = item.view.representedObject
        Dispatch::Queue.main.after(0.02) { select_date(date) }
      end
      indexPaths
    end


    def collectionView(clv, shouldDeselectItemsAtIndexPaths:indexPaths)
      indexPaths
    end


    def collectionView(clv, didSelectItemsAtIndexPaths:indexPaths)
      item = clv.itemAtIndexPath(indexPaths.allObjects.first)
      ldate = item.view.representedObject
      if self.delegate && self.delegate.respond_to?('didSelectDate:')
        self.delegate.didSelectDate(ldate)
      end
    end


    def collectionView(clv, didDeselectItemsAtIndexPaths:indexPaths)
      Dispatch::Queue.main.after(0.01) do
        if clv.selectionIndexPaths.count.zero?
          if self.delegate && self.delegate.respond_to?('didChangeMonth:')
            self.delegate.didChangeMonth(self.date)
          end
        end
      end
    end


    def date
      data_source.current_date
    end


    def month_changed
      if self.delegate && self.delegate.respond_to?('didChangeMonth:')
        self.delegate.didChangeMonth(date)
      end
    end


    def update_weeks(numbers)
      return unless numbers.count >= 5
      labels.zip(numbers) do |label, number|
        description = "#{number ? ("%02d" % number) : ''}"
        label.stringValue = description
        string = localized_string("Calendar Week %@", "Calendar Week %@")
        calendar_week = NSString.stringWithFormat(string, description)
        label.accessibilityLabel = calendar_week
      end
    end


    def delegate=(instance)
      @delegate = WeakRef.new(instance)
    end


    def select_date(date=NSDate.date)
      data_source.change_to_date(date)
      clv = self.collectionView
      clv.deselectAll(nil)
      item = clv.visibleItems
                .find { |i| i.view.representedObject.isInSameDayAsDate(date) }
      item.view.pulse
      indexPaths = NSSet.setWithObject(clv.indexPathForItem(item))
      clv.selectItemsAtIndexPaths(indexPaths, scrollPosition:0)
    end


    def default_layout
      @layout ||= NSCollectionViewFlowLayout.new.tap do |layout|
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        screen_width = ((self.preferredContentSize.width - 7) / 7.5 )
        layout.itemSize = NSSize.new(screen_width, screen_width)
        width = self.preferredContentSize.width
        layout.headerReferenceSize = CGSize.new(width, 65.0)
      end
    end


    def autolayout
      container.translatesAutoresizingMaskIntoConstraints = false
      stacker.translatesAutoresizingMaskIntoConstraints = false
      width = preferredContentSize.width
      [ 
        self.view.widthAnchor
            .constraintGreaterThanOrEqualToConstant(width),
        stacker.heightAnchor
               .constraintEqualToAnchor(self.view.widthAnchor, constant:-10),
        stacker.topAnchor
               .constraintEqualToAnchor(container.topAnchor, constant:93),
        stacker.rightAnchor
              .constraintEqualToAnchor(container.leftAnchor, constant:7),
        container.centerXAnchor
                 .constraintEqualToAnchor(self.view.centerXAnchor),
        container.centerYAnchor
                 .constraintEqualToAnchor(self.view.centerYAnchor),
        container.widthAnchor
                 .constraintEqualToAnchor(self.view.widthAnchor, constant: -10.0),
        container.heightAnchor
                 .constraintEqualToAnchor(self.view.heightAnchor),
      ]
    end


    def container
      @container ||= NoScrollerView.with(frame:NSRect.new).tap do |scrv|
        scrv.documentView = collectionView
        scrv.scrollerStyle = NSScrollerStyleOverlay
        scrv.borderType = NSNoBorder
        scrv.drawsBackground = false
      end
    end


    def labels 
      @labels ||= Array.new(6) do |index|
        Label.new.tap do |l| 
          l.font = NSFont.systemFontOfSize(7.5)
          l.textColor = l.textColor.colorWithAlphaComponent(0.4)
        end
      end
    end


    def stacker
      @stacker ||= NSStackView.stackViewWithViews(labels).tap do |stk|
        stk.orientation = NSUserInterfaceLayoutOrientationVertical
        stk.alignment = NSLayoutAttributeCenterX
        stk.spacing = 26.5
      end
    end

  end
end
