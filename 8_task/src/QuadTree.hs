-- |
-- Module      : QuadTree
-- Description : Двумерное дерево квадрантов (Quadtree) — вариант 6.
--
-- Реализация point-region quadtree для хранения точек в ограниченной 2D-области.
-- Поддерживает вставку, удаление, поиск в радиусе и в прямоугольной области.
-- Структура оформлена как монада: состояние дерева — контекст, операции
-- вставки/удаления последовательно меняют его.
--
-- Применение в проекте «Муравьиная колония»:
--   - Агенты и источники еды хранятся в quadtree вместо плоского списка.
--   - Поиск соседей в радиусе взаимодействия — O(log n) вместо O(n²).
--
module QuadTree
  ( -- * Основные типы
    Point (..)
  , Region (..)
  , QuadTree (..)

    -- * Создание и запросы
  , empty
  , insert
  , delete
  , queryRadius
  , queryRegion
  , size
  , toList
  , capacity

    -- * Монада
  , QTreeM
  , runQTreeM
  , evalQTreeM
  , execQTreeM
  , insertM
  , deleteM
  , queryRadiusM
  , queryRegionM
  , sizeM
  , toListM
  ) where

-- ---------------------------------------------------------------------------
-- ТИПЫ ДАННЫХ
-- ---------------------------------------------------------------------------

-- | Ёмкость листа: сколько точек может храниться в одном листе до разбиения.
capacity :: Int
capacity = 4

-- | 2D-точка с пользовательскими данными.
data Point a = Point
  { px        :: !Double  -- ^ X-координата
  , py        :: !Double  -- ^ Y-координата
  , pointData :: a        -- ^ Пользовательские данные (энергия, тип агента и т.д.)
  } deriving (Eq)

-- | Прямоугольная область, заданная центром и полуразмером.
data Region = Region
  { cx   :: !Double  -- ^ X центра
  , cy   :: !Double  -- ^ Y центра
  , half :: !Double  -- ^ Полуширина / полувысота
  } deriving (Eq, Show)

-- | Двумерное дерево квадрантов (point-region quadtree).
--
-- * @Empty@  — пустая область.
-- * @Leaf@   — лист, содержащий до @capacity@ точек.
-- * @Node@   — внутренний узел, разбитый на 4 дочерних квадранта.
data QuadTree a
  = Empty !Region
  | Leaf  !Region [Point a]
  | Node  !Region !(QuadTree a) !(QuadTree a) !(QuadTree a) !(QuadTree a)
  deriving (Eq)

-- ---------------------------------------------------------------------------
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- ---------------------------------------------------------------------------

-- | Принадлежит ли точка региону?
inRegion :: Point a -> Region -> Bool
inRegion (Point x y _) (Region cx' cy' h) =
  x >= cx' - h && x < cx' + h && y >= cy' - h && y < cy' + h

-- | Разбить регион на 4 подрегиона (NW, NE, SW, SE).
splitRegion :: Region -> (Region, Region, Region, Region)
splitRegion (Region cx' cy' h) =
  let h2 = h / 2.0
  in ( Region (cx' - h2) (cy' - h2) h2   -- NW
     , Region (cx' + h2) (cy' - h2) h2   -- NE
     , Region (cx' - h2) (cy' + h2) h2   -- SW
     , Region (cx' + h2) (cy' + h2) h2   -- SE
     )

-- | В каком квадранте находится точка?
-- Возвращает 0=NW, 1=NE, 2=SW, 3=SE
quadrant :: Point a -> Region -> Int
quadrant (Point x y _) (Region cx' cy' _)
  | x < cx'   && y < cy'   = 0  -- NW
  | x >= cx'  && y < cy'   = 1  -- NE
  | x < cx'   && y >= cy'  = 2  -- SW
  | otherwise              = 3  -- SE

-- | Евклидово расстояние между двумя точками.
distance :: Point a -> Point b -> Double
distance (Point x1 y1 _) (Point x2 y2 _) =
  sqrt ((x1 - x2) ** 2 + (y1 - y2) ** 2)

-- | Пересекается ли регион с кругом? (для отсечения при поиске в радиусе).
-- Находим ближайшую к центру круга точку региона и проверяем расстояние.
regionIntersectsCircle :: Region -> Double -> Double -> Double -> Bool
regionIntersectsCircle (Region rcx rcy rh) qx qy r =
  let closestX = max (rcx - rh) (min qx (rcx + rh))
      closestY = max (rcy - rh) (min qy (rcy + rh))
      dx = qx - closestX
      dy = qy - closestY
  in dx * dx + dy * dy <= r * r

-- | Пересекаются ли два региона?
regionsOverlap :: Region -> Region -> Bool
regionsOverlap (Region x1 y1 h1) (Region x2 y2 h2) =
  abs (x1 - x2) <= h1 + h2 && abs (y1 - y2) <= h1 + h2

-- ---------------------------------------------------------------------------
-- ОСНОВНЫЕ ОПЕРАЦИИ
-- ---------------------------------------------------------------------------

