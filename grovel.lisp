(include "qrencode.h")

(in-package #:cl-libqrencode)

(cenum (mode :define-constants t)
       ((:numeric "QR_MODE_NUM"))
       ((:alphanumeric "QR_MODE_AN"))
       ((:byte "QR_MODE_8"))
       ((:kanji "QR_MODE_KANJI"))
       ((:ECI "QR_MODE_ECI"))
       ((:fnc1-first "QR_MODE_FNC1FIRST"))
       ((:fnc1-second "QR_MODE_FNC1SECOND")))

(cenum (ec-level :define-constants t)
       ((:l "QR_ECLEVEL_L"))
       ((:m "QR_ECLEVEL_M"))
       ((:q "QR_ECLEVEL_Q"))
       ((:h "QR_ECLEVEL_H")))

(cvar ("errno" c-errno) :int :read-only t)

(cstruct qr-code "QRcode"
         (version "version" :type :int)
         (width "width" :type :int)
         (data "data" :type (:pointer :unsigned-char)))
