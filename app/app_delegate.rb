class AppDelegate
  def initialize
    @popover_controller = Carendar::PopoverController.new
    @app_name ||= Carendar::AppInfo.new.name
  end
  
  def applicationDidFinishLaunching(notification)
  end
  
  # Added an application listner to close the popover when our 
  # application is not the front most application
  def applicationDidFinishLaunching(_)
    name = NSWorkspaceDidDeactivateApplicationNotification
    work_space_nc = NSWorkspace.sharedWorkspace.notificationCenter
    work_space_nc.addObserver(self, selector:'foremost_app_activated:', name:name, object:nil)
  end
  
  
  # remove the notification listener if the application will terminate
  def applicationWillTerminate(_)
    name = NSWorkspaceDidActivateApplicationNotification
    work_space_nc = NSWorkspace.sharedWorkspace.notificationCenter
    work_space_nc.removeObserver(self, name:name, object:nil)
  end
  
  private
  attr_reader :popover_controller, :app_name
  
  def foremost_app_activated(note)
    app = note.userInfo[NSWorkspaceApplicationKey]
    popover_controller.hide_popover unless app.localizedName == app_name
  end
  
end
