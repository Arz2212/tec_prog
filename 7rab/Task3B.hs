-- Задача 3Б: Бесконечный список элементов геометрической
-- прогрессии с основанием init и показателем ratio.
-- Пример: init=3, ratio=2 → [3, 6, 12, 24, 48, ..]

module Task3B where

geomProgression :: Double -> Double -> [Double]
geomProgression init ratio = iterate (* ratio) init
