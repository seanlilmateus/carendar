module Carendar
  class BaseViewController < NSViewController
    def init
      instance = initWithNibName(nil, bundle:nil)
      loadView
      instance
    end


    def loadView
      self.view = NSView.alloc.init
      viewDidLoad
    end


    def viewDidLoad
      super
    end


    def updateViewConstraints
      super
    end

    private
    def add_child_controller(child)
      child.willMoveToParentViewController(self)
      self.addChildViewController(child)
      self.view.addSubview(child.view)
      child.didMoveToParentViewController(self)
    end
  end
end
