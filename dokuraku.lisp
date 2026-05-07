; A Lisp interpreter

(defun char-is-number? (c)
  (cond ((char= c #\1) t)
        ((char= c #\2) t)
        ((char= c #\3) t)
        ((char= c #\4) t)
        ((char= c #\5) t)
        ((char= c #\6) t)
        ((char= c #\7) t)
        ((char= c #\8) t)
        ((char= c #\9) t)
        (t nil)))

(defun char-to-number (c)
  (cond ((char= c #\1) 1)
        ((char= c #\2) 2)
        ((char= c #\3) 3)
        ((char= c #\4) 4)
        ((char= c #\5) 5)
        ((char= c #\6) 6)
        ((char= c #\7) 7)
        ((char= c #\8) 8)
        ((char= c #\9) 9)))

(defparameter *input-char* nil)
(defun read-next ()
  (setf *input-char* (read-char nil)))
(defun eof? () (not *input-char*))

(defun read-int' (n)
  (progn
    (read-next)
    (if (not (eof?))
      (if (char-is-number? *input-char*)
        (read-int' (+ (* 10 n) (char-to-number *input-char*)))
        n)
      n)))

(defun read-int ()
  (read-int' (char-to-number *input-char*)))

(defun loop ()
  (progn
    (read-next)
    (if (not (eof?))
      (progn
        (if (char-is-number? *input-char*) (write (read-int)) nil)
        (loop))
      nil)))

(loop)
