module Carendar
  class AppInfo
    
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
    
    def acknowledgements
      @__acknowledgements__ ||= begin
        #path = NSBundle.mainBundle.pathForResource('Acknowledgements', ofType:'rtf')
        #NSAttributedString.alloc.initWithPath(path, documentAttributes:nil)
        NSString.string
      end
    end
    
    def webpage
      @__webpage__ ||= "Visit the #{self.name} Website"
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
    
    private
    attr_reader :dictionary
  end
end