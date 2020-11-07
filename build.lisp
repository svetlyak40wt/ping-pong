(in-package "CL-USER")

(load-all-patches)

(require 'asdf)

(multiple-value-bind (path warns-p fail-p)
    (compile-file "game.lisp"
                  :load t
                  :external-format :utf-8)
  (when fail-p
    (error "Compilation Error")))


(let* ((app-path "~/Desktop/PingPong.app")
       (resources-path
         (merge-pathnames "Contents/Resources/"
                          (concatenate 'string app-path "/")))
       (bundle (create-macos-application-bundle
                app-path
                ;; Do not copy file associations...
                :document-types nil
                ;; ...or CFBundleIdentifier from the LispWorks bundle
                :identifier "com.example.PingPong")))
  (loop for file in (uiop/filesystem:directory-files "." "*.wav")
        for destination-path = (make-pathname
                                :name (pathname-name file)
                                :type (pathname-type file)
                                :defaults resources-path)
        do (uiop/stream:copy-file file destination-path))

  (deliver 'ping-pong:start 
           bundle
           ;; level of compression
           ;; from 0 to 5 where 5 is resulting the
           ;; smallest binary
           5
           :interface :capi
           ;; To suppress LispWork's splash screen
           :startup-bitmap-file nil))
