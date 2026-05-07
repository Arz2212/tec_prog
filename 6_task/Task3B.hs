-- Задача 3Б: Определить, состоит ли данная строка из трёх слов
-- (в начале строки, в конце и между словами может присутствовать
-- любое количество пробелов).

module Task3B where

consistsOfThreeWords :: String -> Bool
consistsOfThreeWords s = length (words s) == 3
