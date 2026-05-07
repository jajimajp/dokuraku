; An example of key-value store.

(defparameter *store*
  (list (cons 'name "Apple")
        (cons 'price 400)
        (cons 'color 'red)))

(defun assoc (ls k)
  (if ls
    (if (= (car (car ls)) k)
      (cdr (car ls))
      (assoc (cdr ls) k))))

(princ "The price of this item: ")
(princ (assoc *store* 'price))
(princ #\Newline)
