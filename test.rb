#!/usr/bin/env ruby

def assert(expected, input, print_value = false)
  command = 'ruby main.rb'
  command += ' --print-value' if print_value
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

assert_value '13', '13'
assert_value '5', ' 5 '
assert_value '5', '(+ 3 2)'
assert_value '10', '(+ 1 2 3 4)'
assert_value '6', '(* 2 3)'
assert_value '14', '(+ 2 (* 3 4))'
assert_value '1', '(- 3 2)'
assert_value '-1', '(- 2 3)'
assert_value '-2', '(- 2)'
assert_value '2', '(/ 4 2)'
assert_value '2', '(/ 8 2 2)'
assert_value 'T', 't'
assert_value 'nil', 'nil'
assert_value 'T', '(< 1 2)'
assert_value 'nil', '(< 2 1)'
assert_value 'T', '(< 1 2 3)'
assert_value 'nil', '(< 1 2 1)'
assert_value 'nil', '(> 1 2)'
assert_value 'T', '(> 2 1)'
assert_value 'T', '(<= 1 2 3)'
assert_value 'nil', '(>= 1 2 1)'
assert_value 'T', '(= 1 1)'
assert_value 'nil', '(= 1 2)'
assert_value 'T', '(= 1 1 1)'
assert_value 'nil', '(= 1 1 (+ 1 1))'
assert_value '5', '(progn
  (+ 1 1)
  (+ 2 3)
)'
assert_value '2', '(progn (defun f () (+ 1 1)) (f))'
assert_value '3', '(progn (defun s (x) (+ 1 x)) (s 2))'
assert_value '3', '(progn (defun add (x y) (+ x y)) (add 1 2))'
assert_value '1', '(if (< 1 2) 1 2)'
assert_value '2', '(if (= 1 2) 1 2)'
assert_value '120', '(progn (defun fact (n) (if (<= n 0) 1 (* n (fact (- n 1))))) (fact 5))'
assert_value '8', '(progn
  (defun fib (n)
    (if (< n 3)
       1
       (+ (fib (- n 1)) (fib (- n 2)))))
  (fib 6))'
assert_value '3', '(progn
  (defparameter x 1)
  (defparameter y 2)
  (+ x y))'
assert_value '#\\a', '#\\a' # escaping backslash
assert 'a', '(write-char #\\a)' # escaping backslash
assert '#\\a', '(write #\\a)' # escaping backslash
assert '123', '(write 123)'
assert '123', '; A comment
(; Comment in a list
write 123)'
assert 'ab', '(write-char #\\a) (write-char #\\b)' # escaping backslash
assert_value '"str"', '"str"'
assert '"str"', '(write "str")'
assert 'str', '(princ "str")'
assert 'C', '(princ #\C)' # escaping backslash
assert '1', '(princ 1)'
assert_value '2', '(cond ((< 1 1) 1) ((= 1 1) 2) (t 3))'
assert_value 'T', '(char= #\a #\a)'
assert_value 'nil', '(char= #\a #\z)'
assert '1', '(defparameter *a* 2)(setq *a* 1)(write *a*)'
assert_value 'nil', '(not t)'
assert_value 'T', '(not nil)'
assert_value '#\Newline', '#\Newline'
assert "a\nb", '(write-char #\a)(write-char #\Newline)(write-char #\b)'
assert_value '(1 . 2)', '(cons 1 2)'
assert_value '(1)', '(cons 1 nil)'
assert_value '(1 . (2 . 3))', '(cons 1 (cons 2 3))'
assert_value '1', '(car (cons 1 2))'
assert_value '2', '(cdr (cons 1 2))'
assert_value 'T', '(numberp 1)'
assert_value 'nil', '(numberp t)'
assert_value 'T', '(symbolp t)'
assert_value 'nil', '(symbolp 1)'
assert_value '"HELLO-WORLD"', '(string-upcase "Hello-wORLD")'
assert_value 'SYM', '(intern "SYM")'
assert_value '"s"', '(string #\s)'
assert_value 'SYM', '(quote sym)'
assert_value 'SYM', '(quote SYM)'
assert_value 'SYM', '\'sym'
assert_value '"str"', "(concatenate 'string (cons #\\s (cons #\\t (cons #\\r nil))))"
assert_value 'T', '(consp (cons 1 2))'
assert_value 'nil', '(consp 2)'
assert_value '2', '(cadr (cons 1 (cons 2 nil)))'
assert_value '3', '(caddr (cons 1 (cons 2 (cons 3 nil))))'
assert_value '(1 . (2 . (3)))', '(list 1 2 3)'
assert '3', "(defun add (x y) (+ x y)) (princ (apply #'add (cons 1 (cons 2 nil))))"
assert '5', "(defparameter h (make-hash-table))
            (puthash 'a 5 h)
            (princ (gethash 'a h))"
assert_value '3', '(let ((x 1) (y 2)) (+ x y))'
assert '5', '(defparameter x 5) (let ((x 1) (y 2)) (+ x y)) (princ x)'
assert_value '3', '(let ((f (lambda (x) (+ x 2)))) (f 1))'
assert '(1 . 2)', '(write (cons 1 2))'
assert_value 'T', '(characterp #\\a)' # escaping backslash
assert_value 'nil', '(characterp 1)'
assert 'h', '(progn
               (defparameter *stream* (open "testdata-hello.txt"))
               (princ (read-char *stream* nil))
               (close *stream*))'
