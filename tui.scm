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
  (c-load '("ncurses.h" "stdlib.h"))
  (c-load-library "libncurses.so")  
  (export-all)
  )

(select-module tui)



(define (make-cstring size)
  (cast (ptr <c-char>) (make (c-array <c-char> size))))

;; c-wrapperからgetyx系のマクロを使うとうまく行かないので新たに定義
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
  (mvaddch (y-of ch) (x-of ch) (x->number (char-of ch))))

(define-method movech ((ch <nchar>) y x)
  (setch (make <nchar> :x (x-of ch) :y (y-of ch)))
  (set! (y-of ch) y)
  (set! (x-of ch) x)
  (setch ch)
  )

(provide "tui")

