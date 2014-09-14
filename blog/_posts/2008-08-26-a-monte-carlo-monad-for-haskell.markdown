---
layout: post
title: A Monte Carlo Monad for Haskell
keywords: haskell, monte carlo, scientific computing
category: Programming

excerpt: The announcement of the Monte Carlo library I wrote for haskell.
---

I've just uploaded two new packages to Hackage. The first, [gsl-random][], is a
set of bindings to the random number generators and random number distributions
that come as part of the [GNU Scientific Library][gsl]. The next package,
[monte-carlo][], is a monad and monad transformer for performing computations
that require a random number generator, and is based on `gsl-random`. This post
will give you a taste of what the `MC` Monte Carlo monad can do.

[gsl-random]:http://hackage.haskell.org/cgi-bin/hackage-scripts/package/gsl-random
[gsl]:http://www.gnu.org/software/gsl/
[monte-carlo]:http://hackage.haskell.org/cgi-bin/hackage-scripts/package/monte-carlo

Introduction
------------

For those unfamiliar with Monte Carlo, the basic idea is to use randomness to
compute a nonrandom quantity. You generate a sequence of random variables `X`
with mean equal to some quantity you care about, and then form a confidence
interval for the quantity based on the mean and standard deviation of the
simulated values.

Here's an example that will make things a little more concrete. Suppose you want
to compute `pi`. Say you have the ability to generate random points in the unit
box `[-1,1]^2`. The box has an area of `2^2 = 4`. The unit disc, which is
contained completely in the box, has an area of `pi`. Therefore, the probability
of `X` landing inside the unit circle is `pi/4`. So, if we generate a whole
bunch of `X`s, we should expect about `pi/4` of them to land inside the unit
circle. This means we can get an estimate of `pi` by generating a bunch of
random points, counting how many land inside the circle, and then multiplying by
`4`.

Of course, the more points we take, the more accurate our answer will be. We can
even get an approximate confidence interval for the true value by computing the
standard deviation of the values.

Using the `MC` Monad
--------------------

The `monte-carlo` package provides a monad, called `MC`, for performing Monte
Carlo computations. The package exports a function for generating values
uniformly over an interval:

    uniform :: Double -> Double -> MC Double
    
This function takes the lower and upper bounds, and produces a value in that
range.  We can use this function to generate a value in the unit box:

    unitBox :: MC (Double,Double)
    unitBox = liftM2 (,) (uniform (-1) 1) 
                         (uniform (-1) 1)

We will need a function to test if a point lies inside the unit circle:

    inUnitCircle :: (Double,Double) -> Bool
    inUnitCircle (x,y) = x*x + y*y <= 1

Here is a function to generate `n` points and count how many fall inside the
circle, and then to compute an estimate and standard error for `pi`
based on n samples:

    computePi :: Int -> MC (Double,Double)
    computePi n = do
        xs <- replicateM n unitBox
        let m  = length $ filter inUnitCircle xs
            p  = toDouble m / toDouble n
            se = sqrt (p * (1 - p) / toDouble n)
        return (4*p, 4*se)

      where
        toDouble = realToFrac . toInteger


Running the Simulation
----------------------

To get a value *out* of the `MC` monad, we must provide it with a random number
generator. To get a Mersenne Twister generator, we use the `mt19937` function.
Then, evaluate the result with `evalMC`.

Here's an example:

    main = let
        n       = 10000000
        seed    = 0
        (mu,se) = evalMC (computePi n) $ mt19937 seed
        delta   = 2.575*se
        (l,u)   = (mu-delta, mu+delta)
        in do
            printf "Estimate:                   %g\n" mu
            printf "99%% Confidence Interval:    (%g,%g)\n" l u

It takes my 2GHz Macbook a little under five seconds to run the simulation with
ten million samples. Here are the results I get:

    Estimate:                   3.1414584
    99% Confidence Interval:    (3.1401211162675353,3.1427956837324644)

Pretty cool, eh?

-----------------------------------------------------------------------------

You might be wondering why I didn't just use [MonadRandom][]? There are two
reasons: first, I didn't want to write routines to generate random variables
from different distributions (Normal, Exponential, Poisson, etc.). The GSL
provides these for me. Second, internally the `MC` monad is *not* using a pure
random number generator. It only keeps one copy of the generator state, and
modifies it every time it samples a value.

[MonadRandom]:http://hackage.haskell.org/cgi-bin/hackage-scripts/package/MonadRandom
