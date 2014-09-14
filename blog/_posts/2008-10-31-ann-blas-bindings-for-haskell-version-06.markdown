---
layout: post
title: "ANN: BLAS Bindings for Haskell, version 0.6"
keywords: haskell, scientific computing
category: Programming

excerpt: I announce the third major release of the haskell BLAS bindings.
---

There's a [new version of the BLAS bindings out][hackage]. I put a lot of work
into it and did a pretty massive overhaul of the code. The highlight of the new
release is that now you can do operations in the `ST` monad. Also, I fixed a lot
of organizational issues (no more orphan instances!), and cleaned up the
interface a bit. There are a few performance improvements, too (I shaved half
second off [that old
benchmark](/blog/2008/07/24/addressing-haskell-blas-performance-issues/)). The
downside is that I completely broke backwards compatibility, but since as far as
I can tell I only have two users, I'm not too worried about that.

People have been clamoring for a tutorial, but unfortunately I still don't have
time. My Orals are in ten days, and this stuff is not really core to my
research.  Maybe in a few months I'll do something.

In the mean time, I did manage to come up with some sample code. Here's a
Fortan90 routine for recursively computing an [LU decomposition][lu] with row
pivoting, taken from [Jack Dongarra and Piotr Luszczek's chapter (PDF)][dongarra] in _Beautiful Code_:

    recursive subroutine rdgetrf(m, n, a, lda, ipiv, info) 
     implicit none 
     
     integer, intent(in) :: m, n, lda 
     double precision, intent(inout) :: a(lda,*) 
     integer, intent(out) :: ipiv(*) 
     integer, intent(out) :: info 
     
     integer :: mn, nleft, nright, i 
     double precision :: tmp 
     
     double precision :: pone, negone, zero 
     parameter (pone=1.0d0) 
     parameter (negone=-1.0d0) 
     parameter (zero=0.0d0) 
     
     intrinsic min
     integer idamax 
     external dgemm, dtrsm, dlaswp, idamax, dscal 
     
     mn = min(m, n) 
      
     if (mn .gt. 1) then 
        nleft = mn / 2 
        nright = n - nleft 
       
        call rdgetrf(m, nleft, a, lda, ipiv, info) 
       
        if (info .ne. 0) return 
        call dlaswp(nright, a(1, nleft+1), lda, 1, nleft, ipiv, 1) 
       
        call dtrsm('L', 'L', 'N', 'U', nleft, nright, pone, a, lda, 
    $        a(1, nleft+1), lda) 
    
        call dgemm('N', 'N', m-nleft, nright, nleft, negone, 
    $        a(nleft+1,1) , lda, a(1, nleft+1), lda, pone, 
    $        a(nleft+1, nleft+1), lda) 
        
        call rdgetrf(m - nleft, nright, a(nleft+1, nleft+1), lda, 
    $        ipiv(nleft+1), info)
        if (info .ne. 0) then 
           info = info + nleft 
           return 
        end if 
    
        do i = nleft+1, m 
           ipiv(i) = ipiv(i) + nleft 
        end do 
       
        call dlaswp(nleft, a, lda, nleft+1, mn, ipiv, 1) 
    
     else if (mn .eq. 1) then 
        i = idamax(m, a, 1) 
        ipiv(1) = i 
        tmp = a(i, 1) 
    
        if (tmp .ne. zero .and. tmp .ne. -zero) then 
           call dscal(m, pone/tmp, a, 1) 
       
           a(i,1) = a(1,1) 
           a(1,1) = tmp 
        else 
           info = 1 
        end if 
       
     end if 
    
     return 
     end 
    
Here's the same program in Haskell, using version 0.6 of the blas bindings:

    module LU ( luFactorize ) where
    
    import BLAS.Elem( BLAS3 )
    import Control.Monad
    import Control.Monad.ST
    import Data.Matrix.Dense
    import Data.Matrix.Dense.ST
    import Data.Matrix.Tri
    import Data.Vector.Dense.ST
    
    luFactorize :: (BLAS3 e) => STMatrix s (m,n) e -> ST s (Either Int [Int])
    luFactorize a
        | mn > 1 =
            let nleft = mn `div` 2
                (a_1, a_2) = splitColsAt nleft a
                (a11, a21) = splitRowsAt nleft a_1
                (a12, a22) = splitRowsAt nleft a_2
            in luFactorize a_1 >>=
                   either (return . Left) (\pivots -> do
                       zipWithM_ (swapRows a_2) [0..] pivots
                       doSolveMat_ (lowerU a11) a12
                       doSApplyAddMat (-1) a21 a12 1 a22
                       luFactorize a22 >>=
                           either (return . Left . (nleft+)) (\pivots' -> do
                               zipWithM_ (swapRows a21) [0..] pivots'
                               return (Right $ pivots ++ map (nleft+) pivots')
                           )
                   )
        | mn == 1 = 
            let x = colView a 0
            in getWhichMaxAbs x >>= \(i,e) ->
                if (e /= 0) 
                    then do
                        scaleBy (1/e) x
                        readElem x 0 >>= writeElem x i
                        writeElem x 0 e
                        return $ Right [i]
                    else
                        return $ Left 0
        | otherwise =
            return (Right [])
      where
        (m,n) = shape a
        mn    = min m n

The Haskell version returns `Left` with a column index in the event of failure,
and `Right` with a list of the pivot swaps in the case of success. It makes
exactly the same BLAS calls as the Fortran90 version. The performance of the two
versions should be close, especially for large inputs. (Anyone want to verify
this?)

Some day it will be possible to do serious scientific computing in Haskell without much effort.  This is one small step towards that goal.

[hackage]:http://hackage.haskell.org/cgi-bin/hackage-scripts/package/blas
[lu]:http://en.wikipedia.org/wiki/LU_decomposition
[dongarra]:http://www.netlib.org/netlib/utk/people/JackDongarra/PAPERS/beautiful-code.pdf
