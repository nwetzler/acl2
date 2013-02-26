(in-package "ACL2")

(include-book "../../lib1/top")

(include-book "../fp")

(defun C (k a b)
  (- (bitn a k) (bitn b k)))

(defun PHI (a b d k)
  (if (and (integerp k) (>= k 0))
      (if (= k 0)
	  0
	(if (= d 0)
	    (phi a b (c (1- k) a b) (1- k))
	  (if (= d (- (c (1- k) a b)))
	      (phi a b (- (c (1- k) a b)) (1- k))
	    k)))
    0))

(local (defun phi-induct (a b d k)
  (if (and (integerp k) (>= k 0))
      (if (= k 0)
	  0
	(and (phi-induct a b (c (1- k) a b) (1- k))
	     (phi-induct a b (- (c (1- k) a b)) (1- k))))
    d)))

(local (defthm c-lemma
    (implies (< b a)
	     (equal (c k b a) (- (c k a b))))))

(local (defthm phi-d
    (implies (and (integerp a)
		  (integerp b)
		  (< b a)
		  (integerp d)
		  (integerp k)
		  (>= k 0))
	     (= (phi a b d k)
		(phi b a (- d) k)))
  :rule-classes ()
  :hints (("Goal" :in-theory (disable c)
		  :induct (phi-induct a b d k)))))

(local (defun nat-induct (k)
  (if (and (integerp k) (>= k 0))
      (if (= k 0)
	  0
	(nat-induct (1- k)))
    0)))

(local (defthm lop1-hack1
    (implies (and (integerp m)
		  (integerp x)
		  (integerp k)
		  (>= m 0))
	     (INTEGERP (+ X (* -1 (EXPT 2 M)) (* K (EXPT 2 M)))))
  :rule-classes ()))

(local (defthm lop1-hack2
    (implies (and (integerp m)
		  (integerp x)
		  (integerp k)
		  (>= x 0)
		  (>= k 0)
		  (>= m 0))
	     (>= (+ X (* K (EXPT 2 M)))
                 0))
  :rule-classes ()))

(local (defthm lop1-hack3
    (implies (and (integerp m)
		  (integerp x)
		  (integerp k)
		  (>= x 0)
		  (>= k 1)
		  (>= m 0))
	     (>= (+ X (* -1 (EXPT 2 M)) (* K (EXPT 2 M)))
                 0))
  :rule-classes ()
  :hints (("Goal" :in-theory (disable a14)
		  :use ((:instance lop1-hack2 (k (1- k))))))))

(defthm BIT+*K
    (implies (and (integerp x)
		  (integerp n)
		  (integerp m)
		  (>= x 0)
		  (> m n)
		  (>= n 0)
		  (integerp k)
		  (>= k 0))
	     (equal (bitn (+ x (* k (expt 2 m))) n)
		    (bitn x n)))
  :rule-classes ()
  :hints (("Goal" :induct (nat-induct k))
	  ("Subgoal *1/2" :use ((:instance integerp-expt (n m))
				(:instance bit+-b (x (+ x (* (1- k) (expt 2 m)))))))
	  ("Subgoal *1/2.2" :use (lop1-hack1))
	  ("Subgoal *1/2.1" :use (lop1-hack3))))

(in-theory (disable rem))

(defthm BITN-REM
    (implies (and (integerp x)
		  (>= x 0)
		  (integerp j)
		  (>= j 0)
		  (integerp k)
		  (> k j))
	     (equal (bitn (rem x (expt 2 k)) j)
		    (bitn x j)))
  :hints (("Goal" :use ((:instance rem-fl (m x) (n (expt 2 k)))
			(:instance rem>=0 (m x) (n (expt 2 k)))
			(:instance bit+*k 
				   (x (rem x (expt 2 k)))
				   (m k)
				   (n j)
				   (k (fl (/ x (expt 2 k)))))))))

(local (defthm rem-c
    (implies (and (integerp x)
		  (>= x 0)
		  (integerp y)
		  (>= y 0)
		  (integerp j)
		  (>= j 0)
		  (integerp k)
		  (> k j))
	     (equal (c j (rem x (expt 2 k)) (rem y (expt 2 k)))
		    (c j x y)))))

(local (defthm rem-c-2
    (implies (and (integerp x)
		  (>= x 0)
		  (integerp y)
		  (>= y 0)
		  (integerp j)
		  (>= j 0)
		  (integerp k)
		  (> k j))
	     (equal (c j (rem x (* 2 (expt 2 (+ -1 k)))) (rem y (* 2 (expt 2 (+ -1 k)))))
		    (c j x y)))
  :hints (("Goal" :in-theory (disable rem-c)
		  :use (rem-c)))))

(defthm PHI-REM
    (implies (and (integerp a)
		  (>= a 0)
		  (integerp b)
		  (>= b 0)
		  (integerp d)
		  (integerp j)
		  (>= j 0)
		  (integerp k)
		  (>= k j))
	     (= (phi a b d j)
		(phi (rem a (expt 2 k)) (rem b (expt 2 k)) d j)))
  :rule-classes ()
  :hints (("Goal" :in-theory (disable c)
		  :induct (phi-induct a b d j))
	  ("Subgoal *1/2" :expand ((phi a b d j)
				   (PHI (REM A (* 2 (EXPT 2 (+ -1 K))))
					(REM B (* 2 (EXPT 2 (+ -1 K))))
					d
					j)))))

