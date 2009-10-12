module Eoraptor
  
  Hooks = Hash.new do |h, klass|
    h[klass] = Hash.new { |h1, name| h1[name] = [] }
  end
  
  def Hooks.invoke!(obj, name)
    self[obj][name].each { |b| b.call }
  end
  
end

Object.class_eval do
  def define_hooks(*args)
    args.each do |hook|
      hook = hook.to_sym
      class_eval(<<-END, __FILE__, __LINE__)
        def #{hook}(&blk)
          Eoraptor::Hooks[self][#{hook.inspect}] << blk
        end
      END
    end
  end
end