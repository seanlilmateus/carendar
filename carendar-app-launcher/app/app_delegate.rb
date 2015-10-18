class AppDelegate
  def applicationDidFinishLaunching(notification)
    id = "de.mateus.Carendar"
     NSLog "Failed to launch #{app_name} app" unless start_app(id)
    NSApp.performSelector("terminate:", withObject: nil, afterDelay: 0.0)
  end
  
  private
  def start_app(id)
    wsp = NSWorkspace.sharedWorkspace
    opts = NSWorkspaceLaunchAsync
    wsp.launchAppWithBundleIdentifier(id,
                              options:opts, 
      additionalEventParamDescriptor:nil, 
                    launchIdentifier:nil)
  end
end

