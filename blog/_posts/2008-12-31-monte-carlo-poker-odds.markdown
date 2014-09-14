---
layout: post
title: Monte Carlo Poker Odds
keywords: haskell, monte carlo, scientific computing
category: Programming

excerpt: I provide a short tutorial of how to use the haskell Monte Carlo haskell library.
---

There's a new version of
[monte-carlo](http://hackage.haskell.org/cgi-bin/hackage-scripts/package/monte-carlo),
the Monte Carlo monad and transformer I wrote for Haskell. The highlights of the
release are a `MonadMC` typeclass and functions for sampling from general
discrete distributions. This post gives a demonstration of the library by
showing how to estimate poker odds via Monte Carlo simulation.

The goal of the program will be to estimate the distribution of poker
hands from dealing five cards out of a well-shuffled deck of fifty-two
cards.  For reference, [Wikipedia][wiki-poker] gives the probabilities
of the poker hands.  I'm not going to bother distinguishing between a
royal flush and a straight flush.

In the program below, we will need to import the following headers

    import Control.Monad
    import Control.Monad.MC
    import Data.List
    import Data.Map( Map )
    import qualified Data.Map as Map
    import System.Environment
    import Text.Printf

The second of these is part of the `monte-carlo` package.

Poker Functions
---------------

In Haskell, we need to define types for cards and functions for 
classifying hands.  First, we define a card:

    data Suit = Club | Diamond  | Heart | Spade deriving (Eq, Show)
    data Card = Card { number :: Int 
                     , suit   :: Suit
                     }
              deriving (Eq, Show)
    
Here are the numerical values for the face cards,

    ace, jack, queen, king :: Int
    ace   = 1
    jack  = 11
    queen = 12
    king  = 13

and here is how we get a complete deck of cards

    deck :: [Card]
    deck = [ Card i s | i <- [ 1..13 ],
                        s <- [ Club, Diamond, Heart, Spade ] ]

Next, we enumerate the different hands, and define a function that takes a list
of five cards and tells us what hand it is

    data Hand = HighCard  | Pair | TwoPair | ThreeOfAKind | Straight
              | Flush | FullHouse | FourOfAKind | StraightFlush 
              deriving (Eq, Show, Ord)
    
    hand :: [Card] -> Hand
    hand cs = 
      case matches of 
        [1,1,1,1,1] -> case undefined of
                         _ | isStraight && isFlush -> StraightFlush
                         _ | isFlush               -> Flush
                         _ | isStraight            -> Straight
                         _ | otherwise             -> HighCard
        [1,1,1,2]                                  -> Pair
        [1,2,2]                                    -> TwoPair
        [1,1,3]                                    -> ThreeOfAKind
        [2,3]                                      -> FullHouse
        [1,4]                                      -> FourOfAKind
      where
        (x:xs) = (sort . map number) cs
        (s:ss) = map suit cs
        
        isStraight | x == ace && xs == [ 10..king ] = True
                   | otherwise                      = xs == [ x+1..x+4 ]
    
        isFlush = all (== s) ss
    
        matches = (sort . map length . group) (x:xs)

The only tricky part is the special handling of the ace in testing for a
straight.

Monte Carlo Functions
---------------------

To choose a random five-card hand, we use the `sampleSubset` function from
`Control.Monad.MC`, which has type

    sampleSubset :: (MonadMC m) => Int -> Int -> [a] -> m [a]

We give as parameters the subset size, the collection size, and a list of the
collection elements.  So, to get a five-card hand from a deck of fifty-two
cards, we define a function `deal` as

    deal :: (MonadMC m) => m [Card]
    deal = sampleSubset 5 52 deck
   
The signature of the function looks a little strange, because it is polymorphic
in the monad type.  We could have written the signature as `deal :: MC [Card]`.
However, by using the more general signature, we can use the function with 
either the `MC` monad or with `MCT`, the monad transormer version.

The bulk of the work in the simulation gets performed by the `repeatMCWith`
function, which has signature

    repeatMCWith :: (MonadMC m)
                 => (a -> b -> a) -- ^ accumulator
                 -> a             -- ^ initial value
                 -> Int           -- ^ number of repetitions
                 -> m b           -- ^ generator
                 -> m a
    
This function is an analogue of `foldl`.  It repeats a Monte Carlo action a
specified number of times and accumulates the results.  To tally up the
counts of all of the hands, we define

    type HandCounts = Map Hand Int

    emptyCounts :: HandCounts
    emptyCounts = Map.empty
    
    updateCounts :: HandCounts -> [Card] -> HandCounts
    updateCounts counts cs = Map.insertWith' (+) (hand cs) 1 counts

Then, we use these functions in combination with `deal` and `reapeatMCWith`
to estimate the probabilities of all of the hands.  Here is the `main` function
we use

    main = do
      [reps] <- map read `fmap` getArgs
      main' reps
    
    main' reps =
      let seed   = 0
          counts = repeatMCWith updateCounts emptyCounts reps deal
                   `evalMC` mt19937 seed in do
      printf "\n"
      printf "    Hand       Count    Probability     99%% Interval   \n"
      printf "-------------------------------------------------------\n"
      forM_ ((reverse . Map.toAscList) counts) $ \(h,c) ->
          let n     = fromIntegral reps :: Double
              p     = fromIntegral c / n 
              se    = sqrt (p * (1 - p) / n)
              delta = 2.575829 * se
              (l,u) = (p-delta, p+delta) in
          printf "%-13s %7d    %.6f   (%.6f,%.6f)\n" (show h) c p l u
      printf "\n"
        
Results & Discussion
--------------------

Here are the results from running the simulation with one million repititions:

        Hand       Count    Probability     99% Interval   
    -------------------------------------------------------
    StraightFlush      12    0.000012   (0.000003,0.000021)
    FourOfAKind       224    0.000224   (0.000185,0.000263)
    FullHouse        1452    0.001452   (0.001354,0.001550)
    Flush            1908    0.001908   (0.001796,0.002020)
    Straight         3980    0.003980   (0.003818,0.004142)
    ThreeOfAKind    21341    0.021341   (0.020969,0.021713)
    TwoPair         47480    0.047480   (0.046932,0.048028)
    Pair           423785    0.423785   (0.422512,0.425058)
    HighCard       499818    0.499818   (0.498530,0.501106)
    
On my machine it takes about six seconds for the simulation to run.  We can 
see that all of the intervals contain the true answer.  However, the relative
accuracty of the uncommon hands is not very good.  In a later post, I'll show
how to use [Importance Sampling][wiki-is] to get better estimates of the probabilities 
for the rare hands.

Thank you to Aditya Majahan for suggesting the inclusion of `reapeatMC` in
the library.  Please send any more usage reports or feature requests my way.
        

[wiki-poker]:http://en.wikipedia.org/wiki/Poker_probability
[wiki-is]:http://en.wikipedia.org/wiki/Importance_sampling
