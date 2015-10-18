module Carendar
  class AppInfo
    def self.name
      @instance ||= new
      @instance.dictionary[KCFBundleNameKey] || @instance.dictionary['CFBundleDisplayName']
    end
    
    def initialize
      @dictionary = NSBundle.mainBundle.infoDictionary      
    end

    # Generates Application information containing version and short version
    def version
      @__version__ ||= begin
        version = dictionary['CFBundleVersion']
        short = dictionary['CFBundleShortVersionString']
        NSString.stringWithString "Version #{version} (Build #{short})"
      end
    end
    
    def copyright
      @__copyright__ ||= dictionary['NSHumanReadableCopyright']
    end
    
    def icon
      NSApp.applicationIconImage || NSImage.imageNamed('NSBonjour')
    end
    
    def name
      @__name__ ||= dictionary[KCFBundleNameKey] || dictionary['CFBundleDisplayName']
    end

    def credits
      @__credits__ ||= begin
        path = NSBundle.mainBundle.pathForResource('Credits', ofType:'rtf')
        NSAttributedString.alloc.initWithPath(path, documentAttributes:nil)
      end
    end
    
    def license
      @shows_credits = false
      @__license__ ||= begin
        path = NSBundle.mainBundle.pathForResource('LICENSE', ofType:'rtf')
        NSAttributedString.alloc.initWithPath(path, documentAttributes:nil)
      end
    end
    
    private
    attr_reader :dictionary
  end
end