(local (defun lop1-induct (n a b)
  (if (and (integerp n) (>= n 0))
      (if (> n 1)
	  (if (= (c (1- n) a b) 0)
	      (lop1-induct (1- n) (rem a (expt 2 (1- n))) (rem b (expt 2 (1- n))))
	    (if (= (c (- n 2) a b) -1)
		(lop1-induct (1- n) (- a (expt 2 (- n 2))) (- b (expt 2 (- n 2))))
	      t))
	t)
    t)))

(local (defthm lop1-1
    (implies (and (integerp a)
		  (integerp b)
		  (integerp n)
		  (>= a 0)
		  (>= b 0)
		  (>= n 0)
		  (<= n 1)
		  (< b a)
		  (< a (expt 2 n))
		  (< b (expt 2 n)))
	     (= n 1))
  :rule-classes ()))

(local (defthm lop1-2
    (implies (and (integerp a)
		  (integerp b)
		  (>= a 0)
		  (>= b 0)
		  (< b a)
		  (< a 2)
		  (< b 2))
	     (and (= a 1) (= b 0)))
  :rule-classes ()))

(local (defthm lop1-3
    (= (phi 1 0 0 1) (expo 1))
  :rule-classes ()))

(local (defthm lop1-4
    (IMPLIES (AND (AND (INTEGERP N) (<= 0 N))
		  (<= N 1))
	     (IMPLIES (AND (INTEGERP A)
			   (INTEGERP B)
			   (INTEGERP N)
			   (<= 0 A)
			   (<= 0 B)
			   (<= 0 N)
			   (< B A)
			   (< A (EXPT 2 N))
			   (< B (EXPT 2 N)))
		      (OR (= (PHI A B 0 N) (EXPO (+ A (- B))))
			  (= (PHI A B 0 N)
			     (+ 1 (EXPO (+ A (- B))))))))
  :rule-classes ()
  :hints (("Goal" :use (lop1-1 lop1-2 lop1-3)))))

(local (defthm lop1-5
    (IMPLIES (AND (INTEGERP N)
		  (< 1 N)
		  (NOT (= (C (+ -1 N) A B) 0))
		  (INTEGERP A)
		  (INTEGERP B)
		  (INTEGERP N)
		  (<= 0 A)
		  (<= 0 B)
		  (<= 0 N)
		  (< B A)
		  (< A (EXPT 2 N))
		  (< B (EXPT 2 N)))
	     (and (= (bitn a (1- n)) 1)
		  (= (bitn b (1- n)) 0)
		  (= (c (1- n) a b) 1)))
  :rule-classes ()
  :hints (("Goal" :use ((:instance bitn-0-1 (x a) (n (1- n)))
			(:instance bitn-0-1 (x b) (n (1- n)))
			(:instance bit-expo-a (x b) (n (1- n)))
			(:instance bit-expo-b (x a) (n (1- n))))))))

(local (defthm lop1-6
    (IMPLIES (AND (INTEGERP N)
		  (< 1 N)
		  (NOT (= (C (+ -1 N) A B) 0))
		  (NOT (= (C (+ -2 N) A B) -1))
		  (INTEGERP A)
		  (INTEGERP B)
		  (INTEGERP N)
		  (<= 0 A)
		  (<= 0 B)
		  (<= 0 N)
		  (< B A)
		  (< A (EXPT 2 N))
		  (< B (EXPT 2 N)))
	     (= (PHI A B 0 N) 
		(1- n)))
  :rule-classes ()
  :hints (("Goal" :in-theory (disable c)
		  :use (lop1-5))
	  ("Subgoal 1" :expand ((PHI A B 1 (+ -1 N)))))))

(local (defthm lop1-7
    (IMPLIES (AND (INTEGERP N)
		  (< 1 N)
		  (NOT (= (C (+ -1 N) A B) 0))
		  (INTEGERP A)
		  (INTEGERP B)
		  (INTEGERP N)
		  (<= 0 A)
		  (<= 0 B)
		  (<= 0 N)
		  (< B A)
		  (< A (EXPT 2 N))
		  (< B (EXPT 2 N)))
	     (and (>= a (expt 2 (1- n)))
		  (< b (expt 2 (1- n)))))
  :rule-classes ()
  :hints (("Goal" :use ((:instance lop1-5)
			(:instance bit-expo-a (x a) (n (1- n)))
			(:instance bit-expo-b (x b) (n (1- n))))))))

(local (defthm lop1-8
    (IMPLIES (AND (INTEGERP N)
		  (< 1 N)
		  (NOT (= (C (+ -1 N) A B) 0))
		  (INTEGERP A)
		  (INTEGERP B)
		  (INTEGERP N)
		  (<= 0 A)
		  (<= 0 B)
		  (<= 0 N)
		  (< B A)
		  (< b (expt 2 (- n 2)))
		  (< A (EXPT 2 N))
		  (< B (EXPT 2 N)))
	     (> (- a b) (expt 2 (- n 2))))
  :rule-classes ()
  :hints (("Goal" :use ((:instance lop1-7)
			(:instance expo+ (m (- 2 n)) (n 1)))))))

(local (in-theory (disable c-lemma)))

(local (defthm lop1-9
    (IMPLIES (AND (INTEGERP N)
		  (< 1 N)
		  (NOT (= (C (+ -1 N) A B) 0))
		  (NOT (= (C (+ -2 N) A B) -1))
		  (INTEGERP A)
		  (INTEGERP B)
		  (INTEGERP N)
		  (<= 0 A)
		  (<= 0 B)
		  (<= 0 N)
		  (< B A)
		  (>= b (expt 2 (- n 2)))
		  (< A (EXPT 2 N))
		  (< B (EXPT 2 N)))
	     (= (bitn a (- n 2)) 1))
  :rule-classes ()
  :hints (("Goal" :in-theory (disable expt)
		  :use (lop1-7
			(:instance bitn-0-1 (x a) (n (- n 2)))
			(:instance bitn-0-1 (x b) (n (- n 2)))
			(:instance bit-expo-b (x b) (n (- n 2))))))))

