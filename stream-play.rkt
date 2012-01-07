#lang racket

(require "./rsound.rkt"
         "./sequencer.rkt")

;; a stream-based sound player built on top of the sequencer.

(provide play/s
         play/s/f
         current-time/s)

;; play/s : rsound -> void
;; play a sound by queueing it for right now.
(define (play/s snd)
  (unless (rsound? snd)
    (raise-type-error 'play/s "rsound" 0 snd))
  (play/s/f snd (current-time/s)))

;; play/s/f : rsound number -> void
;; play a sound at a specified frame
(define (play/s/f snd frame)
  (unless (rsound? snd)
    (raise-type-error 'play/s/f "rsound" 0 snd frame))
  (unless (nonnegative-integer? frame)
    (raise-type-error 'play/s/f "nonnegative integer" 1 snd frame))
  (maybe-initialize)
  (queue-for-playing! sound-heap snd frame))

;; the heap of unplayed sounds
(define sound-heap (make-unplayed-heap))

;; the signal for playing the heap's sounds, and
;; the time-checker
(define-values (signal/block/unsafe current-time/s)
  (heap->signal/block/unsafe sound-heap))

;; initialize, unless it's already been started.
(define already-started? #f)
(define (maybe-initialize) 
  (when (not already-started?)
    (signal/block-play/unsafe signal/block/unsafe (default-sample-rate))
    (set! already-started? #t)))
