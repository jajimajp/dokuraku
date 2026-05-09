#!/usr/bin/env ruby

def assert(expected, input, print_value = false)
  command = 'ruby main.rb dokuraku.lisp'
  command += ' -- --print-value' if print_value
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

def assert_value(expected, input)
  assert(expected, input, true)
end

assert_value '5', '5'
assert_value '5', ' 5 '
assert_value '123', '123'
assert_value 'T', 't'
assert_value 'NIL', 'nil'
assert_value '3', '(+ 1 2)'
assert_value '10', '(+ 1 2 3 4)'
assert_value '10', '(+ 1 2 (+ 3 4))'
assert_value '14', '(+ 2 (* 3 4))'
assert_value '2', '(- 4 2)'
assert_value 'T', '(= 1 1)'
assert_value 'NIL', '(= 1 2)'
assert_value 'T', '(< 1 2)'
assert_value 'NIL', '(< 1 1)'
assert_value 'F', '(defun f () (+ 1 2))'
assert_value 'F
13', '(defun f () 13)(f)'
assert_value 'SUCC
2', '(defun succ (x) (+ 1 x)) (succ 1)'
assert_value 'ADD
3', '(defun add (x y) (+ x y)) (add 1 2)'
assert_value '1', '(if t 1 2)'
assert_value '2', '(if nil 1 2)'
assert '1', '(defun test (n) (if (< 0 n) 1 2)) (write (test 1))'
assert_value 'FACT
120', '(defun fact (n) (if (< 0 n) (* n (fact (- n 1))) 1)) (fact 5)'
assert_value '(1 . 2)', '(cons 1 2)'
assert_value '1', '(car (cons 1 2))'
assert_value '2', '(cdr (cons 1 2))'
assert '3', '(defun length (ls) (if ls (+ 1 (length (cdr ls))) 0))
             (write (length (cons 1 (cons 2 (cons 3 nil)))))'
assert '5', '(write 5)'
assert_value '#\\a', '#\\a' # escape backslash
assert_value '"str"', '"str"'
assert_value '1', '(progn (defun f () 1) (f))'
assert '5', '(defparameter v 5) (write v)'
assert '4', '(defparameter double (lambda (x) (* x 2))) (write (double 2))'
assert_value '(1 . (2 . (3)))', '(list 1 2 3)'
assert_value 'SYM', '(quote sym)'
assert_value 'SYM', '(quote SYM)'
assert_value 'SYM', '\'sym'
assert_value '#\Newline', '#\Newline'
assert 'a', '(write-char #\\a)' # escape backslash
assert_value '1', '(let ((v 1)) v)'
assert_value '1', '; comment
1'
assert '1', '(defparameter x 2) (setq x 1) (write x)'
assert '5', "(defparameter h (make-hash-table))
            (puthash 'a 5 h)
            (princ (gethash 'a h))"
assert_value '2', '(cond ((< 1 1) 1) ((= 1 1) 2) (t 3))'
assert_value 'T', '(char= #\a #\a)'
assert_value 'NIL', '(char= #\a #\z)'
assert_value 'NIL', '(not t)'
assert_value 'T', '(not nil)'
assert_value 'T', '(numberp 1)'
assert_value 'NIL', '(numberp t)'
assert_value 'T', '(symbolp t)'
assert_value 'NIL', '(symbolp 1)'
assert '3', '(defparameter i 0) (while (< i 3) (setq i (+ 1 i))) (write i)'
assert '0
1
2', '(defparameter i 0) (while (< i 3) (progn (write i) (setq i (+ 1 i))))'
assert_value '"str"', "(concatenate 'string (list #\\s #\\t #\\r))"
assert_value 'T', '(characterp #\\a)' # escaping backslash
assert_value 'NIL', '(characterp 1)'
assert_value 'T', '(stringp "str")'
assert_value 'NIL', '(stringp 1)'
assert_value '"HELLO-WORLD"', '(string-upcase "Hello-wORLD")'
assert_value 'T', '(consp (cons 1 2))'
assert_value 'NIL', '(consp 2)'
