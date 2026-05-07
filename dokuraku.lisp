; A Lisp interpreter

(defun digitp (c)
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
(read-next) ; Read the first character
(defun eofp () (not *input-char*))

(defun skip-spaces ()
  (cond
    ((eofp) nil)
    ((char= *input-char* #\ ) (progn (read-next) (skip-spaces)))
    ((char= *input-char* #\Newline) (progn (read-next) (skip-spaces)))
    (t nil)))

(defun read-int' (n)
  (progn
    (read-next)
    (if (not (eofp))
      (if (digitp *input-char*)
        (read-int' (+ (* 10 n) (char-to-number *input-char*)))
        n)
      n)))

(defun read-int ()
  (read-int' (char-to-number *input-char*)))

(defun read-symbol ()
  ; TODO: multiple characters
  (progn
    (defparameter ret (intern (string-upcase (string *input-char*))))
    (read-next)
    ret))

(defun read ()
  (progn
    (skip-spaces)
    (cond
      ((eofp) nil)
      ((digitp *input-char*) (read-int))
      (t (read-symbol)))))

(defun env:find (sym)
  ; TODO: use assoc list
  (cond
    ((= t sym) t)
    (t nil)))

(defun eval (v)
  (cond
    ((numberp v) v)
    ((symbolp v) (env:find v))
    (t nil)))

(defun loop ()
  (progn
    (defparameter v (read))
    (if v
      (progn (write (eval v)) (loop))
      nil)))

(loop)