(local (defthm lop1-10
    (IMPLIES (AND (INTEGERP N)
		  (< 1 N)
		  (NOT (= (C (+ -1 N) A B) 0))
		  (NOT (= (C (+ -2 N) A B) -1))
		  (INTEGERP A)
		  (INTEGERP B)
		  (INTEGERP N)
		  (<= 0 A)
		  (<= 0 B)
		  (<= 0 N)
		  (< B A)
		  (>= b (expt 2 (- n 2)))
		  (< A (EXPT 2 N))
		  (< B (EXPT 2 N)))
	     (= (bitn (- a (expt 2 (1- n))) (- n 2))
		1))
  :rule-classes ()
  :hints (("Goal" :in-theory (disable expt)
		  :use (lop1-9
			lop1-7
			(:instance bit+-b (x (- a (expt 2 (1- n)))) (m (1- n)) (n (- n 2))))))))

(local (defthm lop1-11
    (IMPLIES (AND (INTEGERP N)
		  (< 1 N)
		  (NOT (= (C (+ -1 N) A B) 0))
		  (NOT (= (C (+ -2 N) A B) -1))
		  (INTEGERP A)
		  (INTEGERP B)
		  (INTEGERP N)
		  (<= 0 A)
		  (<= 0 B)
		  (<= 0 N)
		  (< B A)
		  (>= b (expt 2 (- n 2)))
		  (< A (EXPT 2 N))
		  (< B (EXPT 2 N)))
	     (>= (- a b) (expt 2 (- n 2))))
  :rule-classes ()
  :hints (("Goal" :in-theory (disable expt)
		  :use (lop1-10
			lop1-7
			(:instance bit-expo-a (x (- a (expt 2 (1- n)))) (n (- n 2))))))))

(local (defthm lop1-12
    (IMPLIES (AND (INTEGERP N)
		  (< 1 N)
		  (NOT (= (C (+ -1 N) A B) 0))
		  (NOT (= (C (+ -2 N) A B) -1))
		  (INTEGERP A)
		  (INTEGERP B)
		  (INTEGERP N)
		  (<= 0 A)
		  (<= 0 B)
		  (<= 0 N)
		  (< B A)
		  (< A (EXPT 2 N))
		  (< B (EXPT 2 N)))
	     (>= (- a b) (expt 2 (- n 2))))
  :rule-classes ()
  :hints (("Goal" :in-theory (disable expt)
		  :use (lop1-11
			lop1-8)))))

(local (defthm lop1-13
    (IMPLIES (AND (INTEGERP N)
		  (< 1 N)
		  (NOT (= (C (+ -1 N) A B) 0))
		  (NOT (= (C (+ -2 N) A B) -1))
		  (INTEGERP A)
		  (INTEGERP B)
		  (INTEGERP N)
		  (<= 0 A)
		  (<= 0 B)
		  (<= 0 N)
		  (< B A)
		  (< A (EXPT 2 N))
		  (< B (EXPT 2 N)))
	     (>= (expo (- a b)) (- n 2)))
  :rule-classes ()
  :hints (("Goal" :in-theory (disable expt)
		  :use (lop1-12
			(:instance expo>= (x (- a b)) (n (- n 2))))))))

(local (defthm lop1-14
    (IMPLIES (AND (INTEGERP N)
		  (< 1 N)
		  (NOT (= (C (+ -1 N) A B) 0))
		  (NOT (= (C (+ -2 N) A B) -1))
		  (INTEGERP A)
		  (INTEGERP B)
		  (INTEGERP N)
		  (<= 0 A)
		  (<= 0 B)
		  (<= 0 N)
		  (< B A)
		  (< A (EXPT 2 N))
		  (< B (EXPT 2 N)))
	     (<= (expo (- a b)) (- n 1)))
  :rule-classes ()
  :hints (("Goal" :use ((:instance expo-monotone (x (- a b)) (y a))
			(:instance expo<= (x a) (n (- n 1))))))))

(local (defthm lop1-15
    (IMPLIES (AND (INTEGERP N)
		  (< 1 N)
		  (NOT (= (C (+ -1 N) A B) 0))
		  (NOT (= (C (+ -2 N) A B) -1))
		  (INTEGERP A)
		  (INTEGERP B)
		  (INTEGERP N)
		  (<= 0 A)
		  (<= 0 B)
		  (<= 0 N)
		  (< B A)
		  (< A (EXPT 2 N))
		  (< B (EXPT 2 N)))
	     (OR (= (PHI A B 0 N) (EXPO (+ A (- B))))
		 (= (PHI A B 0 N)
		    (+ 1 (EXPO (+ A (- B)))))))
  :rule-classes ()
  :hints (("Goal" :use (lop1-14 lop1-13 lop1-6)))))

(local (defthm lop1-16
    (IMPLIES (AND (INTEGERP N)
		  (< 1 N)
		  (= (C (+ -2 N) A B) -1)
		  (INTEGERP A)
		  (INTEGERP B)
		  (INTEGERP N)
		  (<= 0 A)
		  (<= 0 B)
		  (<= 0 N)
		  (< B A)
		  (< A (EXPT 2 N))
		  (< B (EXPT 2 N)))
	     (and (= (bitn b (- n 2)) 1)
		  (= (bitn a (- n 2)) 0)))
  :rule-classes ()
  :hints (("Goal" :use ((:instance bitn-0-1 (x a) (n (- n 2)))
			(:instance bitn-0-1 (x b) (n (- n 2))))))))

