; List iteration

(defparameter *list* (cons 1 (cons 2 (cons 3 (cons 4 nil)))))
(defun iter (f ls)
  (if ls
    (progn (f (car ls)) (iter f (cdr ls)))
    nil))

(iter (lambda (x) (princ (* 2 x))) *list*)
