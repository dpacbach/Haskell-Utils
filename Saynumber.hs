module Saynumber (sayNumber) where

import Data.List (genericIndex)
import Utils

--------------------------------------------------------------------------------
-- Say an integer in English form

hundreds = splitC ",one hundred,two hundred,three hundred,four hundred,five hundred,six hundred,seven hundred,eight hundred,nine hundred"
oneTo9   = splitC ",one,two,three,four,five,six,seven,eight,nine"
teens    = splitC "ten,eleven,twelve,thirteen,fourteen,fifteen,sixteen,seventeen,eighteen,nineteen"
tens     = splitC "twenty,thirty,forty,fifty,sixty,seventy,eighty,ninety"
ranks    = splitC ",thousand,million,billion,trillion,quadrillion"

sayNumber :: (Integral a) => a -> String
sayNumber n
    | (n == 0) = "zero"
    | (n <  0) = "negative " ++ sayNumber (-n)
    | (n >  0) = join ", " · reverse · map joinStripPair · remove (null · fst) · (`zip` ranks') · map oneTo999 · map (`mod` 1000) · takeWhile (>0) · iterate (`div` 1000) $ n

        where ranks'   = ranks ++ (tail ranks') `zipSpace` (repeat · last $ ranks)
              oneTo999 = genericIndex       [joinStripPair (x,y) | x <- hundreds, y <- oneTo99]
              oneTo99  = oneTo9 ++ teens ++ [joinStripPair (x,y) | x <- tens,     y <- oneTo9]

--------------------------------------------------------------------------------
-- Tests for sayNumber

runTests = and sayNumberTests
sayNumberTests = [sayNumber 0      == "zero",
                  sayNumber 1      == "one",
                  sayNumber 10     == "ten",
                  sayNumber 13     == "thirteen",
                  sayNumber 85     == "eighty five",
                  sayNumber 100    == "one hundred",
                  sayNumber 101    == "one hundred one",
                  sayNumber 1000   == "one thousand",
                  sayNumber 1017   == "one thousand, seventeen",
                  sayNumber 1234   == "one thousand, two hundred thirty four",
                  sayNumber (-4)   == "negative four",
                  sayNumber large1 == "two million quadrillion, three hundred twenty three thousand quadrillion, " ++
                                      "four hundred thirty four quadrillion, five hundred eleven trillion, "       ++
                                      "three hundred forty three billion, four hundred thirty four million, "      ++
                                      "three hundred forty three thousand, four hundred thirty four",
                  sayNumber large2 == "one hundred forty nine billion quadrillion, one thousand quadrillion, " ++
                                      "four hundred forty four quadrillion, five billion, seven hundred eighty million"]

                  where large1 = 2323434511343434343434      :: Integer
                        large2 = 149000001444000005780000000 :: Integer
