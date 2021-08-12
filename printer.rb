require_relative "types"

def pr_str(obj, print_readably=true)
  _r = print_readably
  return case obj
         when List
           "(" + obj.map{|x| pr_str(x, _r)}.join(" ") + ")"
         when Atom
           "(atom " + pr_str(obj.val, true) + ")"
        when String
            if obj[0] == "\u029e"
                ":" + obj[1..-1]
            elsif _r
                obj.inspect  # escape special characters
            else
                obj
            end
         when nil
           "nil"
         else
           obj.to_s
         end
end
