-- ──────────────────────────────────────────────────────────────
-- Justification
-- ──────────────────────────────────────────────────────────────
module Justify (justify) where

import Data.Char  (ord)
import Data.List  (sort, group)
import Data.Maybe (fromMaybe)
import Safe       (lastMay)
import Utils      (merge)

-- Describes the strategy used to justify
data Strategy = FromLeft | FromRight | Centered
  deriving (Enum, Bounded)

numStrategies :: Int
numStrategies = (+1) $ fromEnum $ (maxBound :: Strategy)

-- Generate  an  infinite  sequence of indices which are to repre-
-- sent  the  positions of "slots" between words. The sequence of
-- indices in the returned list determines the order in which  in-
-- dividual space characters are  distributed  among  slots  when
-- justifying a line. This sequence can  be generated by any of a
-- number  of  different  "strategies."  The parameter indicating
-- strategy will be mod'ed by  the  number  of strategies and the
-- result  used to select the strategy. This could be a random in-
-- teger, or some integer derived  from  the  content of the line
-- over which the distribution is happening.
distribute :: Int -> Int -> [Int]
distribute s n | n <= 0    = []
               | otherwise = cycle $ d s' n
  where
    s' :: Strategy
    s' = toEnum (s`mod`numStrategies)

    d Centered  n = [0..n-1]`merge`reverse [0..n-1]
    d FromLeft  n = [0..n-1]
    d FromRight n = reverse [0..n-1]

-- Basically  like  "unwords"  except  it takes an integer and it
-- will ensure that the returned string  contains  enough  spaces
-- between words so as to  span  a  length  equal to that integer.
-- Exceptions to that are if a  line  contains only a single word.
justify_ :: Int -> [String] -> String
justify_ w xs = concat $ merge xs  $ map (spaces . length) $ group
              $ sort   $ take need $ distribute seed $ length xs-1
  where
    need = w - length (concat xs) + punctuation

    -- Here we return 1 if there is a "light" punctuation mark at
    -- the end of the last word. In that case, we want to add one
    -- extra space during the justification in order to push that
    -- puncuation mark outside of the column limit since it seems
    -- too  look  better  in  that  it gives the paragraph a more
    -- straight looking edge. Otherwise, we return 0.
    punctuation = fromEnum $ fromMaybe False $ do
        s <- lastMay xs
        c <- lastMay s
        return (c`elem`",.-")

    spaces :: Int -> String
    spaces n = replicate n ' '

    seed :: Int
    seed = sum $ map ord $ concat $ xs

-- This function will take the  words  on  a single line and will
-- check to see if there would be an "excessive" number of spaces
-- in  it  were  it  to  be justified. If so, then it will return
-- False which is supposed to mean that  it  shouldn't  be  justi-
-- fied. This is to prevent lines  from appearing where the words
-- are too spread out  and  there  are  too  many spaces. The two
-- weighting  numbers  used  in the length comparison were chosen
-- since they seem to  produce  reasonable-looking  output  (note
-- that only their ratio is relevant).
shouldJustify :: Int -> [String] -> Bool
shouldJustify n ws = (89*n < 100*noJust) && (n >= noJust)
  where noJust = length $ unwords $ ws

-- Will justify when appropriate
justify :: Int -> [String] -> String
justify n ws | shouldJustify n ws = justify_ n ws
             | otherwise          = unwords ws
