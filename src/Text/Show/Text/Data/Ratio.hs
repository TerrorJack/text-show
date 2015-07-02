{-# LANGUAGE CPP               #-}
{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}
{-|
Module:      Text.Show.Text.Data.Ratio
Copyright:   (C) 2014-2015 Ryan Scott
License:     BSD-style (see the file LICENSE)
Maintainer:  Ryan Scott
Stability:   Provisional
Portability: GHC

Monomorphic 'Show' function for 'Ratio' values.

/Since: 0.5/
-}
module Text.Show.Text.Data.Ratio (showbRatioPrec) where

import Data.Monoid.Compat ((<>))
import Data.Text.Lazy.Builder (Builder)

import GHC.Real (Ratio(..), ratioPrec, ratioPrec1)

import Prelude hiding (Show)

import Text.Show.Text.Classes (Show(showbPrec), showbParen)
#if MIN_VERSION_base(4,4,0)
import Text.Show.Text.Classes (Show1(..))
#endif
import Text.Show.Text.Data.Integral ()

#include "inline.h"

-- | Convert a 'Ratio' to a 'Builder' with the given precedence.
-- 
-- Note that on @base-4.3.0.0@, this function must have a @('Show' a, 'Integral' a)@
-- constraint instead of just a @('Show' a)@ constraint.
-- 
-- /Since: 0.5/
showbRatioPrec ::
#if MIN_VERSION_base(4,4,0)
                  Show a
#else
                  (Show a, Integral a)
#endif
               => Int -> Ratio a -> Builder
showbRatioPrec p (numer :% denom) = showbParen (p > ratioPrec) $
       showbPrec ratioPrec1 numer
    <> " % "
    <> showbPrec ratioPrec1 denom
{-# INLINE showbRatioPrec #-}

instance
#if MIN_VERSION_base(4,4,0)
         Show a
#else
         (Show a, Integral a)
#endif
      => Show (Ratio a) where
    {-# SPECIALIZE instance Show Rational #-}
    showbPrec = showbRatioPrec
    INLINE_INST_FUN(showbPrec)

#if MIN_VERSION_base(4,4,0)
instance Show1 Ratio where
    showbPrecWith sp p (numer :% denom) = showbParen (p > ratioPrec) $
           sp ratioPrec1 numer
        <> " % "
        <> sp ratioPrec1 denom
    INLINE_INST_FUN(showbPrecWith)
#endif
