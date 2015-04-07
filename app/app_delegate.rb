class AppDelegate
  def initialize
    @popover_controller = Carendar::PopoverController.new
  end
  
  def applicationDidFinishLaunching(notification)
  end
  
  attr_reader :popover_controller
end
