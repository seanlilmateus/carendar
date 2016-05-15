class Promise

  def self.after(delay, queue=Dispatch::Queue.main)
    subject = Promise.new
    queue.after(delay) { subject.fulfill(delay) }
    subject
  end


  def catch(&block)
    self.then(nil, block.to_proc)
  end


  def on_queue(queue=Dispatch::Queue.concurrent)
    subject = Promise.new
    self.then  { |*items| queue.async { subject.fulfill(*items) } }
    .catch { |*items| queue.async { subject.reject(*items)  } } 
    subject
  end


  def on_main_queue
    on_queue(Dispatch::Queue.main)
  end

end
