{-# LANGUAGE CPP                        #-}
{-# LANGUAGE FlexibleContexts           #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MagicHash                  #-}
{-# LANGUAGE StandaloneDeriving         #-}
{-# LANGUAGE TypeOperators              #-}
#if MIN_VERSION_base(4,7,0)
{-# LANGUAGE TypeFamilies               #-}
# if !(MIN_VERSION_base(4,8,0))
{-# OPTIONS_GHC -fno-warn-warnings-deprecations #-}
# endif
#endif
{-# OPTIONS_GHC -fno-warn-orphans               #-}
{-|
Module:      Instances.BaseAndFriends
Copyright:   (C) 2014-2015 Ryan Scott
License:     BSD-style (see the file LICENSE)
Maintainer:  Ryan Scott
Stability:   Experimental
Portability: GHC

Provides 'Arbitrary' instances for data types located in @base@ and other
common libraries. This module also defines 'Show' instances for some data
types as well (e.g., those which do not derive 'Show' in older versions
of GHC).
-}
module Instances.BaseAndFriends () where

import           Control.Applicative (Const(..), ZipList(..))
import           Control.Exception
import           Control.Monad.ST (ST, fixST)

import           Data.ByteString.Short (ShortByteString, pack)
import           Data.Char (GeneralCategory(..))
import qualified Data.Data as D (Fixity(..))
import           Data.Data (Constr, ConstrRep(..), DataRep(..), DataType,
                            mkConstr, mkDataType)
import           Data.Dynamic (Dynamic, toDyn)
#if defined(VERSION_transformers)
# if !(MIN_VERSION_transformers(0,4,0))
import           Data.Functor.Classes ()
# endif
#endif
import           Data.Functor.Identity (Identity(..))
import           Data.Monoid (All(..), Any(..), Dual(..), First(..),
                              Last(..), Product(..), Sum(..))
#if MIN_VERSION_base(4,8,0)
import           Data.Monoid (Alt(..))
#endif
#if MIN_VERSION_base(4,7,0) && !(MIN_VERSION_base(4,8,0))
import qualified Data.OldTypeable.Internal as OldT (TyCon(..), TypeRep(..))
#endif
#if MIN_VERSION_base(4,6,0)
import           Data.Ord (Down(..))
#endif
import           Data.Proxy (Proxy(..))
#if MIN_VERSION_text(1,0,0)
import           Data.Text.Encoding (Decoding(..))
#endif
import           Data.Text.Encoding.Error (UnicodeException(..))
import           Data.Text.Foreign (I16)
#if MIN_VERSION_text(1,1,0)
import           Data.Text.Internal.Fusion.Size (Size, exactSize)
#endif
import           Data.Text.Lazy.Builder (Builder, fromString)
import           Data.Text.Lazy.Builder.RealFloat (FPFormat(..))
#if MIN_VERSION_base(4,7,0)
import           Data.Coerce (Coercible)
import           Data.Type.Coercion (Coercion(..))
import           Data.Type.Equality ((:~:)(..))
#endif
#if MIN_VERSION_base(4,4,0)
import qualified Data.Typeable.Internal as NewT (TyCon(..), TypeRep(..))
#else
import qualified Data.Typeable as NewT (TyCon, TyRep, mkTyCon, typeOf)
#endif
import           Data.Version (Version(..))

import           Foreign.C.Types
import           Foreign.Ptr (FunPtr, IntPtr, Ptr, WordPtr,
                              castPtrToFunPtr, nullPtr, plusPtr,
                              ptrToIntPtr, ptrToWordPtr)

import           GHC.Conc (BlockReason(..), ThreadStatus(..))
#if !(defined(__GHCJS__))
# if defined(mingw32_HOST_OS)
import           GHC.Conc.Windows (ConsoleEvent(..))
# elif MIN_VERSION_base(4,4,0)
import           GHC.Event (Event, evtRead, evtWrite)
# endif
#endif
#if MIN_VERSION_base(4,4,0)
import           GHC.Fingerprint.Type (Fingerprint(..))
#endif
#if __GLASGOW_HASKELL__ >= 702
import qualified GHC.Generics as G (Fixity(..))
import           GHC.Generics (U1(..), Par1(..), Rec1(..), K1(..),
                               M1(..), (:+:)(..), (:*:)(..), (:.:)(..),
                               Associativity(..), Arity(..))
#endif
#if MIN_VERSION_base(4,4,0)
import           GHC.IO.Encoding.Failure (CodingFailureMode(..))
import           GHC.IO.Encoding.Types (CodingProgress(..))
#endif
import           GHC.IO.Exception (IOException(..), IOErrorType(..))
import           GHC.IO.Handle (HandlePosn(..))
#if MIN_VERSION_base(4,8,0)
import           GHC.RTS.Flags
import           GHC.StaticPtr (StaticPtrInfo(..))
#endif
#if MIN_VERSION_base(4,5,0)
import           GHC.Stats (GCStats(..))
#endif
#if MIN_VERSION_base(4,7,0)
import           GHC.TypeLits (SomeNat, SomeSymbol, someNatVal, someSymbolVal)
#endif

import           Instances.Utils ((<@>))

import           Numeric (showHex)
#if !(MIN_VERSION_QuickCheck(2,8,0) && MIN_VERSION_base(4,8,0))
import           Numeric.Natural (Natural)
#endif

import           Prelude ()
import           Prelude.Compat

import           System.Exit (ExitCode(..))
import           System.IO (BufferMode(..), IOMode(..), Newline(..), NewlineMode(..),
                            SeekMode(..), Handle, stdin, stdout, stderr)
import           System.Posix.Types

import           Test.QuickCheck (Arbitrary(..), Gen,
                                  arbitraryBoundedEnum, oneof, suchThat)
#if !(MIN_VERSION_base(4,5,0))
import           Data.Int
import           GHC.Prim (unsafeCoerce#)
import           Test.QuickCheck (arbitrarySizedBoundedIntegral,
                                  arbitrarySizedFractional)
#endif
import           Test.QuickCheck.Instances ()

import           Text.Read.Lex as Lex (Lexeme(..))
#if MIN_VERSION_base(4,7,0)
import           Data.Fixed (Fixed, E12)
import           Text.Read.Lex (Number)
#endif
import           Text.Show.Text (FromStringShow(..), FromTextShow(..))
import           Text.Show.Text.Generic (ConType(..))

#if MIN_VERSION_base(4,7,0)
import           Numeric (showOct, showEFloat, showFFloat, showGFloat)
#else
import           Data.Word
#endif

#if MIN_VERSION_base(4,7,0) || MIN_VERSION_text(1,1,0)
import           Test.QuickCheck (getNonNegative)
#endif

#include "HsBaseConfig.h"

#if !(MIN_VERSION_QuickCheck(2,8,0) && MIN_VERSION_base(4,8,0))
instance Arbitrary Natural where
    arbitrary = fromInteger <$> arbitrary `suchThat` (>= 0)
#endif

instance Arbitrary Builder where
    arbitrary = fromString <$> arbitrary

instance Arbitrary ShortByteString where
    arbitrary = pack <$> arbitrary

instance Arbitrary I16 where
    arbitrary = arbitraryBoundedEnum

deriving instance Bounded FPFormat
instance Arbitrary FPFormat where
    arbitrary = arbitraryBoundedEnum

instance Arbitrary UnicodeException where
    arbitrary = oneof [ DecodeError <$> arbitrary <*> arbitrary
                      , EncodeError <$> arbitrary <*> arbitrary
                      ]

#if MIN_VERSION_text(1,0,0)
instance Arbitrary Decoding where
    arbitrary = Some <$> arbitrary <*> arbitrary <@> undefined
#endif

#if MIN_VERSION_text(1,1,0)
instance Arbitrary Size where
    arbitrary = exactSize . getNonNegative <$> arbitrary
#endif

instance Arbitrary (Ptr a) where
    arbitrary = plusPtr nullPtr <$> arbitrary

instance Arbitrary (FunPtr a) where
    arbitrary = castPtrToFunPtr <$> arbitrary

instance Arbitrary IntPtr where
    arbitrary = ptrToIntPtr <$> arbitrary

instance Arbitrary WordPtr where
    arbitrary = ptrToWordPtr <$> arbitrary

instance Arbitrary GeneralCategory where
    arbitrary = arbitraryBoundedEnum

instance Arbitrary Version where
    arbitrary = Version <$> arbitrary <*> arbitrary

instance Arbitrary SomeException where
    arbitrary = SomeException <$> (arbitrary :: Gen AssertionFailed)

instance Arbitrary IOException where
    arbitrary = IOError <$> arbitrary <*> arbitrary <*> arbitrary
                        <*> arbitrary <*> arbitrary <*> arbitrary

deriving instance Bounded IOErrorType
deriving instance Enum IOErrorType
instance Arbitrary IOErrorType where
    arbitrary = arbitraryBoundedEnum

deriving instance Bounded ArithException
deriving instance Enum ArithException
instance Arbitrary ArithException where
    arbitrary = arbitraryBoundedEnum

instance Arbitrary ArrayException where
    arbitrary = oneof [ IndexOutOfBounds <$> arbitrary
                      , UndefinedElement <$> arbitrary
                      ]

instance Arbitrary AssertionFailed where
    arbitrary = AssertionFailed <$> arbitrary

#if MIN_VERSION_base(4,7,0)
instance Arbitrary SomeAsyncException where
    arbitrary = SomeAsyncException <$> (arbitrary :: Gen AsyncException)
#endif

deriving instance Bounded AsyncException
deriving instance Enum AsyncException
instance Arbitrary AsyncException where
    arbitrary = arbitraryBoundedEnum

instance Arbitrary NonTermination where
    arbitrary = pure NonTermination

instance Arbitrary NestedAtomically where
    arbitrary = pure NestedAtomically

instance Arbitrary BlockedIndefinitelyOnMVar where
    arbitrary = pure BlockedIndefinitelyOnMVar

instance Arbitrary BlockedIndefinitelyOnSTM where
    arbitrary = pure BlockedIndefinitelyOnSTM

#if MIN_VERSION_base(4,8,0)
instance Arbitrary AllocationLimitExceeded where
    arbitrary = pure AllocationLimitExceeded
#endif

instance Arbitrary Deadlock where
    arbitrary = pure Deadlock

instance Arbitrary NoMethodError where
    arbitrary = NoMethodError <$> arbitrary

instance Arbitrary PatternMatchFail where
    arbitrary = PatternMatchFail <$> arbitrary

instance Arbitrary RecConError where
    arbitrary = RecConError <$> arbitrary

instance Arbitrary RecSelError where
    arbitrary = RecSelError <$> arbitrary

instance Arbitrary RecUpdError where
    arbitrary = RecUpdError <$> arbitrary

-- ErrorCall is a newtype starting with base-4.7.0.0, but we'll
-- manually derive Arbitrary to support older versions of GHC.
instance Arbitrary ErrorCall where
    arbitrary = ErrorCall <$> arbitrary

deriving instance Bounded MaskingState
deriving instance Enum MaskingState
instance Arbitrary MaskingState where
    arbitrary = arbitraryBoundedEnum

instance Arbitrary Lexeme where
    arbitrary = oneof [ Char   <$> arbitrary
                      , String <$> arbitrary
                      , Punc   <$> arbitrary
                      , Ident  <$> arbitrary
                      , Symbol <$> arbitrary
#if MIN_VERSION_base(4,7,0)
                      , Number <$> arbitrary
#elif !(MIN_VERSION_base(4,6,0))
                      , Int    <$> arbitrary
                      , Rat    <$> arbitrary
#endif
                      , pure Lex.EOF
                      ]
    
#if MIN_VERSION_base(4,7,0)
instance Arbitrary Number where
    arbitrary = do
        str <- oneof [ show <$> (nonneg :: Gen Double)
                     , fmap (\d -> showEFloat Nothing d "") (nonneg :: Gen Double)
                     , fmap (\d -> showFFloat Nothing d "") (nonneg :: Gen Double)
                     , fmap (\d -> showGFloat Nothing d "") (nonneg :: Gen Double)
                     , show <$> (nonneg :: Gen Float)
                     , show <$> (nonneg :: Gen Int)
                     , fmap (\i -> "0x" ++ showHex i "") (nonneg :: Gen Int)
                     , fmap (\i -> "0o" ++ showOct i "") (nonneg :: Gen Int)
                     , show <$> (nonneg :: Gen Integer)
                     , show <$> (nonneg :: Gen Word)
                     , show <$> (nonneg :: Gen (Fixed E12))
                     ]
        let Number num = read str
        pure num
      where
        nonneg :: (Arbitrary a, Num a, Ord a) => Gen a
        nonneg = getNonNegative <$> arbitrary
#endif

instance Arbitrary (Proxy s) where
    arbitrary = pure Proxy

#if MIN_VERSION_base(4,7,0) && !(MIN_VERSION_base(4,8,0))
instance Arbitrary OldT.TypeRep where
    arbitrary = OldT.TypeRep <$> arbitrary <*> arbitrary <@> []
--     arbitrary = OldT.TypeRep <$> arbitrary <*> arbitrary <*> arbitrary

instance Arbitrary OldT.TyCon where
    arbitrary = OldT.TyCon <$> arbitrary <*> arbitrary <*> arbitrary <*> arbitrary
#endif

instance Arbitrary NewT.TypeRep where
#if MIN_VERSION_base(4,4,0)
    arbitrary = NewT.TypeRep <$> arbitrary <*> arbitrary
# if MIN_VERSION_base(4,8,0)
                                                         <@> [] <@> []
# else
                                                         <@> []
# endif
#else
    arbitrary = NewT.typeOf (arbitrary :: Gen Int)
#endif

instance Arbitrary NewT.TyCon where
#if MIN_VERSION_base(4,4,0)
    arbitrary = NewT.TyCon <$> arbitrary <*> arbitrary <*> arbitrary <*> arbitrary
#else
    arbitrary = NewT.mkTyCon <$> arbitrary
#endif

#if MIN_VERSION_base(4,4,0)
instance Arbitrary Fingerprint where
    arbitrary = Fingerprint <$> arbitrary <*> arbitrary
#endif

#if !(MIN_VERSION_base(4,7,0))
instance Show Fingerprint where
  show (Fingerprint w1 w2) = hex16 w1 ++ hex16 w2
    where
      -- Formats a 64 bit number as 16 digits hex.
      hex16 :: Word64 -> String
      hex16 i = let hex = showHex i ""
                 in replicate (16 - length hex) '0' ++ hex
#endif

instance Arbitrary Dynamic where
    arbitrary = toDyn <$> (arbitrary :: Gen Int)

instance Arbitrary Constr where
    arbitrary = mkConstr <$> arbitrary <*> arbitrary <*> arbitrary <*> arbitrary

instance Arbitrary ConstrRep where
    arbitrary = oneof [ AlgConstr   <$> arbitrary
                      , IntConstr   <$> arbitrary
                      , FloatConstr <$> arbitrary
                      , CharConstr  <$> arbitrary
                      ]

instance Arbitrary DataRep where
    arbitrary = oneof [ AlgRep <$> arbitrary
                      , pure IntRep
                      , pure FloatRep
                      , pure CharRep
                      , pure NoRep
                      ]

instance Arbitrary DataType where
    arbitrary = mkDataType <$> arbitrary <*> arbitrary

deriving instance Bounded D.Fixity
deriving instance Enum D.Fixity
instance Arbitrary D.Fixity where
    arbitrary = arbitraryBoundedEnum

#if MIN_VERSION_base(4,7,0)
instance Coercible a b => Arbitrary (Coercion a b) where
    arbitrary = pure Coercion

instance a ~ b => Arbitrary (a :~: b) where
    arbitrary = pure Refl
#endif

deriving instance Bounded BlockReason
deriving instance Enum BlockReason
instance Arbitrary BlockReason where
    arbitrary = arbitraryBoundedEnum

instance Arbitrary ThreadStatus where
    arbitrary = oneof [ pure ThreadRunning
                      , pure ThreadFinished
                      , ThreadBlocked <$> arbitrary
                      , pure ThreadDied
                      ]

#if !(defined(__GHCJS__))
# if defined(mingw32_HOST_OS)
deriving instance Bounded ConsoleEvent
instance Arbitrary ConsoleEvent where
    arbitrary = arbitraryBoundedEnum
# elif MIN_VERSION_base(4,4,0)
instance Arbitrary Event where
    arbitrary = oneof $ map pure [evtRead, evtWrite]

-- TODO: instance Arbitrary FdKey
# endif
#endif

instance Arbitrary (ST s a) where
    arbitrary = pure $ fixST undefined

instance Arbitrary Handle where
    arbitrary = oneof $ map pure [stdin, stdout, stderr]

instance Arbitrary HandlePosn where
    arbitrary = HandlePosn <$> arbitrary <*> arbitrary

deriving instance Bounded IOMode
instance Arbitrary IOMode where
    arbitrary = arbitraryBoundedEnum

instance Arbitrary BufferMode where
    arbitrary = oneof [ pure NoBuffering
                      , pure LineBuffering
                      , BlockBuffering <$> arbitrary
                      ]

deriving instance Bounded SeekMode
instance Arbitrary SeekMode where
    arbitrary = arbitraryBoundedEnum

deriving instance Bounded Newline
deriving instance Enum Newline
instance Arbitrary Newline where
    arbitrary = arbitraryBoundedEnum

instance Arbitrary NewlineMode where
    arbitrary = NewlineMode <$> arbitrary <*> arbitrary

#if MIN_VERSION_base(4,4,0)
deriving instance Bounded CodingProgress
deriving instance Enum CodingProgress
instance Arbitrary CodingProgress where
    arbitrary = arbitraryBoundedEnum

deriving instance Bounded CodingFailureMode
deriving instance Enum CodingFailureMode
instance Arbitrary CodingFailureMode where
    arbitrary = arbitraryBoundedEnum
#endif

#if MIN_VERSION_base(4,5,0)
instance Arbitrary GCStats where
    arbitrary = GCStats <$> arbitrary <*> arbitrary <*> arbitrary
                        <*> arbitrary <*> arbitrary <*> arbitrary
                        <*> arbitrary <*> arbitrary <*> arbitrary
                        <*> arbitrary <*> arbitrary <*> arbitrary
                        <*> arbitrary <*> arbitrary <*> arbitrary
                        <*> arbitrary <*> arbitrary <*> arbitrary
#endif

#if __GLASGOW_HASKELL__ >= 702
instance Arbitrary (U1 p) where
    arbitrary = pure U1

instance Arbitrary p => Arbitrary (Par1 p) where
    arbitrary = Par1 <$> arbitrary

instance Arbitrary (f p) => Arbitrary (Rec1 f p) where
    arbitrary = Rec1 <$> arbitrary

instance Arbitrary c => Arbitrary (K1 i c p) where
    arbitrary = K1 <$> arbitrary

instance Arbitrary (f p) => Arbitrary (M1 i c f p) where
    arbitrary = M1 <$> arbitrary

instance (Arbitrary (f p), Arbitrary (g p)) => Arbitrary ((f :+: g) p) where
    arbitrary = oneof [L1 <$> arbitrary, R1 <$> arbitrary]

instance (Arbitrary (f p), Arbitrary (g p)) => Arbitrary ((f :*: g) p) where
    arbitrary = (:*:) <$> arbitrary <*> arbitrary

instance Arbitrary (f (g p)) => Arbitrary ((f :.: g) p) where
    arbitrary = Comp1 <$> arbitrary

instance Arbitrary G.Fixity where
    arbitrary = oneof [pure G.Prefix, G.Infix <$> arbitrary <*> arbitrary]

deriving instance Bounded Associativity
deriving instance Enum Associativity
instance Arbitrary Associativity where
    arbitrary = arbitraryBoundedEnum

instance Arbitrary Arity where
    arbitrary = oneof [pure NoArity, Arity <$> arbitrary]
#endif

#if MIN_VERSION_base(4,8,0)
instance Arbitrary ConcFlags where
    arbitrary = ConcFlags <$> arbitrary <*> arbitrary

instance Arbitrary MiscFlags where
    arbitrary = MiscFlags <$> arbitrary <*> arbitrary <*> arbitrary <*> arbitrary

instance Arbitrary DebugFlags where
    arbitrary = DebugFlags <$> arbitrary <*> arbitrary <*> arbitrary
                           <*> arbitrary <*> arbitrary <*> arbitrary
                           <*> arbitrary <*> arbitrary <*> arbitrary
                           <*> arbitrary <*> arbitrary <*> arbitrary
                           <*> arbitrary <*> arbitrary <*> arbitrary

instance Arbitrary TickyFlags where
    arbitrary = TickyFlags <$> arbitrary <*> arbitrary

instance Arbitrary StaticPtrInfo where
    arbitrary = StaticPtrInfo <$> arbitrary <*> arbitrary <*> arbitrary <*> arbitrary
#endif

-- #if MIN_VERSION_base(4,6,0) && !(MIN_VERSION_base(4,7,0))
-- TODO: instance Arbitrary (IsZero n)
-- TODO: instance Arbitrary (IsEven n)
-- #endif

#if MIN_VERSION_base(4,7,0)
instance Arbitrary SomeNat where
    arbitrary = do
        nat <- arbitrary `suchThat` (>= 0)
        case someNatVal nat of
             Just sn -> pure sn
             Nothing -> fail "Negative natural number"

instance Arbitrary SomeSymbol where
    arbitrary = someSymbolVal <$> arbitrary
#endif

instance Arbitrary ConType where
    arbitrary = oneof [pure Rec, pure Tup, pure Pref, Inf <$> arbitrary]

#if MIN_VERSION_base(4,5,0)
deriving instance Arbitrary CChar
deriving instance Arbitrary CSChar
deriving instance Arbitrary CUChar
deriving instance Arbitrary CShort
deriving instance Arbitrary CUShort
deriving instance Arbitrary CInt
deriving instance Arbitrary CUInt
deriving instance Arbitrary CLong
deriving instance Arbitrary CULong
deriving instance Arbitrary CLLong
deriving instance Arbitrary CULLong
deriving instance Arbitrary CFloat
deriving instance Arbitrary CDouble
deriving instance Arbitrary CPtrdiff
deriving instance Arbitrary CSize
deriving instance Arbitrary CWchar
deriving instance Arbitrary CSigAtomic
deriving instance Arbitrary CClock
deriving instance Arbitrary CTime
# if MIN_VERSION_base(4,4,0)
deriving instance Arbitrary CUSeconds
deriving instance Arbitrary CSUSeconds
# endif
deriving instance Arbitrary CIntPtr
deriving instance Arbitrary CUIntPtr
deriving instance Arbitrary CIntMax
deriving instance Arbitrary CUIntMax

# if defined(HTYPE_DEV_T)
deriving instance Arbitrary CDev
# endif
# if defined(HTYPE_INO_T)
deriving instance Arbitrary CIno
# endif
# if defined(HTYPE_MODE_T)
deriving instance Arbitrary CMode
# endif
# if defined(HTYPE_OFF_T)
deriving instance Arbitrary COff
# endif
# if defined(HTYPE_PID_T)
deriving instance Arbitrary CPid
# endif
# if defined(HTYPE_SSIZE_T)
deriving instance Arbitrary CSsize
# endif
# if defined(HTYPE_GID_T)
deriving instance Arbitrary CGid
# endif
# if defined(HTYPE_NLINK_T)
deriving instance Arbitrary CNlink
# endif
# if defined(HTYPE_UID_T)
deriving instance Arbitrary CUid
# endif
# if defined(HTYPE_CC_T)
deriving instance Arbitrary CCc
# endif
# if defined(HTYPE_SPEED_T)
deriving instance Arbitrary CSpeed
# endif
# if defined(HTYPE_TCFLAG_T)
deriving instance Arbitrary CTcflag
# endif
# if defined(HTYPE_RLIM_T)
deriving instance Arbitrary CRLim
# endif
#else
instance Arbitrary CChar where
    arbitrary = arbitrarySizedBoundedIntegral

instance Arbitrary CSChar where
    arbitrary = arbitrarySizedBoundedIntegral

instance Arbitrary CUChar where
    arbitrary = arbitrarySizedBoundedIntegral

instance Arbitrary CShort where
    arbitrary = arbitrarySizedBoundedIntegral

instance Arbitrary CUShort where
    arbitrary = arbitrarySizedBoundedIntegral

instance Arbitrary CInt where
    arbitrary = arbitrarySizedBoundedIntegral

instance Arbitrary CUInt where
    arbitrary = arbitrarySizedBoundedIntegral

instance Arbitrary CLong where
    arbitrary = arbitrarySizedBoundedIntegral

instance Arbitrary CULong where
    arbitrary = arbitrarySizedBoundedIntegral

instance Arbitrary CLLong where
    arbitrary = arbitrarySizedBoundedIntegral

instance Arbitrary CULLong where
    arbitrary = arbitrarySizedBoundedIntegral

instance Arbitrary CFloat where
    arbitrary = arbitrarySizedFractional

instance Arbitrary CDouble where
    arbitrary = arbitrarySizedFractional

instance Arbitrary CPtrdiff where
    arbitrary = arbitrarySizedBoundedIntegral

instance Arbitrary CSize where
    arbitrary = arbitrarySizedBoundedIntegral

instance Arbitrary CWchar where
    arbitrary = arbitrarySizedBoundedIntegral

instance Arbitrary CSigAtomic where
    arbitrary = arbitrarySizedBoundedIntegral

instance Arbitrary CClock where
    arbitrary = unsafeCoerce# (arbitrary :: Gen HTYPE_CLOCK_T)

instance Arbitrary CTime where
    arbitrary = unsafeCoerce# (arbitrary :: Gen HTYPE_TIME_T)

# if MIN_VERSION_base(4,4,0)
instance Arbitrary CUSeconds where
    arbitrary = unsafeCoerce# (arbitrary :: Gen HTYPE_USECONDS_T)

instance Arbitrary CSUSeconds where
    arbitrary = unsafeCoerce# (arbitrary :: Gen HTYPE_SUSECONDS_T)
# endif

instance Arbitrary CIntPtr where
    arbitrary = arbitrarySizedBoundedIntegral

instance Arbitrary CUIntPtr where
    arbitrary = arbitrarySizedBoundedIntegral

instance Arbitrary CIntMax where
    arbitrary = arbitrarySizedBoundedIntegral

instance Arbitrary CUIntMax where
    arbitrary = arbitrarySizedBoundedIntegral

# if defined(HTYPE_DEV_T)
instance Arbitrary CDev where
    arbitrary = unsafeCoerce# (arbitrary :: Gen HTYPE_DEV_T)
# endif
# if defined(HTYPE_INO_T)
instance Arbitrary CIno where
    arbitrary = arbitrarySizedBoundedIntegral
# endif
# if defined(HTYPE_MODE_T)
instance Arbitrary CMode where
    arbitrary = arbitrarySizedBoundedIntegral
# endif
# if defined(HTYPE_OFF_T)
instance Arbitrary COff where
    arbitrary = arbitrarySizedBoundedIntegral
# endif
# if defined(HTYPE_PID_T)
instance Arbitrary CPid where
    arbitrary = arbitrarySizedBoundedIntegral
# endif
# if defined(HTYPE_SSIZE_T)
instance Arbitrary CSsize where
    arbitrary = arbitrarySizedBoundedIntegral
# endif
# if defined(HTYPE_GID_T)
instance Arbitrary CGid where
    arbitrary = arbitrarySizedBoundedIntegral
# endif
# if defined(HTYPE_NLINK_T)
instance Arbitrary CNlink where
    arbitrary = arbitrarySizedBoundedIntegral
# endif
# if defined(HTYPE_UID_T)
instance Arbitrary CUid where
    arbitrary = arbitrarySizedBoundedIntegral
# endif
# if defined(HTYPE_CC_T)
instance Arbitrary CCc where
    arbitrary = unsafeCoerce# (arbitrary :: Gen HTYPE_CC_T)
# endif
# if defined(HTYPE_SPEED_T)
instance Arbitrary CSpeed where
    arbitrary = unsafeCoerce# (arbitrary :: Gen HTYPE_SPEED_T)
# endif
# if defined(HTYPE_TCFLAG_T)
instance Arbitrary CTcflag where
    arbitrary = arbitrarySizedBoundedIntegral
# endif
# if defined(HTYPE_RLIM_T)
instance Arbitrary CRLim where
    arbitrary = arbitrarySizedBoundedIntegral
# endif
#endif

deriving instance Arbitrary Fd

instance Arbitrary ExitCode where
    arbitrary = oneof [pure ExitSuccess, ExitFailure <$> arbitrary]

deriving instance Arbitrary All
deriving instance Arbitrary Any
deriving instance Arbitrary a => Arbitrary (Dual a)
deriving instance Arbitrary a => Arbitrary (First a)
deriving instance Arbitrary a => Arbitrary (Last a)
deriving instance Arbitrary a => Arbitrary (Product a)
deriving instance Arbitrary a => Arbitrary (Sum a)
#if MIN_VERSION_base(4,8,0)
deriving instance Arbitrary (f a) => Arbitrary (Alt f a)
#endif
deriving instance Arbitrary a => Arbitrary (Const a b)
deriving instance Arbitrary a => Arbitrary (ZipList a)
#if MIN_VERSION_base(4,6,0)
deriving instance Arbitrary a => Arbitrary (Down a)
#endif
deriving instance Arbitrary a => Arbitrary (Identity a)

deriving instance Arbitrary a => Arbitrary (FromStringShow a)
deriving instance Arbitrary a => Arbitrary (FromTextShow a)
