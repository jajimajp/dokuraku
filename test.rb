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
assert 't', '(< 1 2)'
assert 'nil', '(< 2 1)'
assert 't', '(< 1 2 3)'
assert 'nil', '(< 1 2 1)'
assert 'nil', '(> 1 2)'
assert 't', '(> 2 1)'
assert 't', '(<= 1 2 3)'
assert 'nil', '(>= 1 2 1)'
assert 't', '(== 1 1)'
assert 'nil', '(== 1 2)'
assert 't', '(== 1 1 1)'
assert 'nil', '(== 1 1 (+ 1 1))'
assert '5', '(progn (+ 1 1) (+ 2 3))'
assert '2', '(progn (defun f () (+ 1 1)) (f))'
assert '3', '(progn (defun s (x) (+ 1 x)) (s 2))'
assert '3', '(progn (defun add (x y) (+ x y)) (add 1 2))'
assert '1', '(if (< 1 2) 1 2)'
assert '2', '(if (== 1 2) 1 2)'
assert '120', '(progn (defun fact (n) (if (<= n 0) 1 (* n (fact (- n 1))))) (fact 5))'
assert '8', '(progn (defun fib (n) (if (< n 3) 1 (+ (fib (- n 1)) (fib (- n 2))))) (fib 6))'
