; A Lisp interpreter

(defun assoc (k ls)
  (if ls
    (if (= k (car (car ls)))
      (cdr (car ls))
      (assoc k (cdr ls)))
    nil))

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
  (setq *input-char* (read-char nil)))
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

(defun reverse' (acc ls)
  (if ls
    (reverse' (cons (car ls) acc) (cdr ls))
    acc))
(defun reverse (ls) (reverse' nil ls))
(defun read-symbol-chars-rev (acc)
  (if (eofp) acc
    (cond ((char= *input-char* #\ ) acc)
          ((char= *input-char* #\Newline) acc)
          ((char= *input-char* #\)) acc)
          (t (progn
               (defparameter c *input-char*)
               (read-next)
               (read-symbol-chars-rev (cons c acc)))))))
(defun read-symbol ()
  (progn
    (defparameter chars (reverse (read-symbol-chars-rev nil)))
    (defparameter ret (intern (string-upcase (concatenate 'string chars))))
    (read-next)
    ret))

(defun read-list-r ()
  (progn
    (skip-spaces)
    (if (char= #\) *input-char*)
      (progn (read-next) nil)
      (cons (read) (read-list-r)))))
(defun read-list ()
  (progn
    (read-next)
    (read-list-r)))

(defun read ()
  (progn
    (skip-spaces)
    (cond
      ((eofp) nil)
      ((digitp *input-char*) (read-int))
      ((char= #\( *input-char*) (read-list))
      (t (read-symbol)))))

(defun equal (a b) (= a b))
(defun lessthan (a b) (< a b))

(defun initial-env ()
  (list (cons 't t)
        (cons '= equal)
        (cons '< lessthan)
  ))
(defun env:find (sym env)
  (assoc sym env))

(defun sum (ls)
  (if ls
    (+ (car ls) (sum (cdr ls)))
    0))

(defun multiply (ls)
  (if ls
    (* (car ls) (multiply (cdr ls)))
    1))

(defun eval-list-elems (env ls)
  (if ls
    (cons (eval env (car ls)) (eval-list-elems env (cdr ls)))
    nil))

(defun eval (env v)
  (cond
    ((numberp v) v)
    ((symbolp v) (env:find v env))
    ((consp v)
     (cond ((= '+ (car v)) (sum (eval-list-elems env (cdr v))))
           ((= '* (car v)) (multiply (eval-list-elems env (cdr v))))
           (t (apply (env:find (car v) env) (eval-list-elems env (cdr v))))))
    (t nil)))

(defun print-value (v)
  (if v
    (write v)
    (princ "NIL")))

(defparameter env (initial-env))
(defun loop ()
  (progn
    (defparameter v (read))
    (if v
      (progn (print-value (eval env v)) (loop))
      nil)))

(loop)
