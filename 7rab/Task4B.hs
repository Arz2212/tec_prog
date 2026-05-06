-- Задача 4Б: Тип данных «многочлен с целыми коэффициентами»
-- с операциями сложения, умножения, дифференцирования и
-- взятия противоположного элемента.
--
-- Многочлен представлен списком коэффициентов от младшей степени:
--   [a0, a1, a2, ...]  ←→  a0 + a1·x + a2·x² + ...

module Task4B where

import Data.List (dropWhileEnd)

-- | Многочлен с целыми коэффициентами.
-- Хранится в нормализованном виде: без хвостовых нулей.
newtype Polynomial = Poly { coeffs :: [Integer] }
    deriving (Eq)

instance Show Polynomial where
    show (Poly [])  = "0"
    show (Poly cs)  = formatTerms 0 cs
      where
        formatTerms _ [] = ""
        formatTerms n (c:rest)
            | c == 0     = formatTerms (n+1) rest
            | n == 0     = show c ++ restStr
            | n == 1     = (if c == 1 then "" else if c == -1 then "-" else show c)
                         ++ "x" ++ restStr
            | otherwise  = (if c == 1 then "" else if c == -1 then "-" else show c)
                         ++ "x^" ++ show n ++ restStr
          where
            restStr = case dropWhile (==0) rest of
                []     -> ""
                (r:rs) -> if r > 0 then " + " ++ formatTerms (n+1) rest
                          else " - " ++ formatTerms (n+1) (map abs rest)

-- | Нормализация: обрезаем хвостовые нули.
normalize :: [Integer] -> [Integer]
normalize = dropWhileEnd (== 0)

-- | Многочлен из списка коэффициентов.
fromCoeffs :: [Integer] -> Polynomial
fromCoeffs = Poly . normalize

-- | Степень многочлена. -1 для нулевого.
degree :: Polynomial -> Int
degree (Poly cs) = length cs - 1

-- | Сложение многочленов.
addPoly :: Polynomial -> Polynomial -> Polynomial
addPoly (Poly as) (Poly bs) = fromCoeffs $ zipWithLong (+) as bs
  where
    zipWithLong f xs ys = zipWith f xs ys ++ drop (min (length xs) (length ys)) (if length xs > length ys then xs else ys)

-- | Противоположный многочлен.
negatePoly :: Polynomial -> Polynomial
negatePoly (Poly cs) = Poly $ map negate cs

-- | Умножение многочленов (свёртка).
mulPoly :: Polynomial -> Polynomial -> Polynomial
mulPoly (Poly as) (Poly bs) =
    fromCoeffs $ take (lenA + lenB - 1) [ conv k | k <- [0..] ]
  where
    lenA = length as
    lenB = length bs
    conv k = sum [ (as !! i) * (bs !! (k - i))
                 | i <- [max 0 (k - lenB + 1) .. min (lenA - 1) k] ]

-- | Дифференцирование многочлена.
derivePoly :: Polynomial -> Polynomial
derivePoly (Poly [])  = Poly []
derivePoly (Poly (_:cs)) = fromCoeffs $ zipWith (*) [1..] cs
