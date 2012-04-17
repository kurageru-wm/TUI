(use tui)
(use srfi-42)

(define pey #f)
(define predator #f)

(define mps
  (list-ec (: i 30) (make-string 130 #\.))
  )
    

(define (chase predator pey)
  (stepch predator
          (if (> (y-of predator) (y-of pey))
              -1
              1)
          (if (> (x-of predator) (x-of pey))
              -1
              1)
          ))

(define (evade predator pey)
  (stepch predator
          (if (> (y-of predator) (y-of pey))
              1
              -1)
          (if (> (x-of predator) (x-of pey))
              1
              -1)
          :proc (lambda () (string-ref (list-ref mps (y-of pey)) (x-of pey)))
          ))


(define (main args)
  (init-tui)
  ;; (fill #\')
  (load-map mps)

  (init_pair 1 COLOR_CYAN COLOR_BLACK)
  (init_pair 2 COLOR_RED COLOR_BLACK)

  (set! pey (make <nchar> :ch #\@ :x 10 :y 10 :attr `(,A_BOLD ,(COLOR_PAIR 1))))
  (set! predator (make <nchar> :ch #\P :x 20 :y 20 :attr `(,A_BOLD ,(COLOR_PAIR 2))))

  (setch pey)
  (setch predator)

  ;; (display-info pey)
  ;; (display-info predator)

  (let loop ((c (getch))
             (proc (lambda () (string-ref (list-ref mps (y-of pey)) (x-of pey))))
             )

    ;; Pey
    (cond
     ((= (x->number #\j) c)
      (stepch pey 1 0 :proc proc))
     ((= (x->number #\k) c)
      (stepch pey -1 0 :proc proc))
     ((= (x->number #\l) c)
      (stepch pey 0 1 :proc proc))
     ((= (x->number #\h) c)
      (stepch pey 0 -1 :proc proc))
     )

    ;; Predator
    (evade predator pey)
    
    (draw-box)
    
    ;; (display-info pey)
    ;; (display-info predator)

    (unless (= (x->number #\q) c)
            (loop (getch) proc)
            )
    )

  (getch)
  (endwin)
  )


  