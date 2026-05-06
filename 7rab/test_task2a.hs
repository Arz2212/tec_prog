-- Тесты для задачи 2А: все целочисленные точки (x,y)

import Task2A
import Data.List (nub)

main :: IO ()
main = do
    putStrLn "=== Тесты задачи 2А: все целочисленные точки ==="

    let pts   = take 25 allPoints
    let first = take 9 allPoints  -- (0,0) + кольцо k=1 (8 точек)

    -- Тест 1: первая точка (0,0)
    check "Первая точка (0,0)" (head allPoints) (0,0 :: Integer)

    -- Тест 2: первые 25 точек — ровно 25 (1 + 8 + 16)
    check "Количество: 25 точек" (length pts) (25 :: Int)

    -- Тест 3: все точки в первых 25 лежат в [-2,2]×[-2,2]
    let inRange = all (\(x,y) -> abs x <= 2 && abs y <= 2) pts
    check "Все точки в [-2,2]×[-2,2]" inRange True

    -- Тест 4: нет дубликатов
    check "Нет дубликатов в первых 25" (length (nub pts)) (25 :: Int)

    -- Тест 5: проверка наличия ключевых точек в первых 9
    let expectedPoints = [(0,0),(1,-1),(1,0),(1,1),(-1,-1),(-1,0),(-1,1),(0,-1),(0,1)]
    let allPresent = all (`elem` first) expectedPoints
    check "Все 9 точек кольца k=0,1 на месте" allPresent True

    -- Тест 6: первые 25 включают углы кольца k=2
    let first25 = take 25 allPoints
    check "Содержит (2,2)" ((2,2 :: Integer) `elem` first25) True
    check "Содержит (-2,-2)" ((-2,-2 :: Integer) `elem` first25) True
    check "Содержит (2,-2)" ((2,-2 :: Integer) `elem` first25) True
    check "Содержит (-2,2)" ((-2,2 :: Integer) `elem` first25) True

    putStrLn "\n✓ Все тесты задачи 2А завершены"


-- Простая проверка с выводом
check :: (Eq a, Show a) => String -> a -> a -> IO ()
check name actual expected = do
    let ok = actual == expected
    putStrLn $ "  " ++ (if ok then "✓" else "✗") ++ " " ++ name
            ++ (if not ok then " → получено " ++ show actual
                           ++ " (ожидалось " ++ show expected ++ ")" else "")
    if not ok then fail "Тест не пройден" else return ()
