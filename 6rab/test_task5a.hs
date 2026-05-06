-- Тесты для задачи 5А: делители натурального числа

import Task5A
import Data.List (sort)

main :: IO ()
main = do
    putStrLn "=== Тесты задачи 5А: делители натурального числа ==="

    let testCases =
            [ (1,   [1],                      "число 1")
            , (24,  [1,2,3,4,6,8,12,24],      "число 24")
            , (7,   [1,7],                     "простое число 7")
            , (12,  [1,2,3,4,6,12],           "число 12")
            , (36,  [1,2,3,4,6,9,12,18,36],   "число 36")
            , (100, [1,2,4,5,10,20,25,50,100],"число 100")
            , (2,   [1,2],                     "простое число 2")
            , (9,   [1,3,9],                   "квадрат 3² = 9")
            ]

    let passed = length [() | (n, expected, _) <- testCases,
                              sort (divisors n) == expected]
    let total  = length testCases

    mapM_ runTest testCases

    putStrLn $ "\nПройдено: " ++ show passed ++ "/" ++ show total
    if passed == total
        then putStrLn "✓ Все тесты задачи 5А пройдены"
        else fail "Некоторые тесты НЕ пройдены"

runTest :: (Integer, [Integer], String) -> IO ()
runTest (n, expected, desc) = do
    let result = sort (divisors n)
    let ok = result == expected
    putStrLn $ "  " ++ (if ok then "✓" else "✗") ++ " " ++ desc
            ++ (if not ok then " → получено " ++ show result ++ " (ожидалось " ++ show expected ++ ")" else "")
