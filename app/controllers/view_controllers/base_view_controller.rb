module Carendar
  class BaseViewController < NSViewController

    def init
      initWithNibName(nil, bundle:nil)
    end


    def loadView
      self.view = NSView.alloc.init
    end


    def viewDidLoad
      super
    end


    def updateViewConstraints
      super
    end

  end
end
