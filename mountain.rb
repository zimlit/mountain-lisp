require "readline"
require_relative "reader"
require_relative "printer"

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
           raise "'" + ast.to_s + "' not found" if not env.key? ast
           env[ast]
        when List   
          list = List.new
          x = ast.map{|a| eval(a, env)}
          x.each do |y|
            list.append(y)
          end
          list
        else
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
    el = eval_ast(ast, env)
    f = el.car.value
    return f[*el.drop(1)]
end

def print(str)
  pr_str(str)
end


def rep(str)
  
repl_env = {}
repl_env[:+] = lambda {|a,b| a + b}
repl_env[:-] = lambda {|a,b| a - b}
repl_env[:*] = lambda {|a,b| a * b}
repl_env[:/] = lambda {|a,b| a / b}
  print(eval(read(str), repl_env))
end

while line = _readline("user> ")
  begin
    puts rep(line)
  rescue MountainException => e
    if e.data == "comment"
      next
    end
    puts e.data
  end
end
