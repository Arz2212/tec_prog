-- Тесты для задачи 2А: произведение трёх трёхзначных чисел

import Task2A

main :: IO ()
main = do
    putStrLn "=== Тесты задачи 2А: произведение трёх трёхзначных ==="

    let testCases =
            [ (100 * 100 * 100,     True,  "100*100*100 = 1,000,000")
            , (999 * 999 * 999,     True,  "999*999*999 = 997,002,999")
            , (100 * 200 * 300,     True,  "100*200*300 = 6,000,000")
            , (500 * 600 * 700,     True,  "500*600*700 = 210,000,000")
            , (123 * 456 * 789,     True,  "123*456*789 = 44,269,032")
            , (999999,              False, "999,999 < 1,000,000")
            , (0,                   False, "0")
            , (1,                   False, "1")
            , (500000,              False, "500,000 < минимума")
            , (997003000,           False, "997,003,000 > максимума")
            , (100 * 100 * 101,     True,  "100*100*101 = 1,010,000")
            -- Проверка с отрицательным: произведение трёх трёхзначных НЕ может быть отрицательным
            -- так как все трёхзначные положительны, но на вход может прийти что угодно
            , (-1000000,            False, "отрицательное")
            ]

    let passed = length [() | (n, expected, _) <- testCases,
                              isProductOfThreeThreeDigit n == expected]
    let total  = length testCases

    mapM_ runTest testCases

    putStrLn $ "\nПройдено: " ++ show passed ++ "/" ++ show total
    if passed == total
        then putStrLn "✓ Все тесты задачи 2А пройдены"
        else fail "Некоторые тесты НЕ пройдены"

runTest :: (Integer, Bool, String) -> IO ()
runTest (n, expected, desc) = do
    let result = isProductOfThreeThreeDigit n
    let ok = result == expected
    putStrLn $ "  " ++ (if ok then "✓" else "✗") ++ " " ++ desc
            ++ " → " ++ show result
            ++ (if not ok then " (ожидалось " ++ show expected ++ ")" else "")
