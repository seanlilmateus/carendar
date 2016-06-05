module Carendar
  class ContentViewController < BaseViewController

    def loadView
      self.view = NSView.alloc.initWithFrame([[0, 0], [280.0, 600]])
      self.view.wantsLayer = true
      viewDidLoad
    end


    def viewDidLoad
      super
      @content_view_model = ContentViewModel.new WeakRef.new(self)
      # attache the childrean Controllers
      add_child_controller calendar_view_controller
      add_child_controller events_view_controller
      self.view.addSubview today_button
      self.view.addSubview settings_button
      calendar_view_controller.viewDidLoad
      create_subviews_constraints
    end


    def viewDidAppear
      super
      @content_view_model.content_loaded
    end


    def updateViewConstraints
      super
    end


    def create_subviews_constraints
      unless @__layouted__
        calendar = calendar_view_controller.view
        table_view = events_view_controller.view
        NSLayoutConstraint.activateConstraints([
          calendar.topAnchor
                  .constraintEqualToAnchor(self.view.leadingAnchor, constant:20),
          calendar.centerXAnchor.constraintEqualToAnchor(self.view.centerXAnchor),
          calendar.widthAnchor.constraintEqualToAnchor(self.view.widthAnchor),
          today_button.centerXAnchor
                      .constraintEqualToAnchor(self.view.centerXAnchor),
          today_button.topAnchor
                      .constraintEqualToAnchor(calendar.bottomAnchor, constant:5),
          
          table_view.centerXAnchor.constraintEqualToAnchor(self.view.centerXAnchor),
          table_view.widthAnchor.constraintEqualToAnchor(self.view.widthAnchor),
          table_view.topAnchor
                  .constraintEqualToAnchor(today_button.bottomAnchor, constant:10),
          table_view.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor),
          table_view.heightAnchor.constraintEqualToConstant(250.0),
          
          #### Settings Button
          settings_button.centerYAnchor
                         .constraintEqualToAnchor(today_button.centerYAnchor),
          settings_button.trailingAnchor
                .constraintEqualToAnchor(self.view.trailingAnchor, constant:-20),
        ])
        @__layouted__ = true
      end
    end


    # childrean Controllers
    def calendar_view_controller
      @__calendar_view_controller__ ||= CalendarViewController.new.tap do |instance|
        instance.delegate = @content_view_model
      end
    end


    def events_view_controller
      @__events_view_controller ||= EventsViewController::new.tap do |evc|
        evc.view.translatesAutoresizingMaskIntoConstraints = false
      end
    end


    ## Events Fetcher Promise based
    def events_fetcher
      @__events_fetcher ||= EventsFetcher.new
    end


    # UI Components
    def today_button
      @today_button ||= create_button do |b|
        b.title = localized_string("Today", "Today")
        b.target = @content_view_model
        b.action = 'select_date:'
      end
    end


    def settings_button
      @setting_button ||= NSPopUpButton.new.tap do |bt|
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.cell.arrowPosition = NSPopUpArrowAtBottom  
        bt.cell.bezelStyle = NSSmallIconButtonBezelStyle
        bt.imagePosition = NSImageOnly
        bt.cell.menu = settings_popup_menu
        bt.pullsDown = true
        bt.bordered = false
      end
    end


    private
    def settings_popup_menu
      menu = NSMenu.new
      item = NSMenuItem.alloc.initWithTitle("", action:nil, keyEquivalent:"")
      item.image = NSImage.imageNamed(NSImageNameActionTemplate).tap do |img|
        img.template = true
        img.size = NSSize.new(20, 20)
      end
      menu.insertItem(item, atIndex:0)
      
      app_name = NSApp.delegate.send(:app_name)
      items = [
        {
          title: NSString.stringWithFormat(localized_string("About %@", "About %@"), app_name),
          action: 'show_about_screen:',
          eq: '',
        },
        {
          title: "#{localized_string('Preferences', 'Preferences')} ...",
          action: 'show_settings:',
          eq: ',',
        },
        {
          title: NSString.stringWithFormat(localized_string("Quit %@", "Quit %@"), app_name),
          action: 'quit_application:',
          eq: 'q',
        }
      ]
      items.each_with_index do |h, i|
        item = NSMenuItem.alloc.initWithTitle(h[:title], action:h[:action], keyEquivalent:h[:eq])
        item.target = NSApp.delegate
        menu.insertItem(item, atIndex:i+1)
      end
      menu.insertItem(NSMenuItem.separatorItem, atIndex:3)    
      menu
    end


    def create_button
      NSButton.new.tap do |b|
        b.translatesAutoresizingMaskIntoConstraints = false
        b.bezelStyle = NSTextFieldRoundedBezel
        b.buttonType = NSMomentaryPushInButton
        yield(b) if block_given?
      end
    end

  end
end
