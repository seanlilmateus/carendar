module Carendar
  class ContentViewModel
    
    def initialize(controller)
      @controller = controller
    end
    
    def content_loaded
      controller.today_button.enabled = false
      events_for_the_month(controller.date)
      update_empty_view
    end
    
    def didChangeMonth(date)
      update_empty_view
      deselect_rows
      controller.today_button.enabled = current_month?
    end
    
    def didSelectDate(date)
      update_empty_view date_formatter.stringFromDate(date)
      if date.nil?
        didChangeMonth(calendar_controller.date)
        return
      end
      events_for_the_day(date)
    end
    
    # Buttons Actions
    def select_date(sender) # previous go to date
      controller.date = NSDate.date
      sender.enabled = false
      events_for_the_month(controller.calendar_view_controller.date)
      deselect_rows(sender)
    end
    
    def show_menu(sender)
      if sender
        app_name = NSApp.delegate.send(:app_name)
        about_string = localized_string("About %@", "About %@")
        quit_string = localized_string("Quit %@", "Quit %@")
        show_setting = localized_string("Preferences", "Preferences")
        
        menu = NSMenu.new.tap { |m| m.autoenablesItems = true }
        [
          { action: 'show_about_screen:', title: localized(about_string, app_name), eq:''},
          { action: 'show_settings:', title: show_setting, eq:','},
          { action: 'quit_application:', title: localized(quit_string, app_name), eq:'q'},
        ].each do |h|
          item = menu.addItemWithTitle(h[:title], action:h[:action], keyEquivalent:h[:eq])
          item.target = NSApp.delegate
          item.action = h[:action]
        end        
        menu.insertItem(NSMenuItem.separatorItem, atIndex:2)
        
        event = create_nsevent(sender)
        NSMenu.popUpContextMenu(menu, withEvent:event, forView:sender)
      end
    end
    
    private
    
    attr_reader :controller
    
    def current_month?
      controller.calendar_view_controller
                .view
                .subviews
                .select { |sbv| sbv.is_a?(CalendarCell) }
                .none?(&:today?)
    end
    
    def date_formatter
      # dafault short date format from somewhere???
      @__date_formatter__ ||= NSDateFormatter.new.tap do |df|
        df.timeStyle = NSDateFormatterNoStyle
        df.dateStyle = NSDateFormatterFullStyle
        df.locale = NSLocale.autoupdatingCurrentLocale
      end
    end
    
    def deselect_rows(sender=nil)
      table_view = controller.events_view_controller.tableView
      calendar = controller.calendar_view_controller.view
      calendar.subviews
              .select { |sbv| sbv.is_a?(CalendarCell) }
              .each   { |sbv| sbv.selected = false }
      table_view.deselectAll(sender)
    end
    
    def update_empty_view(date_string=controller.calendarTitle.stringValue)
      table_view = controller.events_view_controller.tableView
      table_view.date_label.stringValue = date_string
    end
    
    def events_for_the_month(date)
      events_controller = controller.events_view_controller
      controller.events_fetcher
                .events_of_the_month(date)
                .then { |items| events_controller.events = items }
                .then { events_controller.reload_data }
    end
    
    def events_for_the_day(date)
      events_controller = controller.events_view_controller
      controller.events_fetcher
                .events_of_the_day(date)
                .then { |items| events_controller.events = items }
                .then { events_controller.reload_data }
    end
    
    def create_nsevent(sender)
      point = NSPoint.new(-40, 12)
      menu_origin = sender.convertPoint(point, toView:sender.superview)      
      NSEvent.mouseEventWithType( NSLeftMouseDown,
                        location: menu_origin,
                   modifierFlags: NSLeftMouseDownMask,
                       timestamp: 1.0,
                    windowNumber: sender.window.windowNumber,
                         context: sender.window.graphicsContext,
                     eventNumber: 0,
                      clickCount: 1,
                        pressure: 1)
    end
    
  end
end
