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

; Default value nil makes read-char reads from stdin.
(defparameter *input-stream* nil)
(defparameter *input-char* nil)
(defun read-next ()
  (setq *input-char* (read-char *input-stream* nil)))
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
    ; Maybe #\Newline
    (let ((c *input-char*))
      (progn
        (read-next)
        (if (char= *input-char* #\e)
          ; Determine by the 2nd character.
          ; If it is true, the rest must be 'wline'
          (progn
            (read-next) ; w
            (read-next) ; l
            (read-next) ; i
            (read-next) ; n
            (read-next) ; e
            (read-next) ; The next character
            #\Newline)
          c)))))

(defun parse-string-chars ()
  (if (eofp)
    nil
    (if (char= *input-char* #\")
      (progn (read-next) nil)
      (cons *input-char* (progn (read-next) (parse-string-chars))))))
(defun parse-string ()
  (progn ; must be on '"'
    (read-next) ; must be on the 1st character of string
    (concatenate 'string (parse-string-chars))))

(defun read ()
  (progn
    (skip-spaces)
    (cond
      ((eofp) nil)
      ((digitp *input-char*) (read-int))
      ((char= #\( *input-char*) (read-list))
      ((char= #\# *input-char*) (parse-char))
      ((char= #\" *input-char*) (parse-string))
      ((char= #\' *input-char*)
       (progn
         (read-next)
         (let ((v (read)))
           (list 'quote v))))
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
      (cons 'write (lambda (args) (write (car args))))
      (cons 'princ (lambda (args) (princ (car args))))
      (cons 'list (lambda (args) args)))
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
    ((stringp v) v)
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
           ((= 'lambda (car v))
            (let ((args (cadr v))
                  (body (caddr v)))
              (lambda (argvars)
                (let ((newenv (env:new
                                (zip args argvars)
                                env)))
                  (eval newenv body)))))
           ((= 'if (car v))
            (if (eval env (cadr v))
              (eval env (caddr v))
              (eval env (cadddr v))))
           ((= 'quote (car v)) (cadr v))
           ((= 'defparameter (car v))
            (let ((name (cadr v))
                  (val (eval env (caddr v))))
              (env:defparameter name val env)))
           ((= 'progn (car v))
            (progn
              (defparameter aux
                (lambda (ls)
                  (if ls
                    (if (cdr ls)
                      (progn
                        (eval env (car ls))
                        (aux (cdr ls)))
                      (eval env (car ls)))
                    nil)))
              (aux (cdr v))))
           ((= '+ (car v)) (sum (eval-list-elems env (cdr v))))
           ((= '- (car v))
            (- (eval env (cadr v)) (sum (eval-list-elems env (cddr v)))))
           ((= '* (car v)) (multiply (eval-list-elems env (cdr v))))
           (t (let ((args (eval-list-elems env (cdr v))))
                (if (env:find (car v) env)
                  (apply (env:find (car v) env) (cons args nil))
                  (progn (warn "eval: not found") (warn (car v))))))))
    (t nil)))

(defun print-value (v)
  (if v
    (write v)
    (princ "NIL")))

(defparameter *print-value-enabled* nil)
(defparameter *read-from-filep* nil)
(defun read-command-line-args (args)
  (if args
    (progn
      (cond ((= "--print-value" (car args))
             (setq *print-value-enabled* t))
            (t (progn
                 (setq *read-from-filep* t)
                 (setq *input-stream* (open (car args))))))
      (read-command-line-args (cdr args)))
    nil))
(read-command-line-args *command-line-arguments*)
(read-next) ; Read the first character

(defparameter env (initial-env))
(defun loop ()
  (progn
    (defparameter v (read))
    (if v
      (let ((result (eval env v)))
        (progn
          (if *print-value-enabled* (print-value result) nil)
          (loop)))
      nil)))

(loop)
