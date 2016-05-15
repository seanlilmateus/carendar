module Kernel
  # you could name this NSLocalizedString() for compatibility's sake
  def localized_string(*args)
    key     = args.shift
    default = args.shift || key
    NSBundle.mainBundle.localizedStringForKey(key, value:default, table:nil)
  end
  alias localized localized_string
end
