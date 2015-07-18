module Carendar
  class ContentViewController < BaseViewController

    def loadView
      self.view = NSView.alloc.initWithFrame([[0, 0], [280.0, 600]])
      self.view.wantsLayer = true
      self.view.extend(Layout::View)
    end
    
    def viewDidLoad
      super
      @content_view_model = ContentViewModel.new WeakRef.new(self)
      # attache the childrean Controllers
      addChildViewController calendar_view_controller
      addChildViewController events_view_controller
      # add Subviews
      self.view.addSubview calendar_view_controller.view
      self.view.addSubview events_view_controller.view
      self.view.addSubview show_current_month_button
      self.view.addSubview settings_button
      create_subviews_constraints
    end
    
    def viewDidLayout
      @content_view_model.content_loaded
    end
    
    def create_subviews_constraints
      unless @__layouted__
        calendar = calendar_view_controller.view
        table_view = events_view_controller.view
        self.view.addConstraints([
          calendar.top == self.view.leading - 160,
          calendar.centerX == self.view.centerX,
          calendar.width == self.view.width,
          
          show_current_month_button.centerX == self.view.centerX,
          show_current_month_button.top(250) == calendar.bottom + 5,
          #### Settings Button
          settings_button.centerY == show_current_month_button.centerY,
          settings_button.height == show_current_month_button.height,
          settings_button.right == self.view.right + 25,
          settings_button.width == show_current_month_button.width,
          
          table_view.centerX == self.view.centerX,
          table_view.width == self.view.width,
          table_view.top == show_current_month_button.bottom + 10,
          table_view.bottom == self.view.bottom,
          table_view.height == 250.0
        ])
        @__layouted__ = true
      end
    end
    
    # childrean Controllers
    def calendar_view_controller
      @__calendar_view_controller__ ||= CalendarController.new.tap do |instance|
        instance.view.translatesAutoresizingMaskIntoConstraints = false      
        instance.delegate = @content_view_model
        instance.view.extend(Layout::View)
      end
    end
    
    def events_view_controller
      @__events_view_controller ||= EventsViewController::new.tap do |evc|
        evc.view.translatesAutoresizingMaskIntoConstraints = false
        evc.view.extend(Layout::View)
      end
    end
    
    ## Events Fetcher Promise based
    def events_fetcher
      @__events_fetcher ||= EventsFetcher.new
    end
    
    # UI Components
    def show_current_month_button
      @show_current_month_button ||= create_button do |b|
        b.title = localized_string("Current Month", "Current Month")
        b.target = @content_view_model
        b.action = 'select_date:'
      end
    end
    
    def settings_button
      @__settings_button__ ||= create_button do |b|
        b.imagePosition = NSImageOnly
        b.buttonType = NSMomentaryChangeButton
        b.image = NSImage.imageNamed(NSImageNameActionTemplate)
         .tap { |img| img.template = true}
         .tap { |img| img.size = NSSize.new(20, 20) }
        b.bordered = false
        b.target = @content_view_model
        b.action = 'show_menu:'
      end
    end
    
    private
    def create_button
      NSButton.new.tap do |b|
        b.translatesAutoresizingMaskIntoConstraints = false
        b.bezelStyle = NSTextFieldRoundedBezel
        b.buttonType = NSMomentaryPushInButton
        yield(b) if block_given?
        b.extend(Layout::View)
      end
    end
    
  end
end
