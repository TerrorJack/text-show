{-# LANGUAGE CPP                #-}

#if MIN_VERSION_base(4,4,0)
{-# LANGUAGE DeriveGeneric      #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}
#endif

{-|
Module:      Instances.GHC.Fingerprint
Copyright:   (C) 2014-2016 Ryan Scott
License:     BSD-style (see the file LICENSE)
Maintainer:  Ryan Scott
Stability:   Provisional
Portability: GHC

'Arbitrary' instance for 'Fingerprint'.
-}
module Instances.GHC.Fingerprint () where

#if MIN_VERSION_base(4,4,0)
import GHC.Fingerprint.Type (Fingerprint(..))
import GHC.Generics (Generic)

import Test.QuickCheck (Arbitrary(..), genericArbitrary)

deriving instance Generic Fingerprint
instance Arbitrary Fingerprint where
    arbitrary = genericArbitrary
#endif
