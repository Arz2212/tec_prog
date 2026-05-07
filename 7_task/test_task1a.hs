-- Тесты для задачи 1А: циклический повтор списка

import Task1A

main :: IO ()
main = do
    putStrLn "=== Тесты задачи 1А: циклический повтор ==="

    -- Тесты с целыми числами
    check "[1,2,3] × 10"
        (take 10 (cyclicRepeat [1,2,3 :: Int]))
        [1,2,3,1,2,3,1,2,3,1]

    check "[42] × 7"
        (take 7 (cyclicRepeat [42 :: Int]))
        [42,42,42,42,42,42,42]

    check "[1,2] × 0"
        (take 0 (cyclicRepeat [1,2 :: Int]))
        ([] :: [Int])

    -- Тесты со строками
    check "\"ab\" × 5"
        (take 5 (cyclicRepeat "ab" :: String))
        "ababa"

    -- Тесты с Bool
    check "[True,False] × 6"
        (take 6 (cyclicRepeat [True, False]))
        [True,False,True,False,True,False]

    putStrLn "\n✓ Все тесты задачи 1А завершены"


check :: (Eq a, Show a) => String -> a -> a -> IO ()
check name actual expected = do
    let ok = actual == expected
    putStrLn $ "  " ++ (if ok then "✓" else "✗") ++ " " ++ name
            ++ (if not ok then " → получено " ++ show actual
                           ++ " (ожидалось " ++ show expected ++ ")" else "")
    if not ok then fail "Тест не пройден" else return ()
