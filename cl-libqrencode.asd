;;;; cl-libqrencode.asd

(in-package #:cl-user)

(eval-when (:load-toplevel :execute)
  (asdf:operate 'asdf:load-op '#:cffi-grovel))

(asdf:defsystem #:cl-libqrencode
  :description "Common Lisp binding for QRencoder"
  :author "David Selivanov <rtmpdavid@gmail.com>"
  :license  "MIT"
  :version "0.0.1"
  :serial t
  :depends-on (#:cffi
               #:zpng)
  :components ((:file "package")
               (cffi-grovel:grovel-file "grovel")
               (:file "cl-libqrencode")))
