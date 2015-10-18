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
      unless status == NO_ERROR
        NSLog("Failed to LSRegisterURL '%@': %@", url, status)
      end
      unless SMLoginItemSetEnabled(bundle_id, flag)
        NSLog("SMLoginItemSetEnabled failed!")
      end
      willChangeValueForKey("enabled")
      @enable = enabled?
      didChangeValueForKey("enabled")
    end
    
    def enabled?
      jobs_dicts = SMCopyAllJobDictionaries(KSMDomainUserLaunchd) || []
      jobs_dicts.one? { |job| job[:Label] == bundle_id && job[:OnDemand] }
    end
    
    private
    attr_reader :bundle_id, :path
  end
end