(local (defthm lop1-17
    (IMPLIES (AND (INTEGERP N)
		  (< 1 N)
                  (NOT (= (C (+ -1 N) A B) 0))
		  (= (C (+ -2 N) A B) -1)
		  (INTEGERP A)
		  (INTEGERP B)
		  (INTEGERP N)
		  (<= 0 A)
		  (<= 0 B)
		  (<= 0 N)
		  (< B A)
		  (< A (EXPT 2 N))
		  (< B (EXPT 2 N)))
	     (>= b (expt 2 (- n 2))))
  :rule-classes ()
  :hints (("Goal" :in-theory (disable expt)
		  :use (lop1-16
			(:instance bit-expo-a (x b) (n (- n 2))))))))

(local (defthm lop1-18
    (IMPLIES (AND (INTEGERP N)
		  (< 1 N)
                  (NOT (= (C (+ -1 N) A B) 0))
		  (= (C (+ -2 N) A B) -1)
		  (INTEGERP A)
		  (INTEGERP B)
		  (INTEGERP N)
		  (<= 0 A)
		  (<= 0 B)
		  (<= 0 N)
		  (< B A)
		  (< A (EXPT 2 N))
		  (< B (EXPT 2 N)))
	     (< a (- (expt 2 n) (expt 2 (- n 2)))))
  :rule-classes ()
  :hints (("Goal" :in-theory (disable expt)
		  :use (lop1-16
			(:instance bit-expo-c (x a) (k (- n 2))))))))

(local (defthm lop1-19
    (IMPLIES (AND (INTEGERP N)
		  (< 1 N)
                  (NOT (= (C (+ -1 N) A B) 0))
		  (= (C (+ -2 N) A B) -1)
		  (INTEGERP A)
		  (INTEGERP B)
		  (INTEGERP N)
		  (<= 0 A)
		  (<= 0 B)
		  (<= 0 N)
		  (< B A)
		  (< A (EXPT 2 N))
		  (< B (EXPT 2 N)))
	     (< a (+ (expt 2 (- n 1)) (expt 2 (- n 2)))))
  :rule-classes ()
  :hints (("Goal" :in-theory (disable expt)
		  :use (lop1-18
			(:instance expo+ (m (- n 1)) (n 1))
			(:instance expo+ (m (- n 2)) (n 1)))))))

(local (defthm lop1-hack4
    (implies (and (integerp a)
		  (integerp n)
		  (> n 1))
	     (INTEGERP (+ A (* -1 (EXPT 2 (+ -2 N))))))
  :hints (("Goal" :in-theory (disable integerp-expt a14)
		  :use ((:instance integerp-expt (n (- n 2))))))))

(local (defthm lop1-20
    (IMPLIES (AND (AND (INTEGERP N) (<= 0 N))
		  (< 1 N)
		  (NOT (= (C (+ -1 N) A B) 0))
		  (= (C (+ -2 N) A B) -1)
		  (IMPLIES (AND (INTEGERP (+ A (- (EXPT 2 (+ -2 N)))))
				(INTEGERP (+ B (- (EXPT 2 (+ -2 N)))))
				(INTEGERP (+ -1 N))
				(<= 0 (+ A (- (EXPT 2 (+ -2 N)))))
				(<= 0 (+ B (- (EXPT 2 (+ -2 N)))))
				(<= 0 (+ -1 N))
				(< (+ B (- (EXPT 2 (+ -2 N))))
				   (+ A (- (EXPT 2 (+ -2 N)))))
				(< (+ A (- (EXPT 2 (+ -2 N))))
				   (EXPT 2 (+ -1 N)))
				(< (+ B (- (EXPT 2 (+ -2 N))))
				   (EXPT 2 (+ -1 N))))
			   (OR (= (PHI (+ A (- (EXPT 2 (+ -2 N))))
				       (+ B (- (EXPT 2 (+ -2 N))))
				       0 (+ -1 N))
				  (EXPO (+ (+ A (- (EXPT 2 (+ -2 N))))
					   (- (+ B (- (EXPT 2 (+ -2 N))))))))
			       (= (PHI (+ A (- (EXPT 2 (+ -2 N))))
				       (+ B (- (EXPT 2 (+ -2 N))))
				       0 (+ -1 N))
				  (+ 1
				     (EXPO (+ (+ A (- (EXPT 2 (+ -2 N))))
					      (- (+ B (- (EXPT 2 (+ -2 N)))))))))))
		  (INTEGERP A)
		  (INTEGERP B)
		  (INTEGERP N)
		  (<= 0 A)
		  (<= 0 B)
		  (<= 0 N)
		  (< B A)
		  (< A (EXPT 2 N))
		  (< B (EXPT 2 N)))
	     (OR (= (PHI (+ A (- (EXPT 2 (+ -2 N))))
			 (+ B (- (EXPT 2 (+ -2 N))))
			 0 
			 (+ -1 N))
		    (EXPO (+ A (- B))))
		 (= (PHI (+ A (- (EXPT 2 (+ -2 N))))
			 (+ B (- (EXPT 2 (+ -2 N))))
			 0 
			 (+ -1 N))
		    (+ 1 (EXPO (+ A (- B)))))))
  :rule-classes ()
  :hints (("Goal" :in-theory (disable expt)
		  :use (lop1-7 
			lop1-17
			lop1-19
			(:instance expo+ (m (- n 1)) (n 1))
			(:instance expo+ (m (- n 2)) (n 1)))))))

