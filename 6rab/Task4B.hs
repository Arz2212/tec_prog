-- Задача 4Б: Дан список непустых списков.
-- Найти среднее из максимальных значений элементов.

module Task4B where

averageOfMaxValues :: [[Double]] -> Double
averageOfMaxValues lists =
    let maxVals = map maximum lists
        count   = length lists
    in  sum maxVals / fromIntegral count
