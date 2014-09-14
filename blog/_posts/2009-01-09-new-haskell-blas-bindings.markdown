---
layout: post
title: New Haskell BLAS bindings!
keywords: haskell, scientific computing
category: Programming

excerpt: I announce version 0.7 of the haskell BLAS bindings.
---

I just uploaded [version 0.7 of the Haskell BLAS
bindings](http://hackage.haskell.org/cgi-bin/hackage-scripts/package/blas)! This
is a major milestone-- it is finally the library with all of the features that I
want.

Here's what the library is:

* It provides basic data types necessary for doing linear algebra. There are
  dense vectors and matrices, banded matrices, triangular and Hermitian dense 
  matrices, and triangular and Hermitian banded matrices.
* It provides mutable types and operations that mutate them in either the ST
  or the IO monad.
* It maintains a clean distinction in the monadic functions between arguments
  that get mutated and arguments that get read.  This allows passing immutable
  objects without calls to "unsafeThaw" everywhere.
* It gives a convenient interface to the Fortran BLAS functions.  The emphasis
  here is on convenient.  When using the Fortran functions directly, "dgemm",
  the function that multiplies a dense matrix by another dense matrix, takes
  no fewer than 13 arguments.  In the GNU Scientific Library, the binding
  for the function takes 7 arguments.  The Haskell version takes 5.
* It uses BLAS calls internally to perform elementwise vector addition,
  subtraction, multiplication, and division, so these operations should be
  very efficient.
* It gives nearly complete access to all of the functionality in the Fortran
  libraries.  The only missing functions for the dense matrix types are the
  are the matrix updating functions (ger, syr, etc.).  Support for packed
  storage of triangular matrices is absent.  Either of these would be a good
  project for anyone interested.  Neither would be too difficult.
* Other than the matrix updated and the packed storage (and one other small 
  thing, which I will talk about below), anything you can do in Fortran can
  be done in Haskell.  Since most of the computation time in a numerical
  routine is in the floating point operations, this means that in principle
  you can write code in Haskell that will be just as fast the equivalent
  Fortran, at least for moderately-sized inputs.


Here's what the library is not:

* It will never provide support for multiplication by the transpose of a 
  complex matrix without making a copy.  This is the missing feature hinted
  at above.  Even though Fortran BLAS supports this, it is fundamentally
  impossible for the Haskell bindings.  It is debatable how important this
  is, since multiplying by the conjugate of the transpose *is* supported.
* It is not a general array library.  The only supported element types are
  `Double` and `Complex Double`.  This will likely never change.  If you want
  something general, use [array][], [carray][], [uvector][], or one of the
  thousand other Haskell array libraries.
* It is not a full-featured linear algebra library.  You cannot compute an 
  eigenvalue.  You cannot perform a matrix decomposition.  You cannot solve a
  linear system.  This is a library for *writing* a full-featured linear
  algebra library.  It is no good alone for doing anything substantial.

Interested in hacking? Please do. There is a list of project ideas
[in the TODO FILE](http://github.com/patperry/blas/tree/master/TODO).  If
any of these sounds worthwhile and you would like to work on it, let me
know and I will give you some guidance.

Now that that's out of the way, I can (finally) start LAPACK bindings.

  [array]:http://hackage.haskell.org/cgi-bin/hackage-scripts/package/array
  [carray]:http://hackage.haskell.org/cgi-bin/hackage-scripts/package/carray
  [uvector]:http://hackage.haskell.org/cgi-bin/hackage-scripts/package/uvector