-- | Создать пустое дерево квадрантов, покрывающее заданный регион.
empty :: Region -> QuadTree a
empty = Empty

-- | Вставить точку в дерево.
insert :: Point a -> QuadTree a -> QuadTree a
insert pt tree = case tree of
  Empty r
    | inRegion pt r -> Leaf r [pt]
    | otherwise     -> tree

  Leaf r pts
    | not (inRegion pt r) -> tree
    | length pts < capacity -> Leaf r (pt : pts)
    | otherwise ->
        -- Разбиваем лист: создаём Node и перераспределяем все точки + новую
        let allPts = pt : pts
        in foldl (flip insert) (emptyNode r) allPts

  Node r nw ne sw se
    | not (inRegion pt r) -> tree
    | otherwise ->
        case quadrant pt r of
          0 -> Node r (insert pt nw) ne sw se
          1 -> Node r nw (insert pt ne) sw se
          2 -> Node r nw ne (insert pt sw) se
          3 -> Node r nw ne sw (insert pt se)
          _ -> tree  -- никогда не случится

-- | Создать пустой Node из региона (4 пустых дочерних квадранта).
emptyNode :: Region -> QuadTree a
emptyNode r =
  let (nwR, neR, swR, seR) = splitRegion r
  in Node r (Empty nwR) (Empty neR) (Empty swR) (Empty seR)

-- | Удалить точку из дерева (по полному совпадению, включая данные).
delete :: Eq a => Point a -> QuadTree a -> QuadTree a
delete pt tree = case tree of
  Empty _ -> tree
  Leaf r pts
    | pt `elem` pts ->
        let remaining = filter (/= pt) pts
        in if null remaining then Empty r else Leaf r remaining
    | otherwise -> tree
  Node r nw ne sw se
    | not (inRegion pt r) -> tree
    | otherwise ->
        let result = case quadrant pt r of
              0 -> Node r (delete pt nw) ne sw se
              1 -> Node r nw (delete pt ne) sw se
              2 -> Node r nw ne (delete pt sw) se
              3 -> Node r nw ne sw (delete pt se)
              _ -> tree
        in collapse result  -- попытаться склеить обратно, если возможно

-- | Если Node содержит только пустые листья — превратить в Empty.
-- Если все точки можно собрать в один Leaf — склеить.
collapse :: QuadTree a -> QuadTree a
collapse (Node r (Empty _) (Empty _) (Empty _) (Empty _)) = Empty r
collapse (Node r nw ne sw se) =
  let pts = collectLeaves nw ++ collectLeaves ne ++ collectLeaves sw ++ collectLeaves se
  in if length pts <= capacity
        then if null pts then Empty r else Leaf r pts
        else Node r nw ne sw se
collapse t = t

-- | Собрать все точки из листьев (для склеивания).
collectLeaves :: QuadTree a -> [Point a]
collectLeaves (Leaf _ pts) = pts
collectLeaves _            = []

-- | Поиск всех точек в круговом радиусе от заданной точки.
queryRadius :: QuadTree a -> Double -> Double -> Double -> [Point a]
queryRadius tree qx qy r = case tree of
  Empty _ -> []
  Leaf _ pts
    | regionIntersectsCircle (regionOf tree) qx qy r ->
        filter (\p -> distance p (Point qx qy undefined) <= r) pts
    | otherwise -> []
  Node _ nw ne sw se
    | regionIntersectsCircle (regionOf tree) qx qy r ->
        queryRadius nw qx qy r ++ queryRadius ne qx qy r ++
        queryRadius sw qx qy r ++ queryRadius se qx qy r
    | otherwise -> []

-- | Поиск всех точек в прямоугольной области.
queryRegion :: QuadTree a -> Region -> [Point a]
queryRegion tree qr = case tree of
  Empty _ -> []
  Leaf _ pts
    | regionsOverlap (regionOf tree) qr ->
        filter (\p -> inRegion p qr) pts
    | otherwise -> []
  Node _ nw ne sw se
    | regionsOverlap (regionOf tree) qr ->
        queryRegion nw qr ++ queryRegion ne qr ++
        queryRegion sw qr ++ queryRegion se qr
    | otherwise -> []

-- | Получить регион любого узла дерева.
regionOf :: QuadTree a -> Region
regionOf (Empty r)      = r
regionOf (Leaf r _)     = r
regionOf (Node r _ _ _ _) = r

-- | Количество точек в дереве.
size :: QuadTree a -> Int
size (Empty _)      = 0
size (Leaf _ pts)   = length pts
size (Node _ nw ne sw se) = size nw + size ne + size sw + size se

-- | Все точки дерева в виде списка.
toList :: QuadTree a -> [Point a]
toList (Empty _)      = []
toList (Leaf _ pts)   = pts
toList (Node _ nw ne sw se) = toList nw ++ toList ne ++ toList sw ++ toList se

-- ---------------------------------------------------------------------------
-- МОНАДА — состояние дерева как контекст
-- ---------------------------------------------------------------------------

