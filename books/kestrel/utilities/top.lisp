; Kestrel Utilities
;
; Copyright (C) 2016 Kestrel Institute (http://www.kestrel.edu)
;
; License: A 3-clause BSD license. See the LICENSE file distributed with ACL2.
;
; Author: Alessandro Coglio (coglio@kestrel.edu)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file provides a collection of utilities contributed by Kestrel Institute.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package "ACL2")

(include-book "acceptable-rewrite-rule-p")
(include-book "all-vars-theorems")
(include-book "applicability-conditions")
(include-book "auto-termination")
(include-book "characters")
(include-book "copy-def")
(include-book "defchoose-queries")
(include-book "define-sk")
(include-book "defthmr")
(include-book "defmacroq")
(include-book "defun-sk-queries")
(include-book "directed-untranslate")
(include-book "enumerations")
(include-book "event-forms")
(include-book "fresh-names")
(include-book "install-not-norm-event")
(include-book "integers-from-to")
(include-book "list-set-theorems")
(include-book "list-theorems")
(include-book "maybe-msgp")
(include-book "maybe-unquote")
(include-book "minimize-ruler-extenders")
(include-book "nati")
; Skipping the following, because it requires a trust tag:
; (include-book "non-ascii-pathnames" :ttags (:non-ascii-pathnames))
(include-book "numbered-names")
(include-book "oset-theorems")
(include-book "osets")
(include-book "prove-interface")
(include-book "strings")
(include-book "symbol-symbol-alists")
(include-book "symbol-true-list-alists")
(include-book "terms")
(include-book "testing")
(include-book "true-list-listp-theorems")
(include-book "typed-list-theorems")
(include-book "typed-tuples")
(include-book "ubi")
(include-book "user-interface")
(include-book "verify-guards-program")
(include-book "world-queries")
(include-book "world-theorems")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defxdoc kestrel-utilities
  :parents (kestrel-books)
  :short "A collection of utilities contributed by Kestrel Institute.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defxdoc theorems-about-non-kestrel-books
  :parents (kestrel-utilities)
  :short "Theorems about functions defined outside the Kestrel Books.")
