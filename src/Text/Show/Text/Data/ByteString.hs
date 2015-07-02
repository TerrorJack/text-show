{-# LANGUAGE CPP             #-}
#if !(MIN_VERSION_bytestring(0,10,0))
{-# LANGUAGE TemplateHaskell #-}
#endif
{-# OPTIONS_GHC -fno-warn-orphans #-}
{-|
Module:      Text.Show.Text.Data.ByteString
Copyright:   (C) 2014-2015 Ryan Scott
License:     BSD-style (see the file LICENSE)
Maintainer:  Ryan Scott
Stability:   Provisional
Portability: GHC

Monomorphic 'Show' functions for data types in the @bytestring@ library.

/Since: 0.3/
-}
module Text.Show.Text.Data.ByteString (
      showbByteStringStrict
    , showbByteStringLazy
    , showbByteStringLazyPrec
    , showbShortByteString
    ) where

import qualified Data.ByteString      as BS
import qualified Data.ByteString.Lazy as BL
import           Data.ByteString.Short (ShortByteString)
import           Data.Text.Lazy.Builder (Builder)

import           Prelude hiding (Show(show))

import           Text.Show.Text.Classes (Show(showb, showbPrec), FromStringShow(..))

#if !(MIN_VERSION_bytestring(0,10,0))
import           Text.Show.Text.TH.Internal (deriveShow)
#endif

#include "inline.h"

-- | Convert a strict 'BS.ByteString' to a 'Builder'.
--
-- /Since: 0.3/
showbByteStringStrict :: BS.ByteString -> Builder
showbByteStringStrict = showb . FromStringShow
{-# INLINE showbByteStringStrict #-}

-- | Convert a lazy 'BL.ByteString' to a 'Builder'.
--
-- /Since: 0.3/
showbByteStringLazy :: BL.ByteString -> Builder
showbByteStringLazy = showbByteStringLazyPrec 0
{-# INLINE showbByteStringLazy #-}

-- | Convert a lazy 'BL.ByteString' to a 'Builder' with the given precedence.
--
-- With @bytestring-0.10.0.0@ or later, this function ignores the precedence
-- argument, since lazy 'BL.ByteString's are printed out identically to 'String's.
-- On earlier versions of @bytestring@, however, lazy 'BL.ByteString's can be printed
-- with parentheses (e.g., @Chunk "example" Empty@ vs. @(Chunk "example" Empty)@)
-- depending on the precedence.
--
-- /Since: 0.3/
showbByteStringLazyPrec :: Int -> BL.ByteString -> Builder
#if MIN_VERSION_bytestring(0,10,0)
showbByteStringLazyPrec _ = showb . FromStringShow
#else
showbByteStringLazyPrec = showbPrec
#endif
{-# INLINE showbByteStringLazyPrec #-}

-- | Convert a 'ShortByteString' to a 'Builder'.
--
-- /Since: 0.7/
showbShortByteString :: ShortByteString -> Builder
showbShortByteString = showb . FromStringShow
{-# INLINE showbShortByteString #-}

instance Show BS.ByteString where
    showb = showbByteStringStrict
    INLINE_INST_FUN(showb)

#if MIN_VERSION_bytestring(0,10,0)
instance Show BL.ByteString where
    showbPrec = showbByteStringLazyPrec
    INLINE_INST_FUN(showbPrec)
#else
$(deriveShow ''BL.ByteString)
#endif

instance Show ShortByteString where
    showb = showbShortByteString
    INLINE_INST_FUN(showb)
