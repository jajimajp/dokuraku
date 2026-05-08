(defun loop ()
  (progn
    (defparameter c (read-char nil nil))
    (if c
      (progn
        (write-char c)
        (loop))
      nil)))

(loop)
