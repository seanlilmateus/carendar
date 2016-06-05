class NSEdgeInsets
  def self.with(attributes={})
    top, left, bottom, right = [:top, :left, :bottom, :right].map do |attrs|
      attributes.fetch(attrs, 0.0)
    end
    new(top, left, bottom, right)
  end
end