(defun map (f ls)
  (if ls
    (cons (f (car ls)) (map f (cdr ls)))
    nil))

(defun double (x) (* 2 x))

(princ (map double (list 1 2 3 4)))
