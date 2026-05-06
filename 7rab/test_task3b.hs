-- Тесты для задачи 3Б: геометрическая прогрессия

import Task3B

main :: IO ()
main = do
    putStrLn "=== Тесты задачи 3Б: геометрическая прогрессия ==="

    let eps = 1e-9
    let tests =
            [ ("init=3, ratio=2 × 5",    take 5 (geomProgression 3 2),
               [3.0, 6.0, 12.0, 24.0, 48.0])
            , ("init=1, ratio=1 × 4",    take 4 (geomProgression 1 1),
               [1.0, 1.0, 1.0, 1.0])
            , ("init=5, ratio=0.5 × 5",  take 5 (geomProgression 5 0.5),
               [5.0, 2.5, 1.25, 0.625, 0.3125])
            , ("init=10, ratio=3 × 1",   take 1 (geomProgression 10 3),
               [10.0])
            , ("init=2, ratio=(-1) × 6", take 6 (geomProgression 2 (-1)),
               [2.0, -2.0, 2.0, -2.0, 2.0, -2.0])
            , ("init=1, ratio=2 × 8",    take 8 (geomProgression 1 2),
               [1.0, 2.0, 4.0, 8.0, 16.0, 32.0, 64.0, 128.0])
            ]

    let passed = length [() | (_, actual, expected) <- tests,
                              and (zipWith (\a b -> abs (a - b) < eps) actual expected)]
    let total  = length tests

    mapM_ (\(desc, actual, expected) ->
        let ok = and (zipWith (\a b -> abs (a - b) < eps) actual expected)
        in putStrLn $ "  " ++ (if ok then "✓" else "✗") ++ " " ++ desc
                ++ (if not ok then " → получено " ++ show actual
                               ++ " (ожидалось " ++ show expected ++ ")" else "")
        ) tests

    putStrLn $ "\nПройдено: " ++ show passed ++ "/" ++ show total
    if passed == total
        then putStrLn "✓ Все тесты задачи 3Б пройдены"
        else fail "Некоторые тесты НЕ пройдены"
