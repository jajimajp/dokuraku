(defparameter list (cons 1 (cons 2 (cons 3 (cons 4 nil)))))
(princ "List to reverse: ")
(princ list)
(write-char #\Newline)

(defun reverse' (acc ls)
  (if ls
    (reverse' (cons (car ls) acc) (cdr ls))
    acc))
(defun reverse (ls) (reverse' nil ls))

(princ "Reversed list: ")
(princ (reverse list))
(write-char #\Newline)
