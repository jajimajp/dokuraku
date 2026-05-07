(progn
  (defun fibonacci (n)
    (if (< n 3)
      1
      (+ (fibonacci (- n 1))
         (fibonacci (- n 2)))))

  (write (fibonacci 10)))
