---
layout: post
title: "ANN: BLAS bindings for Haskell, version 0.4"
keywords: haskell, scientific computing
category: Programming

excerpt: My announcement of the first public release of the haskell BLAS bindings that I wrote.
---

I've written a set of bindings for the <a href="http://www.netlib.org/blas/">BLAS</a> linear algebra library, and I finally uploaded them to <a href="http://hackage.haskell.org/cgi-bin/hackage-scripts/package/blas">Hackage</a> last night.  That was kind of the impetus for starting this blog: so there would be a place for me to make a formal announcement.

Well, before I got a chance to make that announcement, I received the following e-mail:

    From: Alberto Ruiz
    To: Patrick Perry
    CC: haskell-cafe@haskell.org
    Subject: Patrick Perry's BLAS package

    Hello all,
    I have just noticed that yesterday this fantastic package has been uploaded
    to hackage.  We finally have a high quality library for numeric linear
    algebra. This is very good news for the Haskell community.

    Patrick, many thanks for your excellent work. Do you have similar plans
    for LAPACK?

I'm really happy that people seem to be interested in the library.  Alberto, in particular, is the primary author of <a href="http://alberrto.googlepages.com/gslhaskell">hmatrix</a>, another haskell linear algebra library (which I stole a few ideas from), so if he endorses it, that means a lot to me.

So, Yet Another Linear Algebra Library?  I've already mentioned hmatrix.  There's also another one called <a href="http://www.cs.utah.edu/~hal/HBlas/index.html">HBlas</a>.  Why would anyone want a third?  Here are my reasons:

 - **Support for both immutable and mutable types.** 
   Haskell tries to make you use immutable types as much as possible, and 
   indeed there is a very good reason for this, but sometimes you have a 100MB 
   matrix, and it just isn't very practical to make a copy of it every time 
   you modify it.  _hmatrix_ only supports immutable types, and HBlas only 
   supports mutable ones.  I wanted both.

 - **Access control via phantom types.**
   When you have immutable and mutable types, it's very annoying to have
   separate functions for each type.  Do I want to have to call "numCols" for
   immutable matrices and "getNumCols" for mutable ones, even though both
   functions are pure, and both do exactly the same thing?  No.  If I want to
   add an immutable matrix to a mutable one, to I want to first call 
   `unsafeThaw` on the immutable one to cast it to be mutable?  No.  With the
   phantom type trick, you can get around this insanity.  Jane Street Capital
   has <a href="http://ocaml.janestcapital.com/?q=node/11">a very good description</a> of how this works.
	
 - **Phantom types for matrix and vector shapes.**
   This is a trick I learned from <a href="http://www.haskell.org/haskellwiki/Darcs">darcs</a>.  It means that the compiler can catch many dimension-mismatch mistakes.  So, for instance, a function like the following will not type-check.  (`<*>` is the function to multiply a matrix by a vector.  Everything is ok if you replace `row` by `col`.)  This feature has caught a few bugs in my code.

        foo :: (BLAS3 e) => Matrix (m,n) e -> Matrix (n,k) e -> Int -> Vector m e
        foo a b i = let x = row b i in a <*> x

 - **Taking the conjugate transpose (`herm`) of a matrix is an O(1)
   operation.**
   This is similar to _hmatrix_, where taking the transpose is O(1).  As BLAS
   and LAPACK (mostly) support this, it makes no sense to copy a matrix just
   to work with the conjugate transpose.  Why conjugate transpose instead of
   just transpose?  Because the former is a far more common operation.  This
   is why the `'` operator in MATLAB is conjugate transpose.  The drawback for
   this feature is that BLAS and LAPACK do not support it everywhere.  In
   particular, QR decomposition with pivoting is going to be a huge pain in
   the ass to support for herm-ed matrices.

 - **Support for triangular and hermitian views of matrices.**
   This is a feature of BLAS that no one seems to support (not even MATLAB).
   In addition to the `Matrix` type, there are `Tri Matrix` and `Herm Matrix`
   types that only refer to the upper- or lower-triangular part of the matrix.

Hopefully the features above are compelling enough to make people want to use the library.  These bindings have been a lot of work.  For me to come up with the feature list above, I've already gone through a few iterations of dramatic re-writes (hence the version number).  Of course, I always welcome suggestions for how to make it better.

What's next?  In the immediate future, I plan to add banded matrices.  I've already written a good chunk of code for this, but it isn't very well tested, so I decided to leave it out of the release.  I'm also going to add permutation matrices.  I don't have plans to add support for packed triangular matrices, but if someone else wanted to do that, I would be happy to include it.  The same goes for symmetric complex matrices.  

LAPACK support is on the horizon, but that may take awhile.  Also, I probably won't do more than SVD, QR, and Cholesky, since those are all I need.  Expect a preliminary announcement by the end of the summer.

This work would not have been possible without looking at the other excellent linear algebra libraries out there.  In particular the <a href="http://www.gnu.org/software/gsl/">GNU Scientific Library</a> was the basis for much of the design.  I also drew inspiration from hmatrix and the haskell array libraries.

Thanks also to the folks at `#haskell`.  You guys have been a lot of help.

Please let me know if you have any success in using the library, and if you have any suggestions for how to make it better.
