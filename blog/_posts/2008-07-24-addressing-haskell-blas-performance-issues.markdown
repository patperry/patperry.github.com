---
layout: post
title: Addressing Haskell BLAS Performance Issues
keywords: blas, haskell, performance
category: Programming

excerpt: I discuss some performance improvements to the haskell BLAS bindings.
---

Last month Anatoly Yakovenko started [a thread on haskell-cafe][] about
the Haskell blas bindings being much slower than using raw C.  I was in Denver
at the time on a drive across the United States, so I didn't participate in much
of the conversation.  The conclusion seemed to be that the bindings were about
thirty times slower than C.  Ouch.

[a thread on haskell-cafe]: http://www.haskell.org/pipermail/haskell-cafe/2008-June/044401.html

Here is a C program that computes ten million dot product between two vectors of
doubles:

    #include <cblas.h>
    #include <stdlib.h>

    int main() 
    {
       int size  = 10;
       int times = 10*1000*1000;
       int i = 0;

       double *x = malloc( size*sizeof( double ) );
       double *y = malloc( size*sizeof( double ) );

       for( i = 0; i < times; ++i ) 
       {
          cblas_ddot( size, x, 1, y, 1 );
       }

       free( x );
       free( y );
       
       return 0;
    }

There is no overhead for initializing the vector-- just for allocating and 
freeing it.  The equivalent Haskell program, using mutable vectors, is:

    module Main where

    import Control.Monad
    import Data.Vector.Dense.IO

    main = do
       let size  = 10
       let times = 10*1000*1000
   
       x <- newVector_ size :: IO (IOVector n Double)
       y <- newVector_ size 
       replicateM_ times $ x `getDot` y

The Haskell program also checks that the lengths of x and y match, but the
overhead from this is only about a tenth of a second.  There was some grumbling
on haskell-cafe about the compiler annotations allowing the removal of the for
loop, but this doesn't seem to be happening for me when I compile with -O2.  

The runtime from the C version is about 0.380 seconds, and from the Haskell
version it is about 4.345 seconds.  The discrepancy is 11.5 times worse 
instead of 30, but still bad.  I claimed that the overhead does not grow with
the size of the vector, and indeed this seems to be the case.  When I increase
the size to 1024, the C version runs in about 15.883 seconds and the Haskell
version runs in about 19.900 seconds.

Depending on the size of vectors you're dealing with the Haskell performance is
either terrible or acceptable.  Still, I wondered if I could do better.

The root of the inefficiency is the vector data type I used. [In my last post][]
I argued that it's useful to make conjugating a vector be an O(1) operation. One
way to do this is to store a boolean flag "isConj" that indicates whether or not
the vector is conjugated.  If so, the values stored in memory are the complex
conjugates of the values in the vector.  Another way to do this is to define the
vector data type as

    data DVector t n e =
           DV { fptr   :: !(ForeignPtr e)
              , offset :: !Int
              , len    :: !Int
              , stride :: !Int
              }
         | C !(DVector t n e)

In this representation, a vector of the form "DV f o l s" is a raw vector, and
"C x" is the conjugate of the vector x.  In the first version of the library, I
went with the second representation.  Originally, it was for aesthetic reasons,
but now I'm not so sure of the relative pretty-ness of the two approaches.  One
thing Wren Ng Thorton pointed out to me is that with the two representations are
not equivalent, since in the second you could have C(C(C(...C(DV(...))...))) as
a legitamate value.

[In my last post]: /blog/2008/06/12/blas-data-types

When you take performance considerations into account, a boolean flag is a
clear winner over an algebraic data type.  When I switched to the first
representation and re-ran the benchmarks, I got 1.264 seconds for vectors of
size 10 and 16.839 seconds for vectors of size 1024.  The comparison I've done
between the two data representation isn't perfect, because in the boolean flag
code I also incorporated some unboxing and inlining changes suggested by Don
Stewart.  Still, the biggest performance gains came from the data types.

When you remove the length checking (by using `unsafeGetDot` instead of
`getDot`), the times for the update Haskell benchmarks are 1.095 seconds
and 16.682 seconds.  So, for ten million dot products, there is an overhead of
about 0.6 seconds for using Haskell instead of C, regardless of the vector
size.  This is pretty good.

The next release of the bindings will incorporate these changes.  Thanks go to 
everyone on haskell-cafe for their help, especially Anatoly for pointing out the
problem.
