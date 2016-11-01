class AppDelegate

  def initialize
    @popover_controller = Carendar::PopoverController.new
    @app_name ||= Carendar::AppInfo.new.name
  end


  def applicationDidFinishLaunching(notification)
    @clock = Carendar::Clock.new do |value|
      popover_controller.status_item.button.title = value
    end
  end


  # Added an application listner to close the popover when our 
  # application is not the front most application
  def applicationWillFinishLaunching(_)
    name = NSWorkspaceDidActivateApplicationNotification
    nc = NSWorkspace.sharedWorkspace.notificationCenter
    nc.addObserver(self, selector:'foremost_app_activated:', name:name, object:nil)    
  end


  # remove the notification listener if the application will terminate
  def applicationWillTerminate(_)
    @clock.cancel
    name = NSWorkspaceDidActivateApplicationNotification
    nc = NSWorkspace.sharedWorkspace.notificationCenter
    nc.removeObserver(self, name:name, object:nil)
  end


  def quit_application sender
    NSApp.terminate sender
  end


  def show_settings(sender)
    preferences_controller.showWindow(sender)
    popover_controller.close_popover(sender)
    preferences_controller.window.makeKeyWindow
    preferences_controller.window.center
  end


  def show_about_screen(sender)
    about_controller.showWindow(sender)
    popover_controller.close_popover(sender)
    about_controller.window.makeKeyWindow
    about_controller.window.center
  end


  def windowWillClose(_)
    @__prefs_window__ = nil
    @__about_window__ = nil
    NSApp.hide(nil)
  end


  private
  attr_reader :popover_controller, :app_name
  def preferences_controller
    @__prefs_window__ ||= Carendar::PreferencesWindowController.new.tap do |pc|
      pc.window.hidesOnDeactivate = true
      pc.window.delegate = self
    end
  end


  def about_controller
    @__about_window__ ||= Carendar::AboutWindowController.new.tap do |ac|
      ac.windowDidLoad
      ac.window.hidesOnDeactivate = true
      ac.window.delegate = self
    end
  end


  def foremost_app_activated(note)
    app = note.userInfo[NSWorkspaceApplicationKey]
    unless app.localizedName == app_name
      popover_controller.close_popover(app)
    end
  end

end
