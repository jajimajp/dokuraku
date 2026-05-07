; Calculates the 10th fibonacci number.

(defun fibonacci (n)
  (if (< n 3)
    1
    (+ (fibonacci (- n 1))
       (fibonacci (- n 2)))))

(write (fibonacci 10))
