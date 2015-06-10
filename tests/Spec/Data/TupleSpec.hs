{-# LANGUAGE CPP #-}

{-|
Module:      Spec.Data.TupleSpec
Copyright:   (C) 2014-2015 Ryan Scott
License:     BSD-style (see the file LICENSE)
Maintainer:  Ryan Scott
Stability:   Experimental
Portability: GHC

@hspec@ tests for tuple types.
-}
module Spec.Data.TupleSpec (main, spec) where

import Data.Orphans ()

import Instances.Data.Tuple ()

import Spec.Utils (prop_matchesShow)
#if __GLASGOW_HASKELL__ >= 704
import Spec.Utils (prop_genericShow)
#endif

import Test.Hspec (Spec, describe, hspec, parallel)
import Test.Hspec.QuickCheck (prop)

main :: IO ()
main = hspec spec

spec :: Spec
spec = parallel . describe "Text.Show.Text.Data.Tuple" $ do
    prop "() instance"
        (prop_matchesShow :: Int -> () -> Bool)
    prop "(Int, Int) instance"
        (prop_matchesShow :: Int -> (Int, Int) -> Bool)
    prop "(Int, Int, Int) instance"
        (prop_matchesShow :: Int -> (Int, Int, Int) -> Bool)
    prop "(Int, Int, Int, Int) instance"
        (prop_matchesShow :: Int -> (Int, Int, Int, Int) -> Bool)
    prop "(Int, Int, Int, Int, Int) instance"
        (prop_matchesShow :: Int -> (Int, Int, Int, Int, Int) -> Bool)
    prop "(Int, Int, Int, Int, Int, Int) instance"
        (prop_matchesShow :: Int -> (Int, Int, Int, Int, Int, Int) -> Bool)
    prop "(Int, Int, Int, Int, Int, Int, Int) instance"
        (prop_matchesShow :: Int -> (Int, Int, Int, Int, Int, Int, Int) -> Bool)
    prop "(Int, Int, Int, Int, Int, Int, Int, Int) instance"
        (prop_matchesShow :: Int -> (Int, Int, Int, Int, Int, Int, Int, Int) -> Bool)
    prop "(Int, Int, Int, Int, Int, Int, Int, Int, Int) instance"
        (prop_matchesShow :: Int -> (Int, Int, Int, Int, Int, Int, Int, Int, Int) -> Bool)
    prop "(Int, Int, Int, Int, Int, Int, Int, Int, Int, Int) instance"
        (prop_matchesShow :: Int -> (Int, Int, Int, Int, Int, Int, Int, Int, Int, Int) -> Bool)
    prop "(Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int) instance"
        (prop_matchesShow :: Int -> (Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int) -> Bool)
    prop "(Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int) instance"
        (prop_matchesShow :: Int -> (Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int) -> Bool)
    prop "(Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int) instance"
        (prop_matchesShow :: Int -> (Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int) -> Bool)
    prop "(Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int) instance"
        (prop_matchesShow :: Int -> (Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int) -> Bool)
    prop "(Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int) instance"
        (prop_matchesShow :: Int -> (Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int) -> Bool)
#if __GLASGOW_HASKELL__ >= 704
    prop "() generic show"
        (prop_genericShow :: Int -> () -> Bool)
    prop "(Int, Int) generic show"
        (prop_genericShow :: Int -> (Int, Int) -> Bool)
    prop "(Int, Int, Int) generic show"
        (prop_genericShow :: Int -> (Int, Int, Int) -> Bool)
    prop "(Int, Int, Int, Int) generic show"
        (prop_genericShow :: Int -> (Int, Int, Int, Int) -> Bool)
    prop "(Int, Int, Int, Int, Int) generic show"
        (prop_genericShow :: Int -> (Int, Int, Int, Int, Int) -> Bool)
    prop "(Int, Int, Int, Int, Int, Int) generic show"
        (prop_genericShow :: Int -> (Int, Int, Int, Int, Int, Int) -> Bool)
    prop "(Int, Int, Int, Int, Int, Int, Int) generic show"
        (prop_genericShow :: Int -> (Int, Int, Int, Int, Int, Int, Int) -> Bool)
    prop "(Int, Int, Int, Int, Int, Int, Int, Int) generic show"
        (prop_genericShow :: Int -> (Int, Int, Int, Int, Int, Int, Int, Int) -> Bool)
    prop "(Int, Int, Int, Int, Int, Int, Int, Int, Int) generic show"
        (prop_genericShow :: Int -> (Int, Int, Int, Int, Int, Int, Int, Int, Int) -> Bool)
    prop "(Int, Int, Int, Int, Int, Int, Int, Int, Int, Int) generic show"
        (prop_genericShow :: Int -> (Int, Int, Int, Int, Int, Int, Int, Int, Int, Int) -> Bool)
    prop "(Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int) generic show"
        (prop_genericShow :: Int -> (Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int) -> Bool)
    prop "(Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int) generic show"
        (prop_genericShow :: Int -> (Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int) -> Bool)
    prop "(Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int) generic show"
        (prop_genericShow :: Int -> (Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int) -> Bool)
    prop "(Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int) generic show"
        (prop_genericShow :: Int -> (Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int) -> Bool)
    prop "(Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int) generic show"
        (prop_genericShow :: Int -> (Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int) -> Bool)
#endif