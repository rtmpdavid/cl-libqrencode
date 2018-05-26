;;;; cl-libqrencode.lisp

(in-package #:cl-libqrencode)

(cffi:define-foreign-library libqrencode
  (:unix "libqrencode.so"))

(cffi:use-foreign-library libqrencode)

(cffi:defcfun (c-make-input "QRinput_new2") :pointer
  (version :int)
  (level ec-level))

(cffi:defcfun (c-free-input "QRinput_free") :void
  (input :pointer))

(cffi:defcfun (c-append-input "QRinput_append") :int
  (input :pointer)
  (mode mode)
  (size :int)
  (data (:pointer :unsigned-char)))

(cffi:defcfun (c-encode-input "QRcode_encodeInput") :pointer
  (input :pointer))

(cffi:defcfun (c-strerror "strerror") :string
  (errno :int))

(defun append-string-input (input string mode)
  (let ((data (cffi:foreign-string-alloc string)))
    (unwind-protect
         (progn (when (= (c-append-input input mode (length string) data) -1)
                  (let ((errno c-errno))         
                    (error (format nil "Failed to add input ~s with mode ~a: ~a"
                                   string mode (c-strerror errno))))))
      (cffi:foreign-string-free data))))

(defun append-numeric-input (text input)
  (assert (and (every #'digit-char-p text)
               (every #'(lambda (c) (< (char-code c) 255)) text)))
  (append-string-input input text :numeric))

(defun append-alphanumeric-input (text input)
  (assert (and (every #'alphanumericp text)
               (every #'(lambda (c) (< (char-code c) 255)) text)))
  (append-string-input input (string-upcase text) :alphanumeric))

(defun append-utf8-input (utf-8-text input)
  (append-string-input input utf-8-text :byte))

(defun encode (string &key (mode :alphanumeric) (ec-level :m) version)
  (let ((input (c-make-input (if version version 0) ec-level)))
    (unwind-protect
         (progn (case mode
                  (:alphanumeric (append-alphanumeric-input string input))
                  (:numeric (append-numeric-input string input))
                  (:byte (append-utf8-input string input)))
                (let ((data (c-encode-input input)))
                  (if (cffi:null-pointer-p data)
                      (error "Failed to encode data")
                      (let* ((width (cffi:foreign-slot-value data '(:struct qr-code) 'width))
                             (png (make-instance 'zpng:png
                                                 :color-type :grayscale
                                                 :width width
                                                 :height width))
                             (pixels (cffi:foreign-slot-value data '(:struct qr-code) 'data))
                             (arr (zpng:data-array png)))
                        (loop for i from 0 below width
                              do (loop for j from 0 below width
                                       for v = (cffi:mem-ref pixels :unsigned-char (+ (* i width) j))
                                       do (setf (aref arr i j 0) (if (zerop (logand v 1)) 255 0))))
                        png))))
      (c-free-input input))))

(defun write-png (string pathname &key (mode :alphanumeric) (ec-level :m) version)
  (let ((png (encode string :mode mode :ec-level ec-level :version version)))
    (zpng:write-png png pathname)))
