module Carendar
  class SettingsModel
    class << self
      def instance
        Dispatch.once { @instance ||= new }
        @instance
      end
      
      def automaticallyNotifiesObserversForKey(key)
        [DISPLAY_FORMAT].include?(key) ? false : super
      end
    end
    private_class_method :new
    
    DISPLAY_FORMAT = "current_format"
    def initialize
      format = Token::DateTokenizer.defaults
      data = NSKeyedArchiver.archivedDataWithRootObject(format)
      defaults.registerDefaults({ DISPLAY_FORMAT => data })
      defaults.synchronize
      current_format
    end
  
    def setCurrent_format(format)
      unless @current_format == format
        @current_format = format
        willChangeValueForKey('current_format')
        data = NSKeyedArchiver.archivedDataWithRootObject(format)
        defaults.setObject(data, forKey:DISPLAY_FORMAT)
        defaults.synchronize
        didChangeValueForKey('current_format')
      end
    end
    alias current_format= setCurrent_format
    
    def current_format #Array[String|DateToken]
      data = defaults.dataForKey(DISPLAY_FORMAT)
      @current_format = NSKeyedUnarchiver.unarchiveObjectWithData(data)
    end
    
    def drop(key)
      defaults.removeValueForKey(key)
    end
    
    def clear
      bundle_id = NSBundle.mainBundle.bundleIdentifier
      defaults.removePersistentDomainForName(bundle_id)
    end
    
    private
      def defaults
        NSUserDefaults.standardUserDefaults
      end
  end
end