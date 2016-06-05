class NSColor
  def self.with(attributes={})
    red   = attributes.fetch(:red, 0.0)
    green = attributes.fetch(:green, 0.0)
    blue  = attributes.fetch(:blue, 0.0)
    alpha = attributes.fetch(:alpha, 1.0)
    color = self.colorWithRed(red, green:green, blue:blue, alpha:alpha)
    yield color if block_given?
    color
  end
end