(local (defthm lop1-21
    (IMPLIES (AND (INTEGERP N)
		  (< 1 N)
                  (NOT (= (C (+ -1 N) A B) 0))
		  (= (C (+ -2 N) A B) -1)
		  (INTEGERP A)
		  (INTEGERP B)
		  (INTEGERP N)
		  (<= 0 A)
		  (<= 0 B)
		  (<= 0 N)
		  (< B A)
		  (< A (EXPT 2 N))
		  (< B (EXPT 2 N)))
	     (= (phi a b 0 n)
		(phi a b 1 (- n 1))))
  :rule-classes ()
  :hints (("Goal" :in-theory (disable expt)
		  :use (lop1-5)))))

(local (defthm lop1-22
    (IMPLIES (AND (INTEGERP N)
		  (< 1 N)
                  (NOT (= (C (+ -1 N) A B) 0))
		  (= (C (+ -2 N) A B) -1)
		  (INTEGERP A)
		  (INTEGERP B)
		  (INTEGERP N)
		  (<= 0 A)
		  (<= 0 B)
		  (<= 0 N)
		  (< B A)
		  (< A (EXPT 2 N))
		  (< B (EXPT 2 N)))
	     (= (phi a b 0 n)
		(phi a b 1 (- n 2))))
  :rule-classes ()
  :hints (("Goal" :in-theory (disable expt)
		  :expand (PHI A B 1 (+ -1 N))
		  :use (lop1-5 lop1-21)))))

(local (defthm lop1-23
    (IMPLIES (AND (INTEGERP N)
		  (< 1 N)
                  (NOT (= (C (+ -1 N) A B) 0))
		  (= (C (+ -2 N) A B) -1)
		  (INTEGERP A)
		  (INTEGERP B)
		  (INTEGERP N)
		  (<= 0 A)
		  (<= 0 B)
		  (<= 0 N)
		  (< B A)
		  (< A (EXPT 2 N))
		  (< B (EXPT 2 N)))
	     (= (phi (rem a (expt 2 (- n 2)))
		     (rem b (expt 2 (- n 2)))
		     1
		     (- n 2))
		(phi a b 1 (- n 2))))
  :rule-classes ()
  :hints (("Goal" :in-theory (disable expt)
		  :use ((:instance phi-rem (d 1) (j (- n 2)) (k (- n 2))))))))

(local (defthm lop1-24
    (IMPLIES (AND (INTEGERP N)
		  (< 1 N)
                  (NOT (= (C (+ -1 N) A B) 0))
		  (= (C (+ -2 N) A B) -1)
		  (INTEGERP A)
		  (INTEGERP B)
		  (INTEGERP N)
		  (<= 0 A)
		  (<= 0 B)
		  (<= 0 N)
		  (< B A)
		  (< A (EXPT 2 N))
		  (< B (EXPT 2 N)))
	     (= (phi (rem (- a (expt 2 (- n 2)))
			  (expt 2 (- n 2)))
		     (rem (- b (expt 2 (- n 2)))
			  (expt 2 (- n 2)))
		     1
		     (- n 2))
		(phi (- a (expt 2 (- n 2)))
		     (- b (expt 2 (- n 2)))
		     1 (- n 2))))
  :rule-classes ()
  :hints (("Goal" :in-theory (disable expt)
		  :use (lop1-17
			(:instance phi-rem
				   (a (- a (expt 2 (- n 2))))
				   (b (- b (expt 2 (- n 2))))
				   (d 1) 
				   (j (- n 2))
				   (k (- n 2))))))))

(in-theory (enable integerp-expt))

(local (defthm lop1-25
    (IMPLIES (AND (INTEGERP N)
		  (< 1 N)
                  (NOT (= (C (+ -1 N) A B) 0))
		  (= (C (+ -2 N) A B) -1)
		  (INTEGERP A)
		  (INTEGERP B)
		  (INTEGERP N)
		  (<= 0 A)
		  (<= 0 B)
		  (<= 0 N)
		  (< B A)
		  (< A (EXPT 2 N))
		  (< B (EXPT 2 N)))
	     (= (phi (rem (- a (expt 2 (- n 2)))
			  (expt 2 (- n 2)))
		     (rem (- b (expt 2 (- n 2)))
			  (expt 2 (- n 2)))
		     1
		     (- n 2))
		(phi (rem a
			  (expt 2 (- n 2)))
		     (rem b
			  (expt 2 (- n 2)))
		     1
		     (- n 2))))
  :rule-classes ()
  :hints (("Goal" :in-theory (disable expt)
		  :use (lop1-17
			(:instance expt-pos (x (- n 2)))
			(:instance rem+ (m (- a (expt 2 (- n 2)))) (a 1) (n (expt 2 (- n 2))))
			(:instance rem+ (m (- b (expt 2 (- n 2)))) (a 1) (n (expt 2 (- n 2)))))))))

(local (defthm lop1-26
    (IMPLIES (AND (INTEGERP N)
		  (< 1 N)
                  (NOT (= (C (+ -1 N) A B) 0))
		  (= (C (+ -2 N) A B) -1)
		  (INTEGERP A)
		  (INTEGERP B)
		  (INTEGERP N)
		  (<= 0 A)
		  (<= 0 B)
		  (<= 0 N)
		  (< B A)
		  (< A (EXPT 2 N))
		  (< B (EXPT 2 N)))
	     (= (phi a b 0 n)
		(phi (- a (expt 2 (- n 2)))
		     (- b (expt 2 (- n 2)))
		     1 (- n 2))))
  :rule-classes ()
  :hints (("Goal" :in-theory (disable expt)
		  :use (lop1-22 lop1-23 lop1-24 lop1-25)))))

