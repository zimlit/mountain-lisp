class List
  attr_accessor :car
  include Enumerable
  
  def initialize
    @car = nil
  end
  def append(value)
    if @car
      find_tail.cdr = Node.new(value)
    else
      @car = Node.new(value)
    end
  end
  def find_tail
    node = @car
    return node if !node.cdr
    return node if !node.cdr while (node = node.cdr)
  end
  def append_after(target, value)
    node           = find(target)
    return unless node
    old_cdr       = node.cdr
    node.cdr      = Node.new(value)
    node.cdr.cdr = old_next
  end
  def find(value)
    node = @car
    return false if !node.cdr
    return node  if node.value == value
    while (node = node.cdr)
      return node if node.value == value
    end
  end
  def delete(value)
    if @car.value == value
      @car = @car.cdr
      return
    end
    node      = find_before(value)
    node.cdr = node.cdr.next
  end
  def find_before(value)
    node = @car
    return false if !node.cdr
    return node  if node.cdr.value == value
    while (node = node.cdr)
      return node if node.cdr && node.cdr.value == value
    end
  end
  
  def print
    node = @car
    puts node
    while (node = node.cdr)
      puts node
    end
  end
  def seq()
    self
  end
  def empty?()
    @car == nil
  end

  def each(&block)
    v = @car
    while v.cdr != nil
      block.call(v.value)
      v = v.cdr
    end
    block.call(v.value)
  end
end

class Node
  attr_accessor :cdr
  attr_reader   :value
  def initialize(value)
    @value = value
    @cdr  = nil
  end
  def to_s
    "Node with value: #{@value}"
  end
end



class MountainException < StandardError
  attr_reader :data
  def initialize(data)
    @data = data
  end
end

class Atom
  attr_accessor :meta
  attr_accessor :val
  def initialize(val)
    @val = val
  end
end

class String # re-open and add seq
  def seq()
    list = List.new
    x = self.split("")
    x.each do |y|
      list.append(y)
    end
    list
  end
end
