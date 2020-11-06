
; (CL-USER::START)

(in-package cl-user)

(capi:define-interface pong-game-rigt ()
    ((delay :initform 0.02)   (timer :initform nil)
     (x-movement :initform 14)  (y-movement :initform 12)
     (ball-size :initform 10)
     (computer-move :initform 16)
     (game-height :initform 400)   (game-width :initform 810)
     (slug-width :initform 10)   (slug-height :initform 45)
     (initial-slug-position :initform 140)
     (left-player-score :initform 0)  (rigt-player-score :initform 0) )
  (:menu-bar game-menu)
  (:menus
    (game-menu
      "Game"
       (("New" :callback 'play-game   :callback-type :interface    :mnemonic 1
               :enabled-function #'(lambda (self)  (with-slots (timer) self  (not timer))) )) ) )
  (:panes
   (ball capi:ellipse    :width ball-size  :height ball-size
         :graphics-args `(:foreground ,(color:make-rgb 1.0 1.0 0.0))  :filled t  )
   (ball2 capi:ellipse   :width ball-size  :height ball-size
         :graphics-args `(:foreground ,(color:make-rgb 0.9 0.9 0.0))  :filled t  )
   (ball3 capi:ellipse   :width ball-size  :height ball-size
         :graphics-args `(:foreground ,(color:make-rgb 0.75 0.75 0.0)) :filled t )
   (ball4 capi:ellipse   :width ball-size  :height ball-size
         :graphics-args `(:foreground ,(color:make-rgb 0.6 0.6 0.0))  :filled t  )
   (left-paddle capi:rectangle   :x 0  :y 0
                :visible-min-width slug-width  :visible-min-height slug-height
                :graphics-args '(:foreground :blue) :filled t   )
   (right-paddle capi:rectangle   :x (- game-width slug-width)  :y 0
                 :visible-min-width slug-width  :visible-min-height slug-height
                 :graphics-args '(:foreground :red)  :filled t  )
   (center-line capi:rectangle    :x (- (* 0.5 game-width) (* 0.25 slug-width))  :y 0
                 :visible-min-width (* 0.5 slug-width)  :visible-min-height game-height
                 :graphics-args '(:foreground :white)  :filled t   )
   (rigt-zone-vert-line capi:rectangle  :x (- (* 0.75 game-width) (* 0.25 slug-width)) :y 0
                 :visible-min-width (* 0.5 slug-width)  :visible-min-height game-height
                 :graphics-args '(:foreground :white)  :filled t   )
   (left-zone-vert-line capi:rectangle  :x (- (* 0.25 game-width) (* 0.25 slug-width)) :y 0
                 :visible-min-width (* 0.5 slug-width)  :visible-min-height game-height
                 :graphics-args '(:foreground :white)  :filled t   )
   (left-zone-horiz-line capi:rectangle  :x 0  :y (- (* 0.5 game-height) (* 0.25 slug-width))
                 :visible-min-width (* 0.25 game-width)  :visible-min-height (* 0.5 slug-width)
                 :graphics-args '(:foreground :white)  :filled t   )
   (rigt-zone-horiz-line capi:rectangle  :x (* 0.75 game-width)  :y (- (* 0.5 game-height) (* 0.25 slug-width))
                 :visible-min-width (* 0.25 game-width)  :visible-min-height (* 0.5 slug-width)
                 :graphics-args '(:foreground :white)  :filled t   )
   (left-border-line capi:rectangle      :x 0  :y 0
                 :visible-min-width (* 0.5 slug-width)  :visible-min-height game-height
                 :graphics-args '(:foreground :white)  :filled t   )
   (rigt-border-line capi:rectangle  :x (- game-width (* 0.5 slug-width))   :y 0
                 :visible-min-width (* 0.5 slug-width)  :visible-min-height game-height
                 :graphics-args '(:foreground :white)  :filled t   )
   (top-border-line capi:rectangle       :x 0  :y 0
                 :visible-min-width game-width  :visible-min-height (* 0.5 slug-width)
                 :graphics-args '(:foreground :white)  :filled t   )
   (bot-border-line capi:rectangle       :x 0  :y (- game-height (* 0.5 slug-width))
                 :visible-min-width game-width  :visible-min-height (* 0.5 slug-width)
                 :graphics-args '(:foreground :white)  :filled t   )
   (new-game-button capi:push-button
             :x 1076 :y 68 :background :red
             :text "New ball"
             :selection-callback 'play-game-rigt
             :callback-type :interface   )
   (finalize-score-button capi:push-button
             :x 555 :y 20 :background :red
             :text "Finalize score"
             :selection-callback 'finalize-score
             :callback-type :interface   )
   (left-player-title capi:output-pane
          :x 260 :y 2    :visible-min-width 300  :visible-min-height 28  :visible-border :outline
          :font (gp:make-font-description :family "Times" :size 18 :weight :bold :slant :roman)
          :foreground :midnightblue :background :grey
          :display-callback 'left-player-name-updater   )
   (rigt-player-title capi:output-pane
          :x 650 :y 2    :visible-min-width 300  :visible-min-height 28  :visible-border :outline
          :font (gp:make-font-description :family "Times" :size 18 :weight :bold :slant :roman)
          :foreground :red :background :grey
          :display-callback 'rigt-player-name-updater   )
   (left-player-score-panel capi:output-pane
          :x 250 :y 38 :visible-min-width 36  :visible-min-height 24
          :font (gp:make-font-description :family "Times" :size 16 :weight :bold :slant :roman)
          :foreground :blue :background :grey
          :title "отбитые м€чи  " :title-position :left :title-args '(:foreground :black)
          :title-font (gp:make-font-description :family "Times" :size 14 :weight :bold :slant :roman)
          :display-callback 'left-player-score-counter   )
   (rigt-player-score-panel capi:output-pane
          :x 790 :y 38    :visible-min-width 36  :visible-min-height 24
          :font (gp:make-font-description :family "Times" :size 16 :weight :bold :slant :roman)
          :foreground :blue :background :grey
          :title "  отбитые м€чи" :title-position :right :title-args '(:foreground :black)
          :title-font (gp:make-font-description :family "Times" :size 14 :weight :bold :slant :roman)
          :display-callback 'rigt-player-score-counter   )
   (left-player-neprinyat-balls-panel capi:output-pane
          :x 199 :y 68 :visible-min-width 36  :visible-min-height 24
          :font (gp:make-font-description :family "Times" :size 16 :weight :bold :slant :roman)
          :foreground :blue :background :grey
          :title "неприн€тые подачи  " :title-position :left :title-args '(:foreground :black)
          :title-font (gp:make-font-description :family "Times" :size 14 :weight :bold :slant :roman)
          :display-callback 'left-player-neprinyat-balls-counter   )
   (rigt-player-vyigrannye-balls-panel capi:output-pane
          :x 790 :y 68 :visible-min-width 36  :visible-min-height 24
          :font (gp:make-font-description :family "Times" :size 16 :weight :bold :slant :roman)
          :foreground :blue :background :grey
          :title " <<выигранные>> подачи" :title-position :right :title-args '(:foreground :black)
          :title-font (gp:make-font-description :family "Times" :size 14 :weight :bold :slant :roman)
          :display-callback 'rigt-player-vyigrannye-balls-counter   )
   (left-player-itog-score-panel  capi:output-pane
          :x 500 :y 44 :visible-min-width 80  :visible-min-height 44
          :font (gp:make-font-description :family "Times" :size 30 :weight :bold :slant :roman)
          :foreground :blue :background :grey
          :display-callback 'left-player-itog-score-counter   )
   (rigt-player-itog-score-panel  capi:output-pane
          :x 628 :y 44 :visible-min-width 80  :visible-min-height 44
          :font (gp:make-font-description :family "Times" :size 30 :weight :bold :slant :roman)
          :foreground :red :background :grey
          :display-callback 'rigt-player-itog-score-counter   )
  )
  (:layouts
   (main-layout capi:column-layout
               '(top-area game bot-area)
               :visible-min-width (* 1.5 game-width)  :gap 0   )
   (top-area capi:pinboard-layout
              '(left-player-title left-player-score-panel left-player-neprinyat-balls-panel
                rigt-player-title rigt-player-score-panel rigt-player-vyigrannye-balls-panel
                left-player-itog-score-panel rigt-player-itog-score-panel
                new-game-button)
              :background :deepskyblue2
              :visible-min-height 100 )
   (bot-area capi:pinboard-layout
              '(finalize-score-button) :background :deepskyblue2
                  :visible-min-height (* 0.15 game-height)   )
   (game capi:row-layout
         '(left-area board rigt-area)
         :gap 0 
         :visible-min-height game-height  :visible-min-width game-width   )
   (board capi:pinboard-layout
          '(center-line rigt-zone-vert-line rigt-zone-horiz-line left-zone-vert-line left-zone-horiz-line
            left-border-line rigt-border-line top-border-line bot-border-line
            ball4 ball3 ball2 ball left-paddle right-paddle)
          :background :darkgreen
          :input-model '(((:button-1 :motion) move-paddle-rigt))    :cursor :hand
          :draw-with-buffer t   )
   (left-area capi:pinboard-layout
              '() :background :deepskyblue2
                  :visible-min-width (* 0.25 game-width)   )
   (rigt-area capi:pinboard-layout
              '() :background :deepskyblue2
                  :visible-min-width (+ (* 0.25 game-width) 2)
                  :input-model '(((:button-1 :motion) move-paddle-rigt))    :cursor :move   )
  )
  (:default-initargs    :title "PING - PONG"    :confirm-destroy-callback 'interface-dead ) )

(defun interface-dead (self)
  (with-slots (timer) self
    (when timer (mp:unschedule-timer timer)
      (setq timer nil)))
  t)

(defun move-paddle-rigt (self x y)
  (declare (ignore x))
  (with-slots (right-paddle) (capi:element-interface self)
    (multiple-value-bind 
        (x ignore)
        (capi:pinboard-pane-position right-paddle)
      (declare (ignore ignore))
      (setf (capi:pinboard-pane-position right-paddle)
            (values x y)))))

(defun play-game-rigt (self)
 (setq s4et4ik-rozygryshey (1+ s4et4ik-rozygryshey)
 )
 (with-slots (timer x-movement ball ball2 ball3 ball4
              left-player-score-panel   rigt-player-score-panel ; !!!
              left-player-neprinyat-balls-panel  rigt-player-vyigrannye-balls-panel ; !!
              left-player-itog-score-panel   rigt-player-itog-score-panel       ; !!!!
              game-width  game-height    ) self
    (dolist (bl (list ball ball2 ball3 ball4))
      (setf (capi:pinboard-pane-position bl) (values (* 0.95 game-width) (* 0.4 game-height) )  ))
    (unless (minusp x-movement)
      (setf x-movement (- x-movement)))
    (setf timer (mp:make-timer 'make-a-pong-move-rigt self))
    (mp:schedule-timer-relative timer 0)
  (pervaya-poda4a-sound)
  (if (= flag-finalize-score 0)
   (progn
    (gp:invalidate-rectangle left-player-score-panel)
    (gp:invalidate-rectangle rigt-player-score-panel)
    (gp:invalidate-rectangle left-player-neprinyat-balls-panel)
    (gp:invalidate-rectangle rigt-player-vyigrannye-balls-panel)
    (gp:invalidate-rectangle left-player-itog-score-panel)
    (gp:invalidate-rectangle rigt-player-itog-score-panel)
   )
   (setf flag-finalize-score 0)
  )
 )
)

(defun make-a-pong-move-rigt (self)
  (unless (capi-internals:representation self)
    (with-slots (timer) self
      (when timer 
        (mp:unschedule-timer timer) ) )
    (return-from make-a-pong-move-rigt nil) )
  (capi:execute-with-interface-if-alive self 'internal-make-a-pong-move-rigt self))

(defvar *inside-pong-move* nil)

(defun internal-make-a-pong-move-rigt (self)
  (unless *inside-pong-move*
    (let ((*inside-pong-move* t))
      (catch 'finished
        (with-slots (board left-paddle right-paddle ball-size
                           slug-height slug-width 
                           timer delay x-movement y-movement
                           ball ball2 ball3 ball4 computer-move
                     left-player-score  rigt-player-score   ;    !!!
                    ) self
          (multiple-value-bind (x y)
              (capi:pinboard-pane-position ball)
            (multiple-value-bind (board-width board-height)
                (capi:simple-pane-visible-size board)
              (when (and board-width board-height) ; still on screen
                (cond ((<= slug-width x (- board-width (+ slug-width ball-size)))  t)
                      ((> x (- board-width (+ slug-width ball-size)))
                       (if (<= (nth-value 1 (capi:pinboard-pane-position right-paddle))
                               (+ y (ash ball-size -1))
                               (+ (nth-value 1 (capi:pinboard-pane-position right-paddle))
                                  slug-height))
                           (progn
                             (setf y-movement (- (random 26) 12))
                             (setf x-movement (- x-movement))
                             (setf rigt-player-score (1+ rigt-player-score)) ; ќ“Ѕ»“џ≈ м€чи ѕ–ј¬џћ игроком
  (udar-raketkoy-sound)
                           )
                           (progn 
                             (when timer
                               (mp:unschedule-timer timer))
                             (setf timer nil)
                             (throw 'finished nil)  )  )  )
                     ((> slug-width x)
                       (if (<= (nth-value 1 (capi:pinboard-pane-position left-paddle))
                               (+ y (ash ball-size -1))
                               (+ (nth-value 1 (capi:pinboard-pane-position left-paddle))
                                  slug-height))
                           (progn
                             (setf y-movement (- (random 26) 12))
                             (setf x-movement (- x-movement))
                             (setf left-player-score (1+ left-player-score)) ; ќ“Ѕ»“џ≈ м€чи Ћ≈¬џћ игроком
  (udar-raketkoy-sound)
                           )
                           (progn 
                             (mp:unschedule-timer timer)
                             (setf timer nil)
                             (throw 'finished nil) ) )  )
                     (t (setf x-movement (- x-movement))))
                (unless (<= 0 y (- board-height ball-size))
                  (setf y-movement (- y-movement)))
                (loop for (to from) in (list (list ball4 ball3)
                                             (list ball3 ball2)
                                             (list ball2 ball))
                      do (multiple-value-bind (x y)
                             (capi:pinboard-pane-position from)
                           (setf (capi:pinboard-pane-position to) (values x y))))
                (setf (capi:pinboard-pane-position ball)
                      (values (incf x x-movement)
                              (incf y y-movement)))
                (if (> x (ash board-height -1))
                    (let* ((paddle-middle (+ (nth-value 1 (capi:pinboard-pane-position left-paddle))
                                             (floor slug-height 2)))
                           (court-middle (ash (capi:simple-pane-visible-height board) -1))
                           (diff (- court-middle paddle-middle))
                           (move (+ (truncate diff 10) (- (random 14) 6))))
                           (multiple-value-bind (x y)
                               (capi:pinboard-pane-position left-paddle)
                             (setf (capi:pinboard-pane-position left-paddle)
                                   (values x (+ y move))))
                    )
                  (if (> y (nth-value 1 (capi:pinboard-pane-position left-paddle)))
                      (unless (> (+ (+ slug-height (nth-value 1 (capi:pinboard-pane-position left-paddle)))
                                    computer-move)
                                 (capi:simple-pane-visible-height board))
                        (multiple-value-bind (x y)
                            (capi:pinboard-pane-position left-paddle)
                          (setf (capi:pinboard-pane-position left-paddle)
                                (values x (+ y computer-move))))  )
                      (unless (< (- (nth-value 1 (capi:pinboard-pane-position left-paddle)) computer-move) 0) 
                        (multiple-value-bind (x y)
                            (capi:pinboard-pane-position left-paddle)
                          (setf (capi:pinboard-pane-position left-paddle)
                                (values x (- y computer-move)))) ) ) ) ) ) )
          (when timer (mp:schedule-timer-relative timer delay) ) ) ) ) ))


(defun ping-pong-rigt ()
   (setf neprinyat-podachi 0
         delta-neprinyat-podachi 0
         otbitye-poda4i-iskhodn 0
         s4et4ik-rozygryshey 0
         flag-finalize-score 0
   )
  (vvod-names-of-players)
  (capi:display (setf ekz-interf (make-instance 'pong-game-rigt)))
  (aplodisments-before-game)
)

(defun vvod-names-of-players ()
 (setf left-player-name (capi:prompt-for-string "¬ведите им€ и фамилию игрока на левой стороне"
                             :text "Rafael NADAL" )
       rigt-player-name (capi:prompt-for-string "¬ведите им€ и фамилию игрока на правой стороне"
                             :text "Novak DJOKOVIC" )))

(defun rigt-player-score-counter (pane x y width height)
 (gp:draw-string pane (princ-to-string (slot-value ekz-interf 'rigt-player-score)) (+ x 2) (+ y 19))
)

(defun left-player-score-counter (pane x y width height)
 (gp:draw-string pane (princ-to-string (slot-value ekz-interf 'left-player-score)) (+ x 2) (+ y 19))
 (setq otbitye-poda4i-left (slot-value ekz-interf 'left-player-score) )
 (if (= s4et4ik-rozygryshey 0)
     (setq delta-neprinyat-podachi 0)

     (if (and (= s4et4ik-rozygryshey 1) (= otbitye-poda4i-left otbitye-poda4i-iskhodn) )
         (setq delta-neprinyat-podachi 0)

         (if (and (= s4et4ik-rozygryshey 1) (> otbitye-poda4i-left otbitye-poda4i-iskhodn) )
             (setq delta-neprinyat-podachi 0  otbitye-poda4i-iskhodn otbitye-poda4i-left)

             (if (and (> s4et4ik-rozygryshey 1) (> otbitye-poda4i-left otbitye-poda4i-iskhodn) )
                 (setq delta-neprinyat-podachi 0  otbitye-poda4i-iskhodn otbitye-poda4i-left)

                 (if (and (> s4et4ik-rozygryshey 1) (= otbitye-poda4i-left otbitye-poda4i-iskhodn) )
                     (setq delta-neprinyat-podachi 1)  )  ) ) ) ) )

(defun left-player-neprinyat-balls-counter (pane x y width height)
 (gp:draw-string pane (princ-to-string (setq neprinyat-podachi (+ neprinyat-podachi delta-neprinyat-podachi))) (+ x 2) (+ y 19))
)

(defun rigt-player-vyigrannye-balls-counter (pane x y width height)
 (gp:draw-string pane (princ-to-string neprinyat-podachi) (+ x 2) (+ y 19))
)

(defun left-player-name-updater (pane x y width height)
  (gp:draw-string pane left-player-name (+ x 4) (+ y 22)))

(defun rigt-player-name-updater (pane x y width height)
  (gp:draw-string pane rigt-player-name (+ x 4) (+ y 22)))

(defun left-player-itog-score-counter (pane x y width height)
 (gp:draw-string pane (princ-to-string (slot-value ekz-interf 'left-player-score)) (+ x 6) (+ y 37)))

(defun rigt-player-itog-score-counter (pane x y width height)
 (gp:draw-string pane (princ-to-string (+ (slot-value ekz-interf 'rigt-player-score) neprinyat-podachi)) (+ x 6) (+ y 37)))

(defun aplodisments-before-game ()
  (setq pathname-aplodisments-before-game "D:/PING-PONG/aplodisments.wav"
        lo-sound-aplodisments-before-game (capi:load-sound pathname-aplodisments-before-game :owner ekz-interf) )
  (capi:play-sound lo-sound-aplodisments-before-game) )

(defun pervaya-poda4a-sound ()
  (setq pathname-pervaya-poda4a "D:/PING-PONG/pervaya-poda4a.wav"
        lo-sound-pervaya-poda4a (capi:load-sound pathname-pervaya-poda4a :owner ekz-interf) )
  (capi:play-sound lo-sound-pervaya-poda4a) )

(defun udar-raketkoy-sound ()
  (setq pathname-udar-raketkoy "D:/PING-PONG/udar-raketkoy.wav"
        lo-sound-udar-raketkoy (capi:load-sound pathname-udar-raketkoy :owner ekz-interf) )
  (capi:play-sound lo-sound-udar-raketkoy) )

(defun left-aplodisments ()
  (setq pathname-left-aplodisments "D:/PING-PONG/left-player-aplodisments.wav"
        lo-sound-left-aplodisments (capi:load-sound pathname-left-aplodisments :owner ekz-interf) )
 (capi:play-sound lo-sound-left-aplodisments) )

(defun finalize-score (self)
  (with-slots (left-player-score-panel rigt-player-score-panel
               left-player-neprinyat-balls-panel rigt-player-vyigrannye-balls-panel
               left-player-itog-score-panel rigt-player-itog-score-panel ) self
   (if (= flag-finalize-score 0)
    (progn
     (gp:invalidate-rectangle left-player-score-panel)
     (gp:invalidate-rectangle rigt-player-score-panel)
     (gp:invalidate-rectangle left-player-neprinyat-balls-panel)
     (gp:invalidate-rectangle rigt-player-vyigrannye-balls-panel)
     (gp:invalidate-rectangle left-player-itog-score-panel)
     (gp:invalidate-rectangle rigt-player-itog-score-panel)
     (left-aplodisments)
     (setf flag-finalize-score 1)
    ))))






(capi:define-interface pong-game-left ()
    ((delay :initform 0.02)   (timer :initform nil)
     (x-movement :initform 14)  (y-movement :initform 12)
     (ball-size :initform 10)
     (computer-move :initform 16)
     (game-height :initform 400)   (game-width :initform 810)
     (slug-width :initform 10)   (slug-height :initform 45) ; 30)
     (initial-slug-position :initform 140)
     (left-player-score :initform 0)  (rigt-player-score :initform 0)  ; !!!
    )
  (:menu-bar game-menu)
  (:menus
    (game-menu "Game"
       (("New" :callback 'play-game   :callback-type :interface    :mnemonic 1
               :enabled-function #'(lambda (self)  (with-slots (timer) self  (not timer))) )) ) )
  (:panes
   (ball capi:ellipse    :width ball-size  :height ball-size
         :graphics-args `(:foreground ,(color:make-rgb 1.0 1.0 0.0))  :filled t )
   (ball2 capi:ellipse   :width ball-size  :height ball-size
         :graphics-args `(:foreground ,(color:make-rgb 0.9 0.9 0.0))  :filled t )
   (ball3 capi:ellipse   :width ball-size  :height ball-size
         :graphics-args `(:foreground ,(color:make-rgb 0.75 0.75 0.0)) :filled t )
   (ball4 capi:ellipse   :width ball-size  :height ball-size
         :graphics-args `(:foreground ,(color:make-rgb 0.6 0.6 0.0))  :filled t )
   (left-paddle capi:rectangle   :x 0  :y 0
                :visible-min-width slug-width  :visible-min-height slug-height
                :graphics-args '(:foreground :blue) :filled t  )
   (right-paddle capi:rectangle   :x (- game-width slug-width)  :y 0
                 :visible-min-width slug-width  :visible-min-height slug-height
                 :graphics-args '(:foreground :red)  :filled t  )
   (center-line capi:rectangle    :x (- (* 0.5 game-width) (* 0.25 slug-width))  :y 0
                 :visible-min-width (* 0.5 slug-width)  :visible-min-height game-height
                 :graphics-args '(:foreground :white)  :filled t  )
   (rigt-zone-vert-line capi:rectangle  :x (- (* 0.75 game-width) (* 0.25 slug-width)) :y 0
                 :visible-min-width (* 0.5 slug-width)  :visible-min-height game-height
                 :graphics-args '(:foreground :white)  :filled t  )
   (left-zone-vert-line capi:rectangle  :x (- (* 0.25 game-width) (* 0.25 slug-width)) :y 0
                 :visible-min-width (* 0.5 slug-width)  :visible-min-height game-height
                 :graphics-args '(:foreground :white)  :filled t  )
   (left-zone-horiz-line capi:rectangle  :x 0  :y (- (* 0.5 game-height) (* 0.25 slug-width))
                 :visible-min-width (* 0.25 game-width)  :visible-min-height (* 0.5 slug-width)
                 :graphics-args '(:foreground :white)  :filled t  )
   (rigt-zone-horiz-line capi:rectangle  :x (* 0.75 game-width)  :y (- (* 0.5 game-height) (* 0.25 slug-width))
                 :visible-min-width (* 0.25 game-width)  :visible-min-height (* 0.5 slug-width)
                 :graphics-args '(:foreground :white)  :filled t  )
   (left-border-line capi:rectangle      :x 0  :y 0
                 :visible-min-width (* 0.5 slug-width)  :visible-min-height game-height
                 :graphics-args '(:foreground :white)  :filled t  )
   (rigt-border-line capi:rectangle  :x (- game-width (* 0.5 slug-width))   :y 0
                 :visible-min-width (* 0.5 slug-width)  :visible-min-height game-height
                 :graphics-args '(:foreground :white)  :filled t  )
   (top-border-line capi:rectangle       :x 0  :y 0
                 :visible-min-width game-width  :visible-min-height (* 0.5 slug-width)
                 :graphics-args '(:foreground :white)  :filled t  )
   (bot-border-line capi:rectangle       :x 0  :y (- game-height (* 0.5 slug-width))
                 :visible-min-width game-width  :visible-min-height (* 0.5 slug-width)
                 :graphics-args '(:foreground :white)  :filled t  )
   (new-game-button capi:push-button
             :x 115 :y 68 :background :red  ; !!!
             :text "New ball" :mnemonic 4
             :selection-callback 'play-game-left
             :callback-type :interface  )
   (finalize-score-button capi:push-button
             :x 555 :y 20 :background :red
             :text "Finalize score"
             :selection-callback 'finalize-score
             :callback-type :interface  )
   (left-player-title capi:output-pane
          :x 260 :y 2    :visible-min-width 300  :visible-min-height 28  :visible-border :outline
          :font (gp:make-font-description :family "Times" :size 18 :weight :bold :slant :roman)
          :foreground :midnightblue :background :grey
          :display-callback 'left-player-name-updater  )
   (rigt-player-title capi:output-pane
          :x 650 :y 2    :visible-min-width 300  :visible-min-height 28  :visible-border :outline
          :font (gp:make-font-description :family "Times" :size 18 :weight :bold :slant :roman)
          :foreground :red :background :grey
          :display-callback 'rigt-player-name-updater  )
   (left-player-score-panel capi:output-pane
          :x 250 :y 38 :visible-min-width 36  :visible-min-height 24
          :font (gp:make-font-description :family "Times" :size 16 :weight :bold :slant :roman)
          :foreground :blue :background :grey
          :title "отбитые м€чи  " :title-position :left :title-args '(:foreground :black)
          :title-font (gp:make-font-description :family "Times" :size 14 :weight :bold :slant :roman)
          :display-callback 'left-player-score-counter  )
   (rigt-player-score-panel capi:output-pane
          :x 790 :y 38    :visible-min-width 36  :visible-min-height 24
          :font (gp:make-font-description :family "Times" :size 16 :weight :bold :slant :roman)
          :foreground :blue :background :grey
          :title "  отбитые м€чи" :title-position :right :title-args '(:foreground :black)
          :title-font (gp:make-font-description :family "Times" :size 14 :weight :bold :slant :roman)
          :display-callback 'rigt-player-score-counter  )
   (left-player-neprinyat-balls-panel capi:output-pane
          :x 204 :y 68 :visible-min-width 36  :visible-min-height 24
          :font (gp:make-font-description :family "Times" :size 16 :weight :bold :slant :roman)
          :foreground :blue :background :grey
          :title "неприн€тые подачи " :title-position :left :title-args '(:foreground :black)
          :title-font (gp:make-font-description :family "Times" :size 14 :weight :bold :slant :roman)
          :display-callback 'left-player-neprinyat-balls-counter  )
   (rigt-player-vyigrannye-balls-panel capi:output-pane
          :x 790 :y 68 :visible-min-width 36  :visible-min-height 24
          :font (gp:make-font-description :family "Times" :size 16 :weight :bold :slant :roman)
          :foreground :blue :background :grey
          :title " <<выигранные>> подачи" :title-position :right :title-args '(:foreground :black)
          :title-font (gp:make-font-description :family "Times" :size 14 :weight :bold :slant :roman)
          :display-callback 'rigt-player-vyigrannye-balls-counter  )
   (left-player-itog-score-panel  capi:output-pane
          :x 500 :y 44 :visible-min-width 80  :visible-min-height 44
          :font (gp:make-font-description :family "Times" :size 30 :weight :bold :slant :roman)
          :foreground :blue :background :grey
          :display-callback 'left-player-itog-score-counter  )
   (rigt-player-itog-score-panel  capi:output-pane
          :x 628 :y 44 :visible-min-width 80  :visible-min-height 44
          :font (gp:make-font-description :family "Times" :size 30 :weight :bold :slant :roman)
          :foreground :red :background :grey
          :display-callback 'rigt-player-itog-score-counter  )
  )
  (:layouts
   (main-layout capi:column-layout
               '(top-area game bot-area)
               :visible-min-width (* 1.5 game-width)  :gap 0  )
   (top-area capi:pinboard-layout
              '(left-player-title left-player-score-panel left-player-neprinyat-balls-panel
                rigt-player-title rigt-player-score-panel rigt-player-vyigrannye-balls-panel
                left-player-itog-score-panel rigt-player-itog-score-panel
                new-game-button)
              :background :deepskyblue2
              :visible-min-height 100 )
   (bot-area capi:pinboard-layout
              '(finalize-score-button) :background :deepskyblue2
                  :visible-min-height (* 0.15 game-height)  )
   (game capi:row-layout
         '(left-area board rigt-area)
         :gap 0 
         :visible-min-height game-height  :visible-min-width game-width )
   (board capi:pinboard-layout
          '(center-line rigt-zone-vert-line rigt-zone-horiz-line left-zone-vert-line left-zone-horiz-line
            left-border-line rigt-border-line top-border-line bot-border-line
            ball4 ball3 ball2 ball left-paddle right-paddle)
          :background :darkgreen
          :input-model '(((:button-1 :motion) move-paddle-left))    :cursor :hand
          :draw-with-buffer t  )
   (rigt-area capi:pinboard-layout
              '() :background :deepskyblue2
                  :visible-min-width (* 0.25 game-width)   )
   (left-area capi:pinboard-layout
              '() :background :deepskyblue2
                  :visible-min-width (+ (* 0.25 game-width) 2)
                  :input-model '(((:button-1 :motion) move-paddle-left))    :cursor :move )
  )
  (:default-initargs    :title "PING - PONG"    :confirm-destroy-callback 'interface-dead )
)

(defun move-paddle-left (self x y)
  (declare (ignore x))
  (with-slots (left-paddle) (capi:element-interface self)
    (multiple-value-bind 
        (x ignore)
        (capi:pinboard-pane-position left-paddle)
      (declare (ignore ignore))
      (setf (capi:pinboard-pane-position left-paddle)
            (values x y)))))

(defun play-game-left (self)
 (setq s4et4ik-rozygryshey (1+ s4et4ik-rozygryshey)
 )
 (with-slots (timer x-movement ball ball2 ball3 ball4
              left-player-score-panel  rigt-player-score-panel ; !!!
              left-player-neprinyat-balls-panel  rigt-player-vyigrannye-balls-panel ; !!
              left-player-itog-score-panel  rigt-player-itog-score-panel       ; !!!!
              game-width  game-height    ) self
    (dolist (bl (list ball ball2 ball3 ball4))
      (setf (capi:pinboard-pane-position bl) (values (* 0.95 game-width) (* 0.4 game-height) )  ))
    (unless (plusp x-movement)
      (setf x-movement (- x-movement)))
    (setf timer (mp:make-timer 'make-a-pong-move-left self))
    (mp:schedule-timer-relative timer 0)
  (pervaya-poda4a-sound)
  (if (= flag-finalize-score 0)
   (progn
    (gp:invalidate-rectangle left-player-score-panel) ; !!!
    (gp:invalidate-rectangle rigt-player-score-panel) ; !!!
    (gp:invalidate-rectangle left-player-neprinyat-balls-panel) ; !!!
    (gp:invalidate-rectangle rigt-player-vyigrannye-balls-panel) ; !!
    (gp:invalidate-rectangle left-player-itog-score-panel)       ; !!!!
    (gp:invalidate-rectangle rigt-player-itog-score-panel)       ; !!!!
   )
   (setf flag-finalize-score 0)
  )
 )
)

(defun make-a-pong-move-left (self)
  (unless (capi-internals:representation self)
    (with-slots (timer) self
      (when timer 
        (mp:unschedule-timer timer) ) )
    (return-from make-a-pong-move-left nil) )
  (capi:execute-with-interface-if-alive self 'internal-make-a-pong-move-left self))

(defun internal-make-a-pong-move-left (self)
  (unless *inside-pong-move*
    (let ((*inside-pong-move* t))
      (catch 'finished
        (with-slots (board left-paddle right-paddle ball-size
                           slug-height slug-width 
                           timer delay x-movement y-movement
                           ball ball2 ball3 ball4 computer-move
                     left-player-score   ;                         !!!
                     rigt-player-score   ;                         !!!
                    ) self
          (multiple-value-bind (x y)
              (capi:pinboard-pane-position ball)
            (multiple-value-bind (board-width board-height)
                (capi:simple-pane-visible-size board)
              (when (and board-width board-height) ; still on screen
                (cond ((<= slug-width x (- board-width (+ slug-width ball-size)))  t)
                      ((< x slug-width)
                       (if (<= (nth-value 1 (capi:pinboard-pane-position left-paddle))
                               (+ y (ash ball-size -1))
                               (+ (nth-value 1 (capi:pinboard-pane-position left-paddle))
                                  slug-height))
                           (progn
                             (setf y-movement (- (random 26) 12))  ; 13  6
                             (setf x-movement (- x-movement))
                             (setf left-player-score (1+ left-player-score)) ; ќ“Ѕ»“џ≈ м€чи LEVYM игроком
  (udar-raketkoy-sound)
                           )
                           (progn 
                             (when timer
                               (mp:unschedule-timer timer))
                             (setf timer nil)
                             (throw 'finished nil)
                           )
                       )
                      )
                     ((> x (- board-width (+ slug-width ball-size)))
                       (if (<= (nth-value 1 (capi:pinboard-pane-position right-paddle))
                               (+ y (ash ball-size -1))
                               (+ (nth-value 1 (capi:pinboard-pane-position right-paddle))
                                  slug-height))
                           (progn
                             (setf y-movement (- (random 26) 12))   ; 13  6
                             (setf x-movement (- x-movement))
                             (setf rigt-player-score (1+ rigt-player-score)) ; ќ“Ѕ»“џ≈ м€чи PRAVYM игроком
  (udar-raketkoy-sound)
                           )
                           (progn 
                             (mp:unschedule-timer timer)
                             (setf timer nil)
                             (throw 'finished nil)
                           )
                       )
                     )
                     (t (setf x-movement (- x-movement 0))))
                (unless (<= 0 y (- board-height ball-size))
                  (setf y-movement (- y-movement)))
                (loop for (to from) in (list (list ball4 ball3)
                                             (list ball3 ball2)
                                             (list ball2 ball))
                      do (multiple-value-bind (x y)
                             (capi:pinboard-pane-position from)
                           (setf (capi:pinboard-pane-position to) (values x y))))
                (setf (capi:pinboard-pane-position ball)
                      (values (decf x x-movement)
                              (incf y y-movement)))
                (if (< x (ash (* 3 board-height) -1))
                    (let* ((paddle-middle (+ (nth-value 1 (capi:pinboard-pane-position right-paddle))
                                             (floor slug-height 2)))
                           (court-middle (ash (capi:simple-pane-visible-height board) -1))
                           (diff (- court-middle paddle-middle))
                           (move (- (truncate diff 10) (- (random 14) 6))))   ; 5   7  3
                           (multiple-value-bind (x y)
                               (capi:pinboard-pane-position right-paddle)
                             (setf (capi:pinboard-pane-position right-paddle)
                                   (values x (+ y move))))
                    )
                  (if (> y (nth-value 1 (capi:pinboard-pane-position right-paddle)))
                      (unless (> (+ (+ slug-height (nth-value 1 (capi:pinboard-pane-position right-paddle)))
                                    computer-move)
                                 (capi:simple-pane-visible-height board))
                        (multiple-value-bind (x y)
                            (capi:pinboard-pane-position right-paddle)
                          (setf (capi:pinboard-pane-position right-paddle)
                                (values x (+ y computer-move))))
                      )
                      (unless (< (- (nth-value 1 (capi:pinboard-pane-position left-paddle)) computer-move) 0)
                        (multiple-value-bind (x y)
                            (capi:pinboard-pane-position right-paddle)
                          (setf (capi:pinboard-pane-position right-paddle)
                                (values x (- y computer-move)))) ) ) ) ) ) )
          (when timer (mp:schedule-timer-relative timer delay) ) ) ) ) ))


(defun ping-pong-left ()
   (setf neprinyat-podachi 0
         delta-neprinyat-podachi 0
         otbitye-poda4i-iskhodn 0
         s4et4ik-rozygryshey 0
         flag-finalize-score 0
   )
  (vvod-names-of-players)
  (capi:display (setf ekz-interf (make-instance 'pong-game-left)))
  (aplodisments-before-game)
)


(defun start ()
 (setf active-player (capi:prompt-for-string
"≈сли хотите играть за левую сторону, введите L, иначе - нажмите любую другую клавишу" :text "L" )
 )
 (if (string= active-player "L") (ping-pong-left) (ping-pong-rigt))
)