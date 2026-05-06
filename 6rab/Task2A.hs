-- Задача 2А: Определить, является ли данное целое число
-- произведением трёх трёхзначных целых чисел.

module Task2A where

-- Минимальное и максимальное трёхзначное число
min3 :: Integer
min3 = 100

max3 :: Integer
max3 = 999

-- Минимальное и максимальное произведение трёх трёхзначных чисел
minProduct :: Integer
minProduct = min3 * min3 * min3  -- 1,000,000

maxProduct :: Integer
maxProduct = max3 * max3 * max3  -- 997,002,999

-- Проверка: является ли m произведением двух трёхзначных чисел
isProductOfTwoThreeDigit :: Integer -> Bool
isProductOfTwoThreeDigit m = any check [min3..max3]
  where
    check b = m `mod` b == 0 && let c = m `div` b in c >= min3 && c <= max3

-- Основная функция
isProductOfThreeThreeDigit :: Integer -> Bool
isProductOfThreeThreeDigit n
  | n < minProduct || n > maxProduct = False
  | otherwise = any check [min3..max3]
  where
    check a = n `mod` a == 0 && isProductOfTwoThreeDigit (n `div` a)
