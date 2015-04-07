module Carendar
  module StatusButtonCell
    def init
      super.tap { @activated = false }
    end
    
    def highlight(_, withFrame:frame, inView:view)
      super(@activated, frame, view)
    end  
  end
end