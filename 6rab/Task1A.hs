-- Задача 1А: Найти все числа от 1 до 100, делящиеся на 4.

module Task1A where

divisibleBy4 :: [Int]
divisibleBy4 = [x | x <- [1..100], x `mod` 4 == 0]
