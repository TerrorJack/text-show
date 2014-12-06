{-# LANGUAGE NoImplicitPrelude #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  Text.Show.Text
-- Copyright   :  (C) 2014 Ryan Scott
-- License     :  BSD-style (see the file LICENSE)
-- Maintainer  :  Ryan Scott
-- Stability   :  Experimental
-- Portability :  GHC
-- 
-- Efficiently convert from values to 'Text' via 'Builder's.
----------------------------------------------------------------------------
module Text.Show.Text (
      -- * The 'Show' class
      Show (..)
    , show
    , showLazy
    , showPrec
    , showPrecLazy
    , showList
    , showListLazy
    , showbParen
      -- * 'Builder's
    , module Data.Text.Lazy.Builder
    , lengthB
    , replicateB
    , unlinesB
    , unwordsB
      -- * Printing values
    , print
    , printLazy
    , hPrint
    , hPrintLazy
    ) where

import Data.Text.Lazy.Builder

import Prelude hiding (Show(show, showList), print)

import Text.Show.Text.Class
import Text.Show.Text.Instances ()
import Text.Show.Text.Utils (lengthB, replicateB, unlinesB, unwordsB)