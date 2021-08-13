class List
  attr_accessor :car
  include Enumerable
  
  def initialize(arr)
    @car = nil

    arr.each do |y|
      self.push(y)
    end
  end
  def push(value)
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
  def push_after(target, value)
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

  def to_ary()
    x = []
    self.each do |y|
      x.push(y)
    end
    x
  end

  def each(&block)
    v = @car
    if v == nil
      return nil
    end
    while v.cdr != nil
      block.call(v.value)
      v = v.cdr
    end
    block.call(v.value)
  end

  def each_index(&block)
    v = @car
    i = 0
    if v == nil
      return nil
    end
    while v.cdr != nil
      block.call(i)
      i += 1
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

class Vector < Array
    attr_accessor :meta
    def conj(xs)
        self.push(*xs)
        return self
    end
    def seq()
        return List.new self
    end
end

class Proc # re-open and add meta
    attr_accessor :meta
end

class Function < Proc
    attr_accessor :ast
    attr_accessor :env
    attr_accessor :params
    attr_accessor :is_macro

    def initialize(ast=nil, env=nil, params=nil, &block)
        super()
        @ast = ast
        @env = env
        @params = params
        @is_macro = false
    end

    def gen_env(args)
        return Env.new(@env, @params, args)
    end
end

class Hash # re-open and add meta
    attr_accessor :meta
end

class String # re-open and add seq
  def seq()
    list = List.new self.split("")
  end
end
