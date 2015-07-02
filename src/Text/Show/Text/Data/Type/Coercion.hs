{-# LANGUAGE CPP             #-}

#if MIN_VERSION_base(4,7,0)
{-# LANGUAGE GADTs           #-}
{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}
#endif
{-|
Module:      Text.Show.Text.Data.Type.Coercion
Copyright:   (C) 2014-2015 Ryan Scott
License:     BSD-style (see the file LICENSE)
Maintainer:  Ryan Scott
Stability:   Provisional
Portability: GHC

Monomorphic 'Show' function for representational equality.
This module only exports functions if using @base-4.7.0.0@ or later.

/Since: 0.3/
-}
module Text.Show.Text.Data.Type.Coercion (
#if !(MIN_VERSION_base(4,7,0))
    ) where
#else
      showbCoercion
    ) where

import Data.Text.Lazy.Builder (Builder)
import Data.Type.Coercion (Coercion(..))

import Prelude hiding (Show)

import Text.Show.Text.Classes (Show(showb, showbPrec), Show1(..), Show2(..))
import Text.Show.Text.TH.Internal (deriveShow2)

-- | Convert a representational equality value to a 'Builder'.
-- This function is only available with @base-4.7.0.0@ or later.
--
-- /Since: 0.3/
showbCoercion :: Coercion a b -> Builder
showbCoercion = showb
{-# INLINE showbCoercion #-}

instance Show (Coercion a b) where
    showbPrec = showbPrecWith undefined
    {-# INLINE showb #-}

instance Show1 (Coercion a) where
    showbPrecWith = showbPrecWith2 undefined
    {-# INLINE showbPrecWith #-}

$(deriveShow2 ''Coercion)
#endif
