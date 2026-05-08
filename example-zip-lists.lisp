(defparameter *list1* (cons 'a (cons 'b (cons 'c nil))))
(defparameter *list2* (cons 1 (cons 2 (cons 3 (cons 4 nil)))))

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
