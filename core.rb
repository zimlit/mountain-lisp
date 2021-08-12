require "readline"
require_relative "reader"
require_relative "printer"

$core_ns = {
  :+        => lambda {|a,b| a + b},
  :-        => lambda {|a,b| a - b},
  :*        => lambda {|a,b| a * b},
  :/        => lambda {|a,b| a / b},
  :"pr-str" => lambda {|*a| a.map {|e| pr_str(e, true)}.join(" ")},
  :str      => lambda {|*a| a.map {|e| pr_str(e, false)}.join("")},
  :prn      => lambda {|*a| puts(a.map {|e| pr_str(e, true)}.join(" "))},
  :println  => lambda {|*a| puts(a.map {|e| pr_str(e, false)}.join(" "))},
  :list     => lambda {|*a| List.new a},
  :list?    => lambda {|a| a.is_a? List},
  :empty?   => lambda {|a| a.car == nil},
  :count    => lambda {|a| i = 0;a.each do |x|; i += 1 end; i},
  :"="      => lambda {|a,b| a == b},
  :<        => lambda {|a,b| a < b},
  :<=       => lambda {|a,b| a <= b},
  :>        => lambda {|a,b| a > b},
  :>=       => lambda {|a,b| a >= b},
}