(local (defthm lop1-27
    (IMPLIES (AND (INTEGERP N)
		  (< 1 N)
                  (NOT (= (C (+ -1 N) A B) 0))
		  (= (C (+ -2 N) A B) -1)
		  (INTEGERP A)
		  (INTEGERP B)
		  (INTEGERP N)
		  (<= 0 A)
		  (<= 0 B)
		  (<= 0 N)
		  (< B A)
		  (< A (EXPT 2 N))
		  (< B (EXPT 2 N)))
	     (= (bitn (- b (expt 2 (- n 2))) (- n 2))
		0))
  :rule-classes ()
  :hints (("Goal" :use (lop1-7
			lop1-17
			(:instance expo+ (m (- n 2)) (n 1))
			(:instance bit-expo-a (x (- b (expt 2 (- n 2)))) (n (- n 2))))
		  :in-theory (disable expt)))))

(local (defthm lop1-28
    (IMPLIES (AND (INTEGERP N)
		  (< 1 N)
                  (NOT (= (C (+ -1 N) A B) 0))
		  (= (C (+ -2 N) A B) -1)
		  (INTEGERP A)
		  (INTEGERP B)
		  (INTEGERP N)
		  (<= 0 A)
		  (<= 0 B)
		  (<= 0 N)
		  (< B A)
		  (< A (EXPT 2 N))
		  (< B (EXPT 2 N)))
	     (= (bitn (- a (expt 2 (- n 2))) (- n 2))
		1))
  :rule-classes ()
  :hints (("Goal" :use (lop1-7
			lop1-19
			(:instance expo+ (m (- n 2)) (n 1))
			(:instance bit-expo-b (x (- a (expt 2 (- n 2)))) (n (- n 2))))
		  :in-theory (disable expt)))))

(local (defthm lop1-29
    (IMPLIES (AND (INTEGERP N)
		  (< 1 N)
                  (NOT (= (C (+ -1 N) A B) 0))
		  (= (C (+ -2 N) A B) -1)
		  (INTEGERP A)
		  (INTEGERP B)
		  (INTEGERP N)
		  (<= 0 A)
		  (<= 0 B)
		  (<= 0 N)
		  (< B A)
		  (< A (EXPT 2 N))
		  (< B (EXPT 2 N)))
	     (= (phi (- a (expt 2 (- n 2)))
		     (- b (expt 2 (- n 2)))
		     0 (- n 1))
		(phi (- a (expt 2 (- n 2)))
		     (- b (expt 2 (- n 2)))
		     1 (- n 2))))
  :rule-classes ()
  :hints (("Goal" :expand (PHI (+ A (* -1 (EXPT 2 (+ -2 N))))
			       (+ B (* -1 (EXPT 2 (+ -2 N))))
			       0 (+ -1 N))
		  :use (lop1-27 lop1-28)
		  :in-theory (disable expt)))))

(local (defthm lop1-30
    (IMPLIES (AND (INTEGERP N)
		  (< 1 N)
                  (NOT (= (C (+ -1 N) A B) 0))
		  (= (C (+ -2 N) A B) -1)
		  (INTEGERP A)
		  (INTEGERP B)
		  (INTEGERP N)
		  (<= 0 A)
		  (<= 0 B)
		  (<= 0 N)
		  (< B A)
		  (< A (EXPT 2 N))
		  (< B (EXPT 2 N)))
	     (= (phi a b 0 n)
		(phi (- a (expt 2 (- n 2)))
		     (- b (expt 2 (- n 2)))
		     0 (- n 1))))
  :rule-classes ()
  :hints (("Goal" :in-theory (disable expt)
		  :use (lop1-26 lop1-29)))))

(local (defthm lop1-31
    (IMPLIES (AND (AND (INTEGERP N) (<= 0 N))
		  (< 1 N)
		  (NOT (= (C (+ -1 N) A B) 0))
		  (= (C (+ -2 N) A B) -1)
		  (IMPLIES (AND (INTEGERP (+ A (- (EXPT 2 (+ -2 N)))))
				(INTEGERP (+ B (- (EXPT 2 (+ -2 N)))))
				(INTEGERP (+ -1 N))
				(<= 0 (+ A (- (EXPT 2 (+ -2 N)))))
				(<= 0 (+ B (- (EXPT 2 (+ -2 N)))))
				(<= 0 (+ -1 N))
				(< (+ B (- (EXPT 2 (+ -2 N))))
				   (+ A (- (EXPT 2 (+ -2 N)))))
				(< (+ A (- (EXPT 2 (+ -2 N))))
				   (EXPT 2 (+ -1 N)))
				(< (+ B (- (EXPT 2 (+ -2 N))))
				   (EXPT 2 (+ -1 N))))
			   (OR (= (PHI (+ A (- (EXPT 2 (+ -2 N))))
				       (+ B (- (EXPT 2 (+ -2 N))))
				       0 (+ -1 N))
				  (EXPO (+ (+ A (- (EXPT 2 (+ -2 N))))
					   (- (+ B (- (EXPT 2 (+ -2 N))))))))
			       (= (PHI (+ A (- (EXPT 2 (+ -2 N))))
				       (+ B (- (EXPT 2 (+ -2 N))))
				       0 (+ -1 N))
				  (+ 1
				     (EXPO (+ (+ A (- (EXPT 2 (+ -2 N))))
					      (- (+ B (- (EXPT 2 (+ -2 N)))))))))))
		  (INTEGERP A)
		  (INTEGERP B)
		  (INTEGERP N)
		  (<= 0 A)
		  (<= 0 B)
		  (<= 0 N)
		  (< B A)
		  (< A (EXPT 2 N))
		  (< B (EXPT 2 N)))
	     (OR (= (PHI A B 0 N) (EXPO (+ A (- B))))
		 (= (PHI A B 0 N)
		    (+ 1 (EXPO (+ A (- B)))))))
  :rule-classes ()
  :hints (("Goal" :in-theory (disable expt)
		  :use (lop1-20 lop1-30)))))

