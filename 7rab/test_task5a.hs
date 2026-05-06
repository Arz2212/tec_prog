-- Тесты для задачи 5А: конечное поле GF(q)

import Task5A

main :: IO ()
main = do
    putStrLn "=== Тесты задачи 5А: конечное поле ==="

    -- Поле GF(5)
    let a2 = GF 2 5
    let a3 = GF 3 5
    let a0 = GF 0 5
    let a1 = GF 1 5
    let a4 = GF 4 5

    putStrLn "--- GF(5) ---"
    check "2 + 3 = 0"        (addGF a2 a3) (GF 0 5)
    check "2 * 3 = 1"        (mulGF a2 a3) (GF 1 5)
    check "-2 = 3"           (negateGF a2) (GF 3 5)
    check "2⁻¹ = 3 (2·3=6≡1)" (invGF a2) (GF 3 5)
    check "4 * 4 = 1"        (mulGF a4 a4) (GF 1 5)
    check "0 + 4 = 4"        (addGF a0 a4) a4
    check "1⁻¹ = 1"          (invGF a1) a1
    check "4⁻¹ = 4"          (invGF a4) a4
    check "-(3) = 2"         (negateGF a3) (GF 2 5)

    -- Поле GF(7)
    let b2 = GF 2 7
    let b3 = GF 3 7
    let b5 = GF 5 7
    let b4 = GF 4 7
    let b6 = GF 6 7

    putStrLn "--- GF(7) ---"
    check "5 + 3 = 1"        (addGF b5 b3) (GF 1 7)
    check "4 * 2 = 1"        (mulGF b4 b2) (GF 1 7)
    check "-3 = 4"           (negateGF b3) (GF 4 7)
    check "3⁻¹ = 5 (3·5=15≡1)" (invGF b3) (GF 5 7)
    check "6⁻¹ = 6"          (invGF b6) b6

    putStrLn "\n✓ Все тесты задачи 5А завершены"


check :: (Eq a, Show a) => String -> a -> a -> IO ()
check name actual expected = do
    let ok = actual == expected
    putStrLn $ "  " ++ (if ok then "✓" else "✗") ++ " " ++ name
            ++ (if not ok then " → получено " ++ show actual
                           ++ " (ожидалось " ++ show expected ++ ")" else "")
    if not ok then fail "Тест не пройден" else return ()
