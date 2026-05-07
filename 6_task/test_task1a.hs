-- Тесты для задачи 1А: числа от 1 до 100, делящиеся на 4

import Task1A

main :: IO ()
main = do
    putStrLn "=== Тесты задачи 1А: числа от 1 до 100, делящиеся на 4 ==="
    let result = divisibleBy4

    -- Тест 1: количество элементов
    let count = length result
    check "Количество элементов = 25" (count == 25) (show count)

    -- Тест 2: все элементы в диапазоне [1..100]
    let allInRange = all (\x -> x >= 1 && x <= 100) result
    check "Все элементы ∈ [1..100]" allInRange (show allInRange)

    -- Тест 3: все элементы делятся на 4
    let allDivBy4 = all (\x -> x `mod` 4 == 0) result
    check "Все элементы делятся на 4" allDivBy4 (show allDivBy4)

    -- Тест 4: проверка конкретных значений
    let expected = [4,8,12,16,20,24,28,32,36,40,44,48,52,56,60,64,68,72,76,80,84,88,92,96,100]
    check "Соответствие ожидаемому списку" (result == expected) (show result)

    let allPassed = count == 25 && allInRange && allDivBy4 && result == [4,8,12,16,20,24,28,32,36,40,44,48,52,56,60,64,68,72,76,80,84,88,92,96,100]
    if allPassed
        then putStrLn "\n✓ Все тесты задачи 1А пройдены"
        else fail "Некоторые тесты НЕ пройдены"

check :: String -> Bool -> String -> IO ()
check name passed info =
    putStrLn $ "  " ++ (if passed then "✓" else "✗") ++ " " ++ name
           ++ (if not passed then " (получено: " ++ info ++ ")" else "")
