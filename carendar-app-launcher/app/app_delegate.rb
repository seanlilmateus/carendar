class AppDelegate

  DEST_BUNDLE_ID = "de.mateus.Carendar"

  def applicationDidFinishLaunching(notification)
    start_app(DEST_BUNDLE_ID)
  end


  private
  def start_app(id)
    wsp = NSWorkspace.sharedWorkspace
    unless wsp.runningApplications.map(&:bundleIdentifier).include?(DEST_BUNDLE_ID)
      opts = NSWorkspaceLaunchAsync
      wsp.launchAppWithBundleIdentifier(id, options:opts, additionalEventParamDescriptor:nil,launchIdentifier:nil)
    end
    NSApp.performSelector("terminate:", withObject: nil, afterDelay: 0.0)
  end

end

