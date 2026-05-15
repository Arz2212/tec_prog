-- |
-- Двумерное дерево квадрантов (Quadtree) — вариант 6, работа 8.
-- Вставка точек, поиск в радиусе. Монада для последовательного изменения.
--
module QuadTree
  ( Point (..), Region (..), QuadTree (..)
  , empty, insert, queryRadius, size, toList, capacity
  , QTreeM, runQTreeM, insertM, queryRadiusM, sizeM, toListM
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

inRegion :: Point a -> Region -> Bool
inRegion (Point x y _) (Region cx' cy' h) =
  x >= cx' - h && x < cx' + h && y >= cy' - h && y < cy' + h

quadrant :: Point a -> Region -> Int
quadrant (Point x y _) (Region cx' cy' _)
  | x < cx'  && y < cy'  = 0
  | x >= cx' && y < cy'  = 1
  | x < cx'  && y >= cy' = 2
  | otherwise            = 3

distance :: Point a -> Point b -> Double
distance (Point x1 y1 _) (Point x2 y2 _) =
  sqrt ((x1 - x2) ** 2 + (y1 - y2) ** 2)

regionIntersectsCircle :: Region -> Double -> Double -> Double -> Bool
regionIntersectsCircle (Region rcx rcy rh) qx qy r =
  let dx = qx - max (rcx - rh) (min qx (rcx + rh))
      dy = qy - max (rcy - rh) (min qy (rcy + rh))
  in dx * dx + dy * dy <= r * r

-- ---------------------------------------------------------------------------
-- ОСНОВНЫЕ ОПЕРАЦИИ
-- ---------------------------------------------------------------------------

empty :: Region -> QuadTree a
empty = Empty

insert :: Point a -> QuadTree a -> QuadTree a
insert pt tree = case tree of
  Empty r
    | inRegion pt r -> Leaf r [pt]
    | otherwise     -> tree
  Leaf r pts
    | not (inRegion pt r) -> Leaf r pts
    | length pts < capacity -> Leaf r (pt : pts)
    | otherwise ->
        let h2 = half r / 2
            (nwR, neR, swR, seR) =
              ( Region (cx r - h2) (cy r - h2) h2
              , Region (cx r + h2) (cy r - h2) h2
              , Region (cx r - h2) (cy r + h2) h2
              , Region (cx r + h2) (cy r + h2) h2 )
            node = Node r (Empty nwR) (Empty neR) (Empty swR) (Empty seR)
        in foldl (flip insert) node (pt : pts)
  Node r nw ne sw se
    | not (inRegion pt r) -> Node r nw ne sw se
    | otherwise -> case quadrant pt r of
        0 -> Node r (insert pt nw) ne sw se
        1 -> Node r nw (insert pt ne) sw se
        2 -> Node r nw ne (insert pt sw) se
        _ -> Node r nw ne sw (insert pt se)

queryRadius :: QuadTree a -> Double -> Double -> Double -> [Point a]
queryRadius tree qx qy rad = case tree of
  Empty _ -> []
  Leaf _ pts
    | intersects (getRegion tree) ->
        filter (\p -> distance p (Point qx qy undefined) <= rad) pts
    | otherwise -> []
  Node _ nw ne sw se
    | intersects (getRegion tree) ->
        queryRadius nw qx qy rad ++ queryRadius ne qx qy rad ++
        queryRadius sw qx qy rad ++ queryRadius se qx qy rad
    | otherwise -> []
  where
    intersects reg = regionIntersectsCircle reg qx qy rad
    getRegion (Empty reg)      = reg
    getRegion (Leaf reg _)     = reg
    getRegion (Node reg _ _ _ _) = reg

size :: QuadTree a -> Int
size (Empty _)      = 0
size (Leaf _ pts)   = length pts
size (Node _ nw ne sw se) = size nw + size ne + size sw + size se

toList :: QuadTree a -> [Point a]
toList (Empty _)      = []
toList (Leaf _ pts)   = pts
toList (Node _ nw ne sw se) = toList nw ++ toList ne ++ toList sw ++ toList se

-- ---------------------------------------------------------------------------
-- МОНАДА — состояние дерева как контекст
-- ---------------------------------------------------------------------------

newtype QTreeM a b = QTreeM (QuadTree a -> (b, QuadTree a))

runQTreeM :: QuadTree a -> QTreeM a b -> (b, QuadTree a)
runQTreeM st (QTreeM f) = f st

instance Functor (QTreeM a) where
  fmap f (QTreeM g) = QTreeM $ \st -> let (x, s) = g st in (f x, s)

instance Applicative (QTreeM a) where
  pure x = QTreeM $ \st -> (x, st)
  QTreeM f <*> QTreeM g = QTreeM $ \st ->
    let (h, s1) = f st; (x, s2) = g s1 in (h x, s2)

instance Monad (QTreeM a) where
  QTreeM f >>= k = QTreeM $ \st ->
    let (x, s) = f st; QTreeM g = k x in g s

insertM :: Point a -> QTreeM a ()
insertM pt = QTreeM $ \st -> ((), insert pt st)

queryRadiusM :: Double -> Double -> Double -> QTreeM a [Point a]
queryRadiusM qx qy r = QTreeM $ \st -> (queryRadius st qx qy r, st)

sizeM :: QTreeM a Int
sizeM = QTreeM $ \st -> (size st, st)

toListM :: QTreeM a [Point a]
toListM = QTreeM $ \st -> (toList st, st)

-- ---------------------------------------------------------------------------
-- SHOW
-- ---------------------------------------------------------------------------

instance Show a => Show (Point a) where
  show (Point x y d) = "(" ++ show x ++ "," ++ show y ++ "|" ++ show d ++ ")"

instance Show a => Show (QuadTree a) where
  show tree = "QuadTree{size=" ++ show (size tree) ++ ", points=" ++ show (toList tree) ++ "}"