(local (defthm lop1-32
    (IMPLIES (AND (AND (INTEGERP N) (<= 0 N))
		  (< 1 N)
		  (= (bitn a (- n 1)) 0)
		  (= (bitn b (- n 1)) 0)
		  (INTEGERP A)
		  (INTEGERP B)
		  (INTEGERP N)
		  (<= 0 A)
		  (<= 0 B)
		  (<= 0 N)
		  (< B A)
		  (< A (EXPT 2 N))
		  (< B (EXPT 2 N)))
	     (= (- a b)
		(- (rem a (expt 2 (- n 1)))
		   (rem b (expt 2 (- n 1))))))
  :rule-classes ()
  :hints (("Goal" :use ((:instance rem< (m a) (n (expt 2 (- n 1))))
			(:instance rem< (m b) (n (expt 2 (- n 1))))
			(:instance expt-pos (x (- n 1)))
			(:instance bit-expo-b (x a) (n (- n 1)))
			(:instance bit-expo-b (x b) (n (- n 1))))))))

(local (defthm lop1-33
    (IMPLIES (AND (AND (INTEGERP N) (<= 0 N))
		  (< 1 N)
		  (= (bitn a (- n 1)) 1)
		  (INTEGERP A)
		  (INTEGERP N)
		  (<= 0 A)
		  (<= 0 N)
		  (< A (EXPT 2 N)))
	     (= (rem a (expt 2 (- n 1)))
		(- a (expt 2 (- n 1)))))
  :rule-classes ()
  :hints (("Goal" :use ((:instance rem< (m (- a (expt 2 (- n 1)))) (n (expt 2 (- n 1))))
			(:instance expt-pos (x (- n 1)))
			(:instance expo+ (m (- n 1)) (n 1))
			(:instance bit-expo-a (x a) (n (- n 1)))
			(:instance rem+ (m (- a (expt 2 (- n 1)))) (a 1) (n (expt 2 (- n 1)))))))))

(local (defthm lop1-34
    (IMPLIES (AND (AND (INTEGERP N) (<= 0 N))
		  (< 1 N)
		  (= (bitn a (- n 1)) 1)
		  (= (bitn b (- n 1)) 1)
		  (INTEGERP A)
		  (INTEGERP B)
		  (INTEGERP N)
		  (<= 0 A)
		  (<= 0 B)
		  (<= 0 N)
		  (< B A)
		  (< A (EXPT 2 N))
		  (< B (EXPT 2 N)))
	     (= (- a b)
		(- (rem a (expt 2 (- n 1)))
		   (rem b (expt 2 (- n 1))))))
  :rule-classes ()
  :hints (("Goal" :use ((:instance lop1-33)
			(:instance lop1-33 (a b)))))))

(local (defthm lop1-35
    (IMPLIES (AND (AND (INTEGERP N) (<= 0 N))
		  (< 1 N)
		  (= (C (+ -1 N) A B) 0)
		  (INTEGERP A)
		  (INTEGERP B)
		  (INTEGERP N)
		  (<= 0 A)
		  (<= 0 B)
		  (<= 0 N)
		  (< B A)
		  (< A (EXPT 2 N))
		  (< B (EXPT 2 N)))
	     (= (- a b)
		(- (rem a (expt 2 (- n 1)))
		   (rem b (expt 2 (- n 1))))))
  :rule-classes ()
  :hints (("Goal" :in-theory (disable expt)
		  :use (lop1-34
			lop1-32
			(:instance bitn-0-1 (x a) (n (- n 1)))
			(:instance bitn-0-1 (x b) (n (- n 1))))))))

(local (defthm lop1-36
    (IMPLIES (AND (AND (INTEGERP N) (<= 0 N))
		  (< 1 N)
		  (= (C (+ -1 N) A B) 0)
		  (IMPLIES (AND (INTEGERP (REM A (EXPT 2 (+ -1 N))))
				(INTEGERP (REM B (EXPT 2 (+ -1 N))))
				(INTEGERP (+ -1 N))
				(<= 0 (REM A (EXPT 2 (+ -1 N))))
				(<= 0 (REM B (EXPT 2 (+ -1 N))))
				(<= 0 (+ -1 N))
				(< (REM B (EXPT 2 (+ -1 N)))
				   (REM A (EXPT 2 (+ -1 N))))
				(< (REM A (EXPT 2 (+ -1 N)))
				   (EXPT 2 (+ -1 N)))
				(< (REM B (EXPT 2 (+ -1 N)))
				   (EXPT 2 (+ -1 N))))
			   (OR (= (PHI (REM A (EXPT 2 (+ -1 N)))
				       (REM B (EXPT 2 (+ -1 N)))
				       0 (+ -1 N))
				  (EXPO (+ (REM A (EXPT 2 (+ -1 N)))
					   (- (REM B (EXPT 2 (+ -1 N)))))))
			       (= (PHI (REM A (EXPT 2 (+ -1 N)))
				       (REM B (EXPT 2 (+ -1 N)))
				       0 (+ -1 N))
				  (+ 1
				     (EXPO (+ (REM A (EXPT 2 (+ -1 N)))
					      (- (REM B (EXPT 2 (+ -1 N))))))))))
		  (INTEGERP A)
		  (INTEGERP B)
		  (INTEGERP N)
		  (<= 0 A)
		  (<= 0 B)
		  (<= 0 N)
		  (< B A)
		  (< A (EXPT 2 N))
		  (< B (EXPT 2 N)))
	     (OR (= (PHI (REM A (EXPT 2 (+ -1 N)))
			 (REM B (EXPT 2 (+ -1 N)))
			 0 (+ -1 N))
		    (EXPO (+ A (- B))))
		 (= (PHI (REM A (EXPT 2 (+ -1 N)))
			 (REM B (EXPT 2 (+ -1 N)))
			 0 (+ -1 N))
		    (+ 1 (EXPO (+ A (- B)))))))
  :rule-classes ()
  :hints (("Goal" :in-theory (disable expt)
		  :use (lop1-35
			(:instance rem>=0 (m a) (n (expt 2 (- n 1))))
			(:instance rem>=0 (m b) (n (expt 2 (- n 1))))
			(:instance rem<n (m a) (n (expt 2 (- n 1))))
			(:instance rem<n (m b) (n (expt 2 (- n 1))))
			(:instance expt-pos (x (- n 1))))))))

