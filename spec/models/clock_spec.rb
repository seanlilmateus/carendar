describe Carendar::Clock do
  before do
    @action = Proc.new { Carendar::Clock.new }
  end
  
  it "needs an initialization block" do
    @action.should.raise(ArgumentError)
           .message.should.match(/Missing block/)
  end

  it "execute block every given seconds" do
    @value = 0
    clock = Carendar::Clock.new(0.2) { @value += 1 }      
    wait(0.6) do
      clock.cancel
      @value.should.be == 3
    end
  end
  
  it "The block should be executed on main Queue" do
    clock = Carendar::Clock.new(0.1) do
      Dispatch::Queue.current.label.should.be == "com.apple.main-thread"
    end      
    wait(0.2) { clock.cancel }    
  end
end

