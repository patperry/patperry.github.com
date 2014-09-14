---
layout: post
title: "ANN: BLAS Bindings for Haskell, version 0.5"
keywords: haskell, scientific computing
category: Programming

excerpt: The announcment for the second major release of the haskell BLAS bindings.
---

I've put together a new release of the Haskell BLAS bindings, now
[available on hackage](http://hackage.haskell.org/cgi-bin/hackage-scripts/package/blas).

Here are the new features:

* Add `Banded` matrix data type, as well as `Tri Banded` and `Herm Banded`.
* Add support for trapezoidal dense matrices (`Tri Matrix (m,n) e`, where
  `m` is not the same as `n`).  Note that trapezoidal banded matrices are
  *NOT* supported.
* Add `Diag` matrix data type for diagonal matrices.
* Add `Perm` matrix data type, for permutation matrices.
* Enhance the `RMatrix` and `RSolve` type classes with an API that allows 
  specifying where to store the result of a computation.
* Enhance the `IMatrix`, `RMatrix`, `ISolve`, and `RSolve` type classes to add
  "scale and multiply" operations.
* Remove the scale parameter for `Tri` and `Herm` matrix data types.
* Flatten the data types for `DVector` and `DMatrix`.
* Some inlining and unpacking performance improvements.

As far as what to expect in version 0.6, I plan to add support for operations 
in the ST monad.  This is going to require a pretty big code reorganization and
will cause quite a few API breakages, but I think it's worth the pain.  The 
next release will also come with a tutorial and examples.  After the big
code reorganization, I'll get started on LAPACK bindings.

Please let me know if you are using the library.  I'm really interested in 
what people like and don't like.  If you think that some functionality is 
missing, let me know.  If you think the API is awkward in certain places,
let me know that, too.
