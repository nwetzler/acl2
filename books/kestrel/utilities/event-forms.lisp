; Event Forms
;
; Copyright (C) 2016 Kestrel Institute (http://www.kestrel.edu)
;
; License: A 3-clause BSD license. See the LICENSE file distributed with ACL2.
;
; Author: Alessandro Coglio (coglio@kestrel.edu)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file provides shallow recognizers of event forms and lists thereof.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package "ACL2")

(include-book "std/util/deflist" :dir :system)
(include-book "std/util/defrule" :dir :system)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defxdoc event-forms
  :parents (kestrel-utilities system-utilities)
  :short "Shallow recognizers of event forms and lists thereof.")

(define pseudo-event-formp (x)
  :returns (yes/no booleanp)
  :parents (event-forms)
  :short "Recognize the basic structure of an event form."
  :long
  "<p>
   Check whether @('x') is a
   non-empty, @('nil')-terminated list that starts with a symbol
   (like a function or macro call).
   </p>
   <p>
   This is a &ldquo;shallow&rdquo; check.
   Its satisfaction does not guarantee that @('x') is a valid event form.
   </p>"
  (and x
       (true-listp x)
       (symbolp (car x)))

  ///

  (defrule pseudo-event-formp-of-cons
    (equal (pseudo-event-formp (cons a b))
           (and (symbolp a)
                (true-listp b)))))

(std::deflist pseudo-event-form-listp (x)
  (pseudo-event-formp x)
  :parents (event-forms)
  :short "Recognize @('nil')-terminated lists whose elements all have the
          <see topic='@(url pseudo-event-formp)'>basic structure
          of an event form</see>."
  :true-listp t
  :elementp-of-nil nil)
