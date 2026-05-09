# 🌀 dokuraku = A Lisp interpreter written in Ruby + Self-hosting Lisp interpreter

## Examples

Run the interpreter:

```bash
$ ./main.rb
(princ "Hello, world!")
Hello, world!
```

Execute Lisp code:

```bash
$ ./main.rb example-fibonacci.lisp
55
```

Run the self-hosting Lisp interpreter:

```bash
$ ./main.rb dokuraku.lisp
(princ "Hello, world!")
Hello, world!
```

Verify self-hosting:

```bash
$ ./main.rb dokuraku.lisp -- dokuraku.lisp
(princ "Hello, world!")
Hello, world!
```

## Features not found in Common Lisp

### `while`

`(while <cond> <body>)` evaluates `<body>` as long as `<cond>` evaluates to a non-nil value.

```lisp
(defparameter i 0)
(while (< i 3)
  (progn (princ "Tick...")
         (write-char #\Newline)
         (setq i (+ 1 i))))
(princ "BOOM!")
```

### `warn`

`(warn <value>)` prints `<value>` to stderr.

```lisp
(warn "warning")
```

### Hash Table Manipulations

`make-hash-table`, `puthash` and `gethash` privide hash table manipulations.

```lisp
(let ((prices (make-hash-table)))
  (progn
    (puthash 'apple 100 prices)
    (puthash 'orange 100 prices)
    
    ; Price of an apple
    (princ (gethash 'apple prices))))
```
