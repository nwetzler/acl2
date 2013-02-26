;; Processing Unicode Files with ACL2
;; Copyright (C) 2005-2006 by Jared Davis <jared@cs.utexas.edu>
;;
;; This program is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by the Free
;; Software Foundation; either version 2 of the License, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;; FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
;; more details.
;;
;; You should have received a copy of the GNU General Public License along with
;; this program; if not, write to the Free Software Foundation, Inc., 59 Temple
;; Place - Suite 330, Boston, MA 02111-1307, USA.

(in-package "ACL2")
(include-book "app")
(include-book "consless-listp")

(defun binary-append-without-guard (x y)
  (declare (xargs :guard t))
  (mbe :logic
       (append x y)
       :exec
       (if (consp x)
           (cons (car x)
                 (binary-append-without-guard (cdr x) y))
         y)))

(defmacro append-without-guard (x y &rest rst)
  (xxxjoin 'binary-append-without-guard (list* x y rst)))

(add-macro-alias append-without-guard binary-append-without-guard)

(defund flatten (x)
  (declare (xargs :guard t))
  (if (consp x)
      (mbe :logic (app (car x)
                       (flatten (cdr x)))
           :exec (binary-append-without-guard (car x)
                                          (flatten (cdr x))))
    nil))

(defthm flatten-when-not-consp
  (implies (not (consp x))
           (equal (flatten x)
                  nil))
  :hints(("Goal" :in-theory (enable flatten))))

(defthm flatten-of-cons
  (equal (flatten (cons a x))
         (app a (flatten x)))
  :hints(("Goal" :in-theory (enable flatten))))

(defthm flatten-of-list-fix
  (equal (flatten (list-fix x))
         (flatten x))
  :hints(("Goal" :induct (len x))))

(defthm flattenp-of-app
  (equal (flatten (app x y))
         (app (flatten x)
              (flatten y)))
  :hints(("Goal" :induct (len x))))

(defthm flatten-under-iff
  (iff (flatten x)
       (not (consless-listp x)))
  :hints(("Goal" :induct (len x))))