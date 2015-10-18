class NSObject
  def objc_send(selector, ctypes, *args)
    signature = NSMethodSignature.signatureWithObjCTypes(ctypes)
    invocation = NSInvocation.invocationWithMethodSignature(signature)
    invocation.target, invocation.selector = self, selector
    ctypes.split(':')
          .last.split(//)
          .each_with_index do |type, index|
            arg = args[index]
            pointer = Pointer.new(type)
            pointer[0] = arg
            invocation.setArgument(pointer, atIndex:index+2)
          end
    invocation.invoke
    pointer = Pointer.new(ctypes[0, 1])
    invocation.getReturnValue(pointer)
    pointer[0]
  end
end