module Carendar
  class AutoStarter
    def self.automaticallyNotifiesObserversForKey(key)
      return false if key.isEqualToString("enabled")
      super
    end
    
    attr_accessor :enable
    def initialize(switcher)
      app_name = 'carendar-app-launcher'
      @path = "Contents/Library/LoginItems/#{app_name}.app"
      @bundle_id = "de.mateus.#{app_name}"
      switcher.target = self
      switcher.action = 'switcher_action:'
      switcher.on = enabled?
      @enable = enabled?
    end
    
    def switcher_action(sender)
      start_at_login(sender.isOn?)
      sender.on = enabled?
    end
    
    NO_ERROR = 0
    def start_at_login(flag)
      url = NSBundle.mainBundle.bundleURL.URLByAppendingPathComponent(path)
      status = LSRegisterURL(url, true)
      NSLog("Failed to LSRegisterURL '%@': %@", url, status) unless status == NO_ERROR
      NSLog("SMLoginItemSetEnabled failed!") unless SMLoginItemSetEnabled(bundle_id, flag)
      willChangeValueForKey("enabled")
      @enable = enabled?
      didChangeValueForKey("enabled")
      # error = NSError.errorWithDomain(NSOSStatusErrorDomain, code:status, userInfo:nil)
    end
    
    def enabled?
      jobs_dicts = SMCopyAllJobDictionaries(KSMDomainUserLaunchd) || []
      jobs_dicts.one? { |job| job[:Label] == bundle_id && job[:OnDemand] }
    end
    
    def starter_helper
      helper = "Contents/Library/LoginItems/carendar-app-launcher.app"
      path = NSBundle.mainBundle.bundlePath.stringByAppendingPathComponent helper
      bundle = NSBundle.bundleWithPath(path)
      login_controller = AutoStarterController.new(bundle)
    end
        
    private
    attr_reader :bundle_id, :path
  end
end