-- | Монада для последовательного изменения состояния дерева квадрантов.
--
-- @QTreeM a b@ — вычисление, которое работает с деревом типа @QuadTree a@
-- и возвращает значение типа @b@.
--
-- Пример использования:
--
-- @
-- runQTreeM (empty initialRegion) $ do
--   insertM (Point 10 20 (Agent "worker1"))
--   insertM (Point 30 40 (Agent "scout1"))
--   pts <- queryRadiusM 25 30 20
--   pure pts
-- @
newtype QTreeM a b = QTreeM { runQTreeM' :: QuadTree a -> (b, QuadTree a) }

-- | Запустить монадическое вычисление с начальным состоянием.
runQTreeM :: QuadTree a -> QTreeM a b -> (b, QuadTree a)
runQTreeM st (QTreeM f) = f st

-- | Запустить монадическое вычисление и вернуть только значение.
evalQTreeM :: QuadTree a -> QTreeM a b -> b
evalQTreeM st m = fst (runQTreeM st m)

-- | Запустить монадическое вычисление и вернуть только конечное состояние.
execQTreeM :: QuadTree a -> QTreeM a b -> QuadTree a
execQTreeM st m = snd (runQTreeM st m)

instance Functor (QTreeM a) where
  fmap f (QTreeM g) = QTreeM $ \st ->
    let (x, st') = g st in (f x, st')

instance Applicative (QTreeM a) where
  pure x = QTreeM $ \st -> (x, st)
  QTreeM f <*> QTreeM g = QTreeM $ \st ->
    let (h, st')  = f st
        (x, st'') = g st'
    in (h x, st'')

instance Monad (QTreeM a) where
  QTreeM f >>= k = QTreeM $ \st ->
    let (x, st') = f st
        QTreeM g = k x
    in g st'

-- | Получить текущее состояние дерева.
getTree :: QTreeM a (QuadTree a)
getTree = QTreeM $ \st -> (st, st)

-- | Заменить состояние дерева.
putTree :: QuadTree a -> QTreeM a ()
putTree st = QTreeM $ \_ -> ((), st)

-- | Применить функцию к состоянию дерева.
modifyTree :: (QuadTree a -> QuadTree a) -> QTreeM a ()
modifyTree f = QTreeM $ \st -> ((), f st)

-- | Монадическая вставка точки.
insertM :: Point a -> QTreeM a ()
insertM pt = modifyTree (insert pt)

-- | Монадическое удаление точки.
deleteM :: Eq a => Point a -> QTreeM a ()
deleteM pt = modifyTree (delete pt)

-- | Монадический поиск точек в радиусе.
queryRadiusM :: Double -> Double -> Double -> QTreeM a [Point a]
queryRadiusM qx qy r = do
  tree <- getTree
  pure $ queryRadius tree qx qy r

-- | Монадический поиск точек в регионе.
queryRegionM :: Region -> QTreeM a [Point a]
queryRegionM qr = do
  tree <- getTree
  pure $ queryRegion tree qr

-- | Монадический размер дерева.
sizeM :: QTreeM a Int
sizeM = size <$> getTree

-- | Монадическое получение всех точек.
toListM :: QTreeM a [Point a]
toListM = toList <$> getTree

-- ---------------------------------------------------------------------------
-- SHOW — красивая печать дерева квадрантов
-- ---------------------------------------------------------------------------

instance Show a => Show (Point a) where
  show (Point x y d) = "(" ++ show x ++ ", " ++ show y ++ " | " ++ show d ++ ")"

-- | Красивое текстовое представление дерева квадрантов с отступами.
instance Show a => Show (QuadTree a) where
  show tree = showTree 0 True tree

-- | Вспомогательная: рекурсивная печать дерева с отступами.
showTree :: Show a => Int -> Bool -> QuadTree a -> String
showTree n _isRoot tree = case tree of
  Empty r ->
    indent n ++ "[Empty] " ++ regionStr r
  Leaf r pts ->
    indent n ++ "[Leaf] " ++ regionStr r ++
    "  points=" ++ show (length pts) ++ "\n" ++
    concatMap (\p -> indent (n + 1) ++ "• " ++ show p ++ "\n") pts
  Node r nw ne sw se ->
    indent n ++ "[Node] " ++ regionStr r ++
    "  total=" ++ show (size tree) ++ "\n" ++
    indent (n + 1) ++ "NW:\n" ++ showTree (n + 2) False nw ++
    indent (n + 1) ++ "NE:\n" ++ showTree (n + 2) False ne ++
    indent (n + 1) ++ "SW:\n" ++ showTree (n + 2) False sw ++
    indent (n + 1) ++ "SE:\n" ++ showTree (n + 2) False se

-- | Отступ для красивого вывода.
indent :: Int -> String
indent n = replicate (n * 2) ' '

-- | Строковое представление региона.
regionStr :: Region -> String
regionStr (Region x y h) =
  "Region(cx=" ++ show x ++ ", cy=" ++ show y ++ ", half=" ++ show h ++ ")"
