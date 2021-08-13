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
  while true
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
      return env.set(k, eval(v, env))
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
      env = let_env
      ast = a2
    when :do
        eval_ast(ast.to_ary()[1..-2], env)
        ast = ast.to_ary.last # Continue loop (TCO)
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
        ast = a3
      else
        ast = a2
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
        return Function.new(a2, env, a1.to_ary) {|*args|
            EVAL(a2, Env.new(env, a1.to_ary, args))
        }
    else
        el = eval_ast(ast, env)
        f = el.car.value
        if f.class == Function
            ast = f.ast
            env = Env.new(f.env, f.params, el.drop(1))
        else
            return f[*el.drop(1)]
        end
    end
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
