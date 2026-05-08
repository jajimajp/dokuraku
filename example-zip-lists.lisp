(defparameter *list1* (list 'a 'b 'c))
(defparameter *list2* (list 1 2 3 4))

(defun zip (a b)
  (if a
    (let ((carb (if b (car b) nil))
          (cdrb (if b (cdr b) nil)))
      (cons
        (cons (car a) carb)
        (zip (cdr a) cdrb)))
    nil))

(princ (zip *list1* *list2*))
; => ((A . 1) . ((B . 2) . ((C . 3))))
