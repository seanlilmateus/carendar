class AppDelegate
  DEST_BUNDLE_ID = "de.mateus.Carendar"
  def applicationDidFinishLaunching(notification)
    NSLog "Failed to launch #{app_name} app" unless start_app(DEST_BUNDLE_ID)
    NSApp.performSelector("terminate:", withObject: nil, afterDelay: 0.0)
  end
  
  private
  def start_app(id)
    wsp = NSWorkspace.sharedWorkspace
    return if ws.runningApplications.map(&:bundleIdentifier).include?(DEST_BUNDLE_ID)
    opts = NSWorkspaceLaunchAsync
    wsp.launchAppWithBundleIdentifier(id, options:opts, additionalEventParamDescriptor:nil, launchIdentifier:nil)
  end
end

