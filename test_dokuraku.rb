#!/usr/bin/env ruby

def assert(expected, input)
  command = 'ruby main.rb dokuraku.lisp'
  got = IO.popen(command, 'r+') do |io|
    io.puts input
    io.close_write
    io.read.chomp
  end
  if expected != got
    puts "`#{input}` => #{expected} expected but got #{got}"
    exit
  end
  puts "#{input} => #{expected}"
end

assert '5', '5'
assert '5', ' 5 '
assert '123', '123'
assert 'T', 't'
assert 'NIL', 'nil'
assert '3', '(+ 1 2)'
assert '10', '(+ 1 2 3 4)'
