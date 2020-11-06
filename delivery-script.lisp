;;; Automatically generated delivery script

(in-package "CL-USER")

(load-all-patches)

;;; Load the application:
(load "/Users/art/Downloads/PING-PONG-iskhodnik/pong-6-utf8.lisp")

;; (compile-system 'ping-pong-system :load t)

;;; Load the exmaple file that defines WRITE-MACOS-APPLICATION-BUNDLE
;;; to create the bundle.
(compile-file (sys:example-file "configuration/macos-application-bundle.lisp") :load t)

(deliver 'start 
         (when (save-argument-real-p)
                 (write-macos-application-bundle
                   "/Users/art/Desktop/PingPong2"))
         0
         :interface :capi)