(local (defthm lop1-37
    (IMPLIES (AND (AND (INTEGERP N) (<= 0 N))
		  (< 1 N)
		  (= (C (+ -1 N) A B) 0)
		  (INTEGERP A)
		  (INTEGERP B)
		  (INTEGERP N)
		  (<= 0 A)
		  (<= 0 B)
		  (<= 0 N)
		  (< B A)
		  (< A (EXPT 2 N))
		  (< B (EXPT 2 N)))
	     (= (phi a b 0 n)
		(PHI (REM A (EXPT 2 (+ -1 N)))
		     (REM B (EXPT 2 (+ -1 N)))
		     0 (+ -1 N))))
  :rule-classes ()
  :hints (("Goal" :in-theory (disable expt)
		  :use ((:instance phi-rem (d 0) (j (- n 1)) (k (- n 1))))))))

(local (defthm lop1-38
    (IMPLIES (AND (AND (INTEGERP N) (<= 0 N))
		  (< 1 N)
		  (= (C (+ -1 N) A B) 0)
		  (IMPLIES (AND (INTEGERP (REM A (EXPT 2 (+ -1 N))))
				(INTEGERP (REM B (EXPT 2 (+ -1 N))))
				(INTEGERP (+ -1 N))
				(<= 0 (REM A (EXPT 2 (+ -1 N))))
				(<= 0 (REM B (EXPT 2 (+ -1 N))))
				(<= 0 (+ -1 N))
				(< (REM B (EXPT 2 (+ -1 N)))
				   (REM A (EXPT 2 (+ -1 N))))
				(< (REM A (EXPT 2 (+ -1 N)))
				   (EXPT 2 (+ -1 N)))
				(< (REM B (EXPT 2 (+ -1 N)))
				   (EXPT 2 (+ -1 N))))
			   (OR (= (PHI (REM A (EXPT 2 (+ -1 N)))
				       (REM B (EXPT 2 (+ -1 N)))
				       0 (+ -1 N))
				  (EXPO (+ (REM A (EXPT 2 (+ -1 N)))
					   (- (REM B (EXPT 2 (+ -1 N)))))))
			       (= (PHI (REM A (EXPT 2 (+ -1 N)))
				       (REM B (EXPT 2 (+ -1 N)))
				       0 (+ -1 N))
				  (+ 1
				     (EXPO (+ (REM A (EXPT 2 (+ -1 N)))
					      (- (REM B (EXPT 2 (+ -1 N))))))))))
		  (INTEGERP A)
		  (INTEGERP B)
		  (INTEGERP N)
		  (<= 0 A)
		  (<= 0 B)
		  (<= 0 N)
		  (< B A)
		  (< A (EXPT 2 N))
		  (< B (EXPT 2 N)))
	     (OR (= (PHI A B 0 N) (EXPO (+ A (- B))))
		 (= (PHI A B 0 N)
		    (+ 1 (EXPO (+ A (- B)))))))
  :rule-classes ()
  :hints (("Goal" :in-theory (disable expt)
		  :use (lop1-36 lop1-37)))))

(local (defthm lop1-39
    (implies (and (integerp a)
		  (integerp b)
		  (integerp n)
		  (>= a 0)
		  (>= b 0)
		  (>= n 0)
		  (< b a)
		  (< a (expt 2 n))
		  (< b (expt 2 n)))
	     (or (= (phi a b 0 n) (expo (- a b)))
		 (= (phi a b 0 n) (1+ (expo (- a b))))))
  :rule-classes ()
  :hints (("Goal" :in-theory (disable c)
		  :induct (lop1-induct n a b))
	  ("Subgoal *1/4" :use (lop1-4))
	  ("Subgoal *1/3" :use (lop1-15))
	  ("Subgoal *1/2" :use (lop1-31))
	  ("Subgoal *1/1" :use (lop1-38)))))

(local (defthm lop1-hack5
    (implies (and (rationalp a) (rationalp b))
	     (equal (- (+ A (- B)))
		    (+ (- a) b)))))

(defthm LOP-THM-1
    (implies (and (integerp a)
		  (integerp b)
		  (integerp n)
		  (>= a 0)
		  (>= b 0)
		  (>= n 0)
		  (not (= a b))
		  (< a (expt 2 n))
		  (< b (expt 2 n)))
	     (or (= (phi a b 0 n) (expo (- a b)))
		 (= (phi a b 0 n) (1+ (expo (- a b))))))
  :rule-classes ()
  :hints (("Goal" :in-theory (disable c phi)
		  :use (lop1-39
			(:instance expo-minus (x (- a b)))
			(:instance lop1-39 (a b) (b a))
			(:instance phi-d (a b) (b a) (d 0) (k n))))))