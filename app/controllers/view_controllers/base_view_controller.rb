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


    # Mouse events and selection
    def canBecomeKeyView
      true
    end


    def acceptsFirstResponder
      true
    end


    def becomeFirstResponder
      true
    end


    def resignFirstResponder
      true
    end


    def becomeFirstResponder
      true
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
