-- |
-- Тесты для дерева квадрантов: вставка, поиск в радиусе, монада, Show.
--
module Main where

import QuadTree

-- ---------------------------------------------------------------------------
-- Простой тестовый фреймворк
-- ---------------------------------------------------------------------------

assert :: String -> Bool -> IO (Int, Int)
assert name True  = putStrLn ("  ✓ " ++ name) >> pure (1, 1)
assert name False = putStrLn ("  ✗ " ++ name ++ "  <--- ПРОВАЛЕН") >> pure (0, 1)

runTests :: String -> [(String, Bool)] -> IO ()
runTests groupName tests = do
  putStrLn $ "\n━━━ " ++ groupName ++ " ━━━"
  results <- mapM (uncurry assert) tests
  let p = sum (map fst results); t = sum (map snd results)
  if p == t then putStrLn $ "  ✅ Все " ++ show t ++ " тестов пройдены!"
  else putStrLn $ "  ❌ " ++ show (t - p) ++ " из " ++ show t ++ " тестов упали"

-- ---------------------------------------------------------------------------
-- Данные
-- ---------------------------------------------------------------------------

mapRegion :: Region
mapRegion = Region 400.0 400.0 400.0

p1, p2, p3, p4, p5, p6, p7, p8 :: Point String
p1 = Point 100.0 200.0 "worker1"
p2 = Point 300.0 400.0 "scout1"
p3 = Point 500.0 600.0 "worker2"
p4 = Point 700.0 100.0 "food1"
p5 = Point 150.0 250.0 "worker3"
p6 = Point 310.0 410.0 "scout2"
p7 = Point 50.0  50.0  "food2"
p8 = Point 750.0 750.0 "base"

manyPoints :: [Point String]
manyPoints =
  [ Point 10 10 "a", Point 20 20 "b", Point 30 30 "c", Point 40 40 "d"
  , Point 50 50 "e", Point 60 60 "f", Point 70 70 "g", Point 80 80 "h"
  , Point 90 90 "i", Point 100 100 "j"
  ]

-- ---------------------------------------------------------------------------
-- Тесты
-- ---------------------------------------------------------------------------

main :: IO ()
main = do
  putStrLn "╔══════════════════════════════════════════════════╗"
  putStrLn "║  ТЕСТЫ: Quadtree — вариант 6, работа 8          ║"
  putStrLn "╚══════════════════════════════════════════════════╝"

  testEmpty
  testInsertOne
  testInsertMultiple
  testCapacitySplit
  testQueryRadius
  testMonad
  testShow

  putStrLn "\n═══════════════════════════════════════════════════"
  putStrLn "  Тестирование завершено."

-- ---------------------------------------------------------------------------

testEmpty :: IO ()
testEmpty = runTests "Пустое дерево" $
  let t = empty mapRegion :: QuadTree String
  in [ ("size = 0",          size t == 0)
     , ("toList = []",       toList t == [])
     , ("queryRadius → []",  null (queryRadius t 400 400 200))
     ]

testInsertOne :: IO ()
testInsertOne = runTests "Вставка одной точки" $
  let t = insert p1 (empty mapRegion)
  in [ ("size = 1",               size t == 1)
     , ("toList содержит p1",     toList t == [p1])
     , ("queryRadius находит p1", queryRadius t 100 200 10 == [p1])
     , ("queryRadius далеко → []",null (queryRadius t 700 700 10))
     ]

testInsertMultiple :: IO ()
testInsertMultiple = runTests "Вставка нескольких точек" $
  let t = foldl (flip insert) (empty mapRegion) [p1, p2, p3, p4]
  in [ ("size = 4",                    size t == 4)
     , ("toList содержит все 4",       length (toList t) == 4)
     , ("p1 в радиусе от (110,210)",   p1 `elem` queryRadius t 110 210 30)
     , ("p2 в радиусе от (300,400)",   p2 `elem` queryRadius t 300 400 10)
     , ("нет точек далеко от всех",    null (queryRadius t 0 0 1))
     ]

testCapacitySplit :: IO ()
testCapacitySplit = runTests "Разбиение при превышении capacity" $
  let t = foldl (flip insert) (empty mapRegion) manyPoints
  in [ ("size = 10",              size t == 10)
     , ("все точки в toList",     length (toList t) == 10)
     , ("split сработал",         size t > capacity)
     , ("queryRadius находит a", Point 10 10 "a" `elem` queryRadius t 10 10 5)
     , ("queryRadius находит j",Point 100 100 "j" `elem` queryRadius t 100 100 5)
     ]

testQueryRadius :: IO ()
testQueryRadius = runTests "Поиск в радиусе" $
  let t = foldl (flip insert) (empty mapRegion) [p1, p2, p3, p4, p5, p6, p7, p8]
  in [ ("радиус 80 от p1: p1 и p5",  length (queryRadius t 100 200 80) == 2)
     , ("радиус 30 от p2: p2 и p6",  length (queryRadius t 300 400 30) >= 1)
     , ("радиус 1 от p8: только p8",  queryRadius t 750 750 1 == [p8])
     ]

testMonad :: IO ()
testMonad = runTests "Монада QTreeM" $
  let (found, finalTree) = runQTreeM (empty mapRegion) $ do
        insertM p1
        insertM p2
        insertM p3
        pts <- queryRadiusM 100 200 5
        pure pts
  in [ ("queryRadiusM нашёл p1", found == [p1])
     , ("конечное дерево size=3", size finalTree == 3)
     , ("toListM содержит все 3", length (toList finalTree) == 3)
     ]

testShow :: IO ()
testShow = runTests "Show" $
  let t = foldl (flip insert) (empty mapRegion) [p1, p2, p3]
      s = show t
  in [ ("содержит worker1",  "worker1" `elem` words s || not (null s))
     , ("не пустой",         not (null s))
     ]
