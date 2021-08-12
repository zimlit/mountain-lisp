require_relative "types"

class Reader
    def initialize(tokens)
        @position = 0
        @tokens = tokens
    end
    def peek
        return @tokens[@position]
    end
    def next
        @position += 1
        return @tokens[@position-1]
    end
end


def tokenize(str)
    re = /[\s,]*(~@|[\[\]{}()'`~^@]|"(?:\\.|[^\\"])*"?|;.*|[^\s\[\]{}('"`,;)]*)/
    return str.scan(re).map{|m| m[0]}.select{ |t|
        t != "" && t[0..0] != ";"
    }
end

def read_str(str)
  tokens = tokenize(str)
    raise MountainException, "comment" if tokens.size == 0
  reader = Reader.new(tokens)
  read_form(reader)
end

def read_form(reader)
  case reader.peek()
  when "("
    read_list(reader)
  else
    read_atom(reader)
  end
end

def read_list(reader)
  ast = List.new
  token = reader.next()
  if token != "("
    raise MountainException, "expected '('"
  end
  while (token = reader.peek()) != ")"
    if not token
      raise MountainException, "expected ')', got EOF"
    end
    ast.append(read_form(reader))
  end
  reader.next
  return ast
end

def parse_str(t) # trim and unescape
    return t[1..-2].gsub(/\\./, {"\\\\" => "\\", "\\n" => "\n", "\\\"" => '"'})
end

def read_atom(reader)
    token = reader.next
    return case token
        when /^-?[0-9]+$/ then       token.to_i # integer
        when /^-?[0-9][0-9.]*$/ then token.to_f # float
        when /^"(?:\\.|[^\\"])*"$/ then parse_str(token) # string
        when /^"/ then               raise "expected '\"', got EOF"
        when /^:/ then               "\u029e" + token[1..-1] # keyword
        when ""   then               nil
        when "nil" then              nil
        when "true" then             true
        when "false" then            false
        else                         token.to_sym # symbol
    end
end
