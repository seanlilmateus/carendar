module Carendar
  class AutoStarter

    def self.automaticallyNotifiesObserversForKey(key)
      return false if key.isEqualToString("enabled")
      super
    end


    def initialize(switcher)
      @bundle_id = "de.mateus.carendar-app-launcher"
      @login_item = LoginItem.new(@bundle_id)
      @login_item.valid?
      switcher.target = self
      switcher.action = 'switcher_action:'
      switcher.on = enabled?
      @enable = enabled?
    end


    def switcher_action(sender)
      start_at_login(sender.isOn?)
      sender.on = enabled?
    end


    def enabled=(flag)
      start_at_login(flag)
    end
    alias_method :setEnable, :enabled=


    NO_ERROR = 0
    def start_at_login(flag)
      willChangeValueForKey("enabled")
      @login_item.enabled = flag
      didChangeValueForKey("enabled")
    end


    def enabled?
      @login_item.enabled?
    end
    alias_method :enabled, :enabled?


    private
    attr_reader :bundle_id, :path
  end


  class LoginItem < Struct.new(:identifier)
    DEFAULTS = NSUserDefaults.standardUserDefaults
    def initialize(id)
      super
      DEFAULTS.registerDefaults({ default_key => false })
    end


    def enabled?
      DEFAULTS.boolForKey(default_key) || false
    end


    def enabled=(value)
      if SMLoginItemSetEnabled(self.identifier, value)
        willChangeValueForKey("enabled")
        DEFAULTS.setBool(value, forKey: default_key)
        DEFAULTS.synchronize
        didChangeValueForKey("enabled")
        return value
      end
      false
    end


    def valid?
      flag = (self.enabled = self.enabled?)
      return true if flag
      DEFAULTS.removeObjectForKey(default_key)
      return false
    end


    private
    def default_key
      "SMLoginItem-#{self.identifier}"
    end
  end
end
