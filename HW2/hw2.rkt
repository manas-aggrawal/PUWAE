#lang pl 02

; Question 1
; Runs the function provided (first argument) on f(first) upto l(last)
(: sequence : (All (A) ((A -> A) A A -> (Listof A))))
(define (sequence func f l)
  (cond [(equal? f l) (cons l '())]
        [else (cons f (sequence func (func f) l))]))

(: sq : Number -> Number)
(define (sq x) (* x x))

(test (sequence add1 1 1) => '(1))
(test (sequence add1 1 5) => '(1 2 3 4 5))
(test (sequence sub1 5 1) => '(5 4 3 2 1))
(test (sequence sqrt 65536 2) => '(65536 256 16 4 2))
(test (sequence sq 2 65536) => '(2 4 16 256 65536))
(test (sequence not #f #t) => '(#f #t))

; Question 2
;; An INTSET can be a number, range or a two INTSETs.
(define-type INTSET
  [Num   Integer]
  [Range Integer Integer]
  [2Sets INTSET INTSET])

(: intset-min/max : INTSET (Integer Integer -> Boolean) -> Integer)
;; Returns the minimal or maximal value in an INTSET based on the comparator
(define (intset-min/max set comparator)
  (cases set
    [(Num n) n]
    [(Range low high) (if (comparator low high) low high)]
    [(2Sets set1 set2)
     (let ([left (intset-min/max set1 comparator)]
           [right (intset-min/max set2 comparator)])
       (if (comparator left right) left right))]))


(: intset-min : INTSET -> Integer)
;; Finds the minimal member of the given set.
(define (intset-min set) (intset-min/max set <))

(: intset-max : INTSET -> Integer)
;; Finds the maximal member of the given set.
(define (intset-max set) (intset-min/max set >))

(: intset-normalized? : INTSET -> Boolean)
;; Checks if an INTSET is normalized.
(define (intset-normalized? set)
  (cases set
    [(Num n) #t]  ; Single numbers are normalized
    [(Range low high) (< low high)]  ; Range is normalized if low < high
    [(2Sets set1 set2)
     (let ([max1 (intset-max set1)]
           [min2 (intset-min set2)])
       (and (intset-normalized? set1) ; First subset is normalized
            (intset-normalized? set2) ; Second subset is normalized
            (> (- min2 max1) 1)))]))  ; Diff bw max1 and min2 is more than 1

(test  (not (intset-normalized? (Range 3 1))))
(test  (not (intset-normalized? (2Sets (Range 1 2) (Range 3 4)))))
(test  (not (intset-normalized? (2Sets (Num 2) (Range 1 3)))))
(test  (not (intset-normalized? (2Sets (Range 1 10) (Num 10)))))
(test  (not (intset-normalized? (2Sets (Range 1 10) (Num 1)))))
(test  (not (intset-normalized? (2Sets (Range 1 10) (Num 5)))))
(test  (intset-normalized? (Num 5)))
(test  (intset-normalized? (Range 1 3)))
(test  (intset-normalized? (2Sets (Num 4) (Range 12 18))))
(test  (intset-normalized? (2Sets (Range 12 18) (Num 200))))
(test  (intset-normalized? (2Sets (Range 1 3) (Range 5 7))))
(test  (intset-normalized? (2Sets (Range 1 10) (Range 12 18))))
(test  (intset-normalized? (2Sets (Range -30 -12) (Range -10 10))))
(test  (intset-normalized? (2Sets (Range 1 3)
                                  (2Sets (Range 5 7) (Range 9 11)))))
(test  (intset-normalized? (2Sets (2Sets (Range 5 7) (Range 9 11))
                                  (Range 13 19))))
(test  (intset-normalized? (2Sets (Num 3)
                                  (2Sets (Range 5 7) (Range 9 11)))))
(test  (intset-normalized? (2Sets (2Sets (Range 5 7) (Range 9 11))
                                  (Num 20))))
(test  (intset-normalized? (2Sets (2Sets (Range 5 7) (Range 9 11))
                                  (2Sets (Range 13 15) (Range 17 19)))))

; Question 3
#|
<PAGES> ::=2Sets (Range 1 3) (2Sets (Range 5 7) (Range 9 11)))))
 <PAGE>
          | <PAGE> "," <PAGE>
<PAGE> ::= <int>
         | <int> "-" <int>
|#

(define minutes-spent 180)
