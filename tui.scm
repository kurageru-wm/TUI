;;;
;;; TUI Library
;;;
;;;
;;; Copyright (C) 2012 kurageruwm <kurageruwm@gmail.com>
;;;
;;; Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation file
;;; s (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify,m 
;;; erge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnis
;;; hed to do so, subject to the following conditions:
;;;
;;; The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
;;;
;;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
;;; OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
;;; LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR 
;;; IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
;;;

(use c-wrapper)
(c-load '("ncurses.h" "stdlib.h"))

(define-module tui
  (use c-wrapper)
  (use srfi-11)
  (c-load '("ncurses.h" "stdlib.h"))
  (c-load-library "libncurses.so")  
  (export-all)
  )

(select-module tui)



(define (make-cstring size)
  (cast (ptr <c-char>) (make (c-array <c-char> size))))

;; c-wrapper$B$+$i(Bgetyx$B7O$N%^%/%m$r;H$&$H$&$^$/9T$+$J$$$N$G?7$?$KDj5A(B
(define-syntax ngetyx
  (syntax-rules ()
    ((_ win y x)
     (begin
       (set! y (getcury win))
       (set! x (getcurx win))))
    ))

(define-syntax ngetmaxyx
  (syntax-rules ()
    ((_ win y x)
     (begin
       (set! y (getmaxy win))
       (set! x (getmaxx win))))    
    ))


(define-class <nchar> ()
  ((ch :init-keyword :ch
       :init-value #\space
       :accessor char-of
       )
   (x :init-keyword :x
      :init-value 0
      :accessor x-of
      )
   (y :init-keyword :y
      :init-value 0
      :accessor y-of)
   (attr :init-keyword :attr
          :init-value '()
          :accessor attr-of)   
   ))

(define (getwinyx)
  (values
   (getmaxy stdscr)
   (getmaxx stdscr)))

(define-method getchyx ((ch <nchar>))
  (values
   (y-of ch)
   (x-of ch)))

(define-method setch ((ch <nchar>))
  (attrset (fold logior 0 (attr-of ch)))
  (mvaddch (y-of ch) (x-of ch) (x->number (char-of ch)))
  (attroff (fold logior 0 (attr-of ch)))
  )

(define-method movech ((ch <nchar>) y x . args)  
  (let-keywords args ((proc (lambda () #\space)))
                  (setch (make <nchar> :ch (proc) :x (x-of ch) :y (y-of ch)))
                  (set! (y-of ch) y)
                  (set! (x-of ch) x)
                  (setch ch)
                  )
  )

(define-method stepch ((ch <nchar>) y x . args)
  (let-keywords args ((proc (lambda () #\space)))
                  (movech ch (+ (y-of ch) y) (+ (x-of ch) x) :proc proc)))

(define (draw-box)
  (box stdscr 0 0))

(define (fill ch)
  (let-values (((y x) (getwinyx)))
    (let loop ((col 1))
      (if (= col (- y 1))
          #t
          (begin
            (mvaddstr col 1 (make-string (- x 2) ch))
            (loop (+ col 1)))
          ))))

(define (load-map mp)
  (let loop ((y 1) (rest mp))
    (if (null? rest)
        #t
        (begin
          (mvaddstr y 1 (car rest))          
          (loop (+ y 1) (cdr rest))))    
    ))


(define (init-tui)
  (initscr)
  (start_color)
  (cbreak)
  (noecho)
  (curs_set 0)
  (draw-box)
  )
  

(provide "tui")
