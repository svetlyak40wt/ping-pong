(in-package "CL-USER")

(load-all-patches)

(compile-file "pong-6-utf8.lisp"
              :load t
              :external-format :utf-8)


(ping-pong:start2)

(deliver 'ping-pong:start2 
         (create-macos-application-bundle
          "~/Desktop/PingPong.app"
          ;; Do not copy file associations...
          :document-types nil
          ;; ...or CFBundleIdentifier from the LispWorks bundle
          :identifier "com.example.PingPong")
         ;; level
         0
         :interface :capi)