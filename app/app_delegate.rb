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
  
  private
  attr_reader :popover_controller, :app_name
  
  def foremost_app_activated(note)
    app = note.userInfo[NSWorkspaceApplicationKey]
    popover_controller.hide_popover unless app.localizedName == app_name
  end
  
end
