; Returns the sum of numbers in a list.

(defun sum (ls)
  (if ls
    (+ (car ls) (sum (cdr ls)))
    0))

(defparameter list (cons 1 (cons 2 (cons 3 (cons 4 nil)))))

(princ (sum list))
