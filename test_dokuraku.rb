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
assert '10', '(+ 1 2 (+ 3 4))'
assert '14', '(+ 2 (* 3 4))'
assert '2', '(- 4 2)'
assert 'T', '(= 1 1)'
assert 'NIL', '(= 1 2)'
assert 'T', '(< 1 2)'
assert 'NIL', '(< 1 1)'
assert 'F', '(defun f () (+ 1 2))'
assert 'F
13', '(defun f () 13)(f)'
assert 'SUCC
2', '(defun succ (x) (+ 1 x)) (succ 1)'
assert 'ADD
3', '(defun add (x y) (+ x y)) (add 1 2)'
assert '1', '(if t 1 2)'
assert '2', '(if nil 1 2)'
assert 'TEST
1', '(defun test (n) (if (< 0 n) 1 2)) (test 1)'
assert 'FACT
120', '(defun fact (n) (if (< 0 n) (* n (fact (- n 1))) 1)) (fact 5)'
assert '(1 . 2)', '(cons 1 2)'
