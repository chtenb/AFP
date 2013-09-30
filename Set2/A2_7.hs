{-# LANGUAGE FlexibleContexts #-}
module A2_7 where
import Control.Monad
import Control.Monad.State

type Object a = a -> a -> a
data X = X {n :: Int, f :: Int -> Int}
data Step a b = Enter a
              | Return b
                deriving Show
{-
data X = X Int (Int -> Int)

n (X n _) = n
f (X _ f) = f
-}

x, y, z :: Object X
x super this = X {n = 0, f = \i -> i + n this}
y super this = super {n = 1}
z super this = super {f = f super . f super}

fixObject :: Object a -> a
fixObject o = o (error "super") (fixObject o)

extendedBy :: Object a -> Object a -> Object a
extendedBy o1 o2 super this = o2 (o1 super this) this

fac :: Monad m => Object (Int -> m Int)
fac super this n = case n of
    0 -> return 1
    n -> liftM (n*) (this (n - 1))

calls :: MonadState Int m => Object (a -> m b)
calls super this n = do
    modify (+1)
    super n

-- Look at what the type of fixObject is and familiarize yourself with
-- the behaviour of fixObject by trying the following expressions:
-- n (fixObject x)
-- f (fixObject x) 5
-- n (fixObject y)
-- f (fixObject y) 5
-- n (fixObject (x `extendedBy` y))
-- f (fixObject (x `extendedBy` y)) 5
-- f (fixObject (x `extendedBy` y `extendedBy` z)) 5
-- f (fixObject (x `extendedBy` y `extendedBy` z `extendedBy` z)) 5


-- The zero object
zero :: Object a
zero super this = this


-- The trace object


test = runState (fixObject (fac `extendedBy` zero) 5) 0 -- Ok, I admit, I don't understand everything comletely :S