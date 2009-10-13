module Kernel
  
  # From http://oldrcrs.rubypal.com/rcr/show/309
  def __DIR__(offset = 0)
    (/^(.+)?:\d+/ =~ caller[offset + 1]) ? File.dirname($1) : nil
  end
  
end