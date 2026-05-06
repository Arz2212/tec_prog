-- Задача 5А: Тип данных «конечное поле заданного порядка q»
-- с операциями сложения, умножения, взятия противоположного
-- и обратного элементов.
--
-- Предполагается, что q — простое число.
-- Элементы поля: целые числа по модулю q.

module Task5A where

-- | Элемент конечного поля GF(q): (значение, модуль q)
data GF = GF Integer Integer
    deriving (Eq)

instance Show GF where
    show (GF v _) = show v

-- | Значение элемента
value :: GF -> Integer
value (GF v _) = v

-- | Модуль поля
modulus :: GF -> Integer
modulus (GF _ q) = q

-- | Сложение в GF(q)
addGF :: GF -> GF -> GF
addGF (GF a q) (GF b _) = GF ((a + b) `mod` q) q

-- | Умножение в GF(q)
mulGF :: GF -> GF -> GF
mulGF (GF a q) (GF b _) = GF ((a * b) `mod` q) q

-- | Противоположный элемент (аддитивный обратный)
negateGF :: GF -> GF
negateGF (GF a q) = GF ((-a) `mod` q) q

-- | Обратный элемент (мультипликативный обратный)
--   Требуется: a ≠ 0 (mod q)
invGF :: GF -> GF
invGF gf@(GF a q)
    | a `mod` q == 0 = error "invGF: нуль не имеет обратного элемента"
    | otherwise      = GF (modularInverse a q) q

-- | Расширенный алгоритм Евклида: возвращает (gcd, x, y),
--   такие что a*x + b*y = gcd(a,b)
extendedGCD :: Integer -> Integer -> (Integer, Integer, Integer)
extendedGCD a 0 = (a, 1, 0)
extendedGCD a b =
    let (d, x1, y1) = extendedGCD b (a `mod` b)
        x = y1
        y = x1 - (a `div` b) * y1
    in (d, x, y)

-- | Модульный обратный: такой inv, что a*inv ≡ 1 (mod m)
--   Требуется: gcd(a,m) = 1
modularInverse :: Integer -> Integer -> Integer
modularInverse a m =
    let (_, x, _) = extendedGCD a m
    in x `mod` m
