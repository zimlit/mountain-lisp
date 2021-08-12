require "readline"
require_relative "reader"
require_relative "printer"
require_relative "env"
require_relative "core"

$history_loaded = false
$histfile = "#{ENV['HOME']}/.mountain-history"

def _readline(prompt)
    if !$history_loaded && File.exist?($histfile)
        $history_loaded = true
        if File.readable?($histfile)
            File.readlines($histfile).each {|l| Readline::HISTORY.push(l.chomp)}
        end
    end

    if line = Readline.readline(prompt, true)
        if File.writable?($histfile)
            File.open($histfile, 'a+') {|f| f.write(line+"\n")}
        end
        return line
    else
        return nil
    end
end

def read(str)
  read_str(str)
end

def eval_ast(ast, env)
  return case ast
         when Symbol
           env.get(ast)
        when List   
          List.new ast.map{|a| eval(a, env)}
        when Vector
            Vector.new ast.map{|a| eval(a, env)}
        when Hash
            new_hm = {}
            ast.each{|k,v| new_hm[eval(k,env)] = eval(v, env)}
            new_hm        else
          ast
         end
end

def eval(ast, env)
    if not ast.is_a? List
        return eval_ast(ast, env)
    end
    if ast.empty?
        return ast
    end

    # apply list
    l = ast
    a0 = l.car.value
    case a0
    when :define
      if l.car.cdr != nil
        k = l.car.cdr.value
      else
        raise MountainException, "expect variable name"
      end
      if l.car.cdr.cdr != nil
        v = l.car.cdr.cdr.value
      else
        raise MountainException, "expect variable value"
      end
      env.set(k, eval(v, env))
    when :let
      let_env = Env.new(env)
      
      if l.car.cdr != nil
        a1 = l.car.cdr.value
      else
        raise MountainException, "expect bindings"
      end
      a1.each_slice(2) do |a, e|
        let_env.set(a, eval(e, let_env))
      end

      if l.car.cdr.cdr != nil
        a2 = l.car.cdr.cdr.value
      else
        raise MountainException, "expect in section"
      end
      eval(a2, let_env)
    when :do
      r = nil
      x = ast.drop(1)
      x.each() do |x|
        r = eval(x, env)
      end
        r
    when :if

      if l.car.cdr != nil
        a1 = l.car.cdr.value
      else
        raise MountainException, "expect condition"
      end
      
      if l.car.cdr.cdr != nil
        a2 = l.car.cdr.cdr.value
      else
        raise MountainException, "expect if block"
      end

      a3 = l.car.cdr.cdr.cdr.value
      cond = eval(a1, env)
      if not cond
        return nil if a3 == nil
        return eval(a3, env)
      else
        return eval(a2, env)
      end

    when :fn

      if l.car.cdr != nil
        a1 = l.car.cdr.value
      else
        raise MountainException, "expect args"
      end
      
      if l.car.cdr.cdr != nil
        a2 = l.car.cdr.cdr.value
      else
        raise MountainException, "expect body"
      end
        return lambda {|*args|
            eval(a2, Env.new(env, a1.to_ary(), args))
        }
    else
      el = eval_ast(ast, env)
      f = el.car.value
      f[*el.drop(1)]
    end
    end

def print(str)
  pr_str(str)
end


@repl_env = Env.new
$core_ns.each do |k, v| @repl_env.set(k, v) end

def rep(str)
  
  
  print(eval(read(str), @repl_env))
end

while line = _readline("user> ")
  begin
    puts rep(line)
  rescue MountainException => e
    if e.data == "comment"
      next
    end
    puts e.data
  rescue TypeError => e
    puts e.message
  end
end
