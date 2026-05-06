#!/usr/bin/env ruby

def assert(expected, input)
  got = `echo '#{input}' | ruby main.rb`.chomp
  if expected != got
    puts "`#{input}` => #{expected} expected but got #{got}"
    exit
  end
  puts "#{input} => #{expected}"
end

assert '13', '13'
assert '5', ' 5 '
assert '5', '(+ 3 2)'
assert '10', '(+ 1 2 3 4)'
assert '6', '(* 2 3)'
assert '14', '(+ 2 (* 3 4))'
assert '1', '(- 3 2)'
assert '-1', '(- 2 3)'
assert '-2', '(- 2)'
assert '2', '(/ 4 2)'
assert '2', '(/ 8 2 2)'
assert 't', 't'
assert 'nil', 'nil'
