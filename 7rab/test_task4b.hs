-- Тесты для задачи 4Б: многочлен с целыми коэффициентами

import Task4B

main :: IO ()
main = do
    putStrLn "=== Тесты задачи 4Б: многочлены ==="

    let zero = fromCoeffs []
    let p1   = fromCoeffs [1, 2, 1]    -- 1 + 2x + x²
    let p2   = fromCoeffs [1, -2, 1]   -- 1 - 2x + x²
    let p3   = fromCoeffs [1, 1]       -- 1 + x
    let p4   = fromCoeffs [3, 0, 1]    -- 3 + x²
    let p5   = fromCoeffs [0, 0, 2]    -- 2x²

    -- Сложение
    check "p1 + p2 = 2 + 2x²"   (addPoly p1 p2) (fromCoeffs [2, 0, 2])
    check "p1 + zero = p1"      (addPoly p1 zero) p1
    check "p3 + p3 = 2 + 2x"    (addPoly p3 p3) (fromCoeffs [2, 2])

    -- Умножение
    check "(1+x)² = 1 + 2x + x²" (mulPoly p3 p3) (fromCoeffs [1, 2, 1])
    check "p3 * zero = zero"    (mulPoly p3 zero) zero
    check "(2x²) * (1+x) = 2x² + 2x³" (mulPoly (fromCoeffs [0,0,2]) (fromCoeffs [1,1]))
                                       (fromCoeffs [0,0,2,2])

    -- Дифференцирование
    check "d/dx(3 + x²) = 2x"   (derivePoly p4) (fromCoeffs [0, 2])
    check "d/dx(1+2x+x²) = 2+2x" (derivePoly p1) (fromCoeffs [2, 2])
    check "d/dx(const) = 0"     (derivePoly (fromCoeffs [5])) zero
    check "d/dx(0) = 0"         (derivePoly zero) zero

    -- Противоположный
    check "-p1 = -1 - 2x - x²"  (negatePoly p1) (fromCoeffs [-1, -2, -1])
    check "--p1 = p1"           (negatePoly (negatePoly p1)) p1

    -- Степень
    check "deg(p1) = 2"         (degree p1) (2 :: Int)
    check "deg(const) = 0"      (degree (fromCoeffs [42])) (0 :: Int)
    check "deg(zero) = -1"      (degree zero) (-1 :: Int)

    putStrLn "\n✓ Все тесты задачи 4Б завершены"


check :: (Eq a, Show a) => String -> a -> a -> IO ()
check name actual expected = do
    let ok = actual == expected
    putStrLn $ "  " ++ (if ok then "✓" else "✗") ++ " " ++ name
            ++ (if not ok then " → получено " ++ show actual
                           ++ " (ожидалось " ++ show expected ++ ")" else "")
    if not ok then fail "Тест не пройден" else return ()
