-- Тесты для задачи 4Б: среднее из максимальных значений элементов

import Task4B

main :: IO ()
main = do
    putStrLn "=== Тесты задачи 4Б: среднее из максимальных значений ==="

    let eps = 1e-9

    let testCases =
            [ ([[1,2,3],[4,5,6],[7,8,9]],   6.0,  "[[1,2,3],[4,5,6],[7,8,9]] → (3+6+9)/3 = 6")
            , ([[5],[10],[15]],              10.0, "[[5],[10],[15]] → (5+10+15)/3 = 10")
            , ([[1,5,3],[2,8,4]],            6.5,  "[[1,5,3],[2,8,4]] → (5+8)/2 = 6.5")
            , ([[100]],                       100.0,"[[100]] → 100/1 = 100")
            , ([[1,1,1],[2,2,2]],            1.5,  "[[1,1,1],[2,2,2]] → (1+2)/2 = 1.5")
            , ([[0,0,0],[0,0,0],[0,0,0]],    0.0,  "все нули → 0")
            , ([[1.5,2.5,3.5],[4.5,5.5]],    4.5,  "дробные: (3.5+5.5)/2 = 4.5")
            , ([[-5,-3,-1],[-10,-2,-8]],     -1.5, "отрицательные: (-1 + (-2))/2 = -1.5")
            ]

    let passed = length [() | (lists, expected, _) <- testCases,
                              abs (averageOfMaxValues lists - expected) < eps]
    let total  = length testCases

    mapM_ runTest testCases

    putStrLn $ "\nПройдено: " ++ show passed ++ "/" ++ show total
    if passed == total
        then putStrLn "✓ Все тесты задачи 4Б пройдены"
        else do
            putStrLn "✗ Некоторые тесты НЕ пройдены"
            fail "Тесты не пройдены"

runTest :: ([[Double]], Double, String) -> IO ()
runTest (lists, expected, desc) = do
    let result = averageOfMaxValues lists
    let ok = abs (result - expected) < 1e-9
    putStrLn $ "  " ++ (if ok then "✓" else "✗") ++ " " ++ desc
            ++ (if not ok then " → получено " ++ show result ++ " (ожидалось " ++ show expected ++ ")" else "")
