#!/usr/bin/env ruby

def assert(expected, input)
  got = `echo #{input} | ruby main.rb`.chomp
  if expected != got
    puts "`#{input}` => #{expected} expected but got #{got}"
    exit
  end
  puts "#{input} => #{expected}"
end

assert '13', '13'
