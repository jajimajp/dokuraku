; A Lisp interpreter

(defun cddr (ls) (cdr (cdr ls)))
(defun cadddr (ls) (car (cdr (cdr (cdr ls)))))

(defun iter (f ls)
  (if ls
    (progn (f (car ls)) (iter f (cdr ls)))
    nil))

(defun zip (a b)
  (if a
    (let ((carb (if b (car b) nil))
          (cdrb (if b (cdr b) nil)))
      (cons
        (cons (car a) carb)
        (zip (cdr a) cdrb)))
    nil))

(defun digitp (c)
  (cond ((char= c #\0) t)
        ((char= c #\1) t)
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
  (cond ((char= c #\0) 0)
        ((char= c #\1) 1)
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

(defun parse-char ()
  (progn ; must be at '#'
    (read-next) ; must be at '\'
    (read-next) ; must be at the character
    (let ((c *input-char*))
      (progn
        (read-next)
        c))))

(defun read ()
  (progn
    (skip-spaces)
    (cond
      ((eofp) nil)
      ((digitp *input-char*) (read-int))
      ((char= #\( *input-char*) (read-list))
      ((char= #\# *input-char*) (parse-char))
      (t (read-symbol)))))

(defun equal (a b) (= a b))
(defun lessthan (a b) (< a b))

(defun binop-to-single (f)
  (lambda (args)
    (f (car args) (cadr args))))

(defun initial-env ()
  (env:new
    (list
      (cons 't t)
      (cons '= (binop-to-single equal))
      (cons '< (binop-to-single lessthan))
      (cons 'cons (lambda (args) (cons (car args) (cadr args))))
      (cons 'car (lambda (args) (car (car args))))
      (cons 'cdr (lambda (args) (cdr (car args))))
      (cons 'write (lambda (args) (write (car args)))))
    nil))

(defun env:new (alist fallback)
  (let ((hash (make-hash-table)))
    (progn
      (iter (lambda (pair)
              (puthash (car pair) (cdr pair) hash))
            alist)
      (cons hash fallback))))
(defun env:find (sym env)
  (let ((v (gethash sym (car env))))
    (if v
      v
      (if (cdr env)
        (env:find sym (cdr env))
        nil))))
(defun env:defparameter (sym val env)
  (puthash sym val (car env)))

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
    ((characterp v) v)
    ((symbolp v) (env:find v env))
    ((consp v)
     (cond ((= 'defun (car v))
            (let ((name (cadr v))
                  (args (caddr v))
                  (body (cadddr v)))
              (let ((f (lambda (argvars)
                         (let ((newenv (env:new
                                         (zip args argvars)
                                         env)))
                           (eval newenv body)))))
                (progn (env:defparameter name f env) name))))
           ((= 'if (car v))
            (if (eval env (cadr v))
              (eval env (caddr v))
              (eval env (cadddr v))))
           ((= '+ (car v)) (sum (eval-list-elems env (cdr v))))
           ((= '- (car v))
            (- (eval env (cadr v)) (sum (eval-list-elems env (cddr v)))))
           ((= '* (car v)) (multiply (eval-list-elems env (cdr v))))
           (t (let ((args (eval-list-elems env (cdr v))))
                (apply (env:find (car v) env) (cons args nil))))))
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
