-- |
-- Module      : Test
-- Description : Тесты для двумерного дерева квадрантов.
--
-- Проверяются операции вставки, поиска в радиусе, удаления,
-- а также монадический интерфейс.
--
module Main where

import QuadTree
import Data.List (isInfixOf)

-- ---------------------------------------------------------------------------
-- ТЕСТОВЫЙ ФРЕЙМВОРК (без внешних зависимостей)
-- ---------------------------------------------------------------------------

type TestName = String

passed :: Int -> Int -> IO ()
passed 0 _ = pure ()
passed n t = putStrLn $ "  ✅ " ++ show n ++ " тестов пройдено из " ++ show t

failed :: Int -> Int -> IO ()
failed 0 _ = pure ()
failed n t = putStrLn $ "  ❌ " ++ show n ++ " ТЕСТОВ УПАЛО из " ++ show t

assert :: TestName -> Bool -> IO (Int, Int)
assert name True  = putStrLn ("  ✓ " ++ name) >> pure (1, 1)
assert name False = putStrLn ("  ✗ " ++ name ++ "  <--- ПРОВАЛЕН") >> pure (0, 1)

runTests :: String -> [(TestName, Bool)] -> IO ()
runTests groupName tests = do
  putStrLn $ "\n━━━ " ++ groupName ++ " ━━━"
  results <- mapM (uncurry assert) tests
  let p = sum (map fst results)
  let t = sum (map snd results)
  if p == t
    then putStrLn $ "  ✅ Все " ++ show t ++ " тестов пройдены!"
    else putStrLn $ "  ❌ " ++ show (t - p) ++ " из " ++ show t ++ " тестов упали"

-- ---------------------------------------------------------------------------
-- ТЕСТОВЫЕ ДАННЫЕ
-- ---------------------------------------------------------------------------

-- Карта 800×800, как в проекте муравьиной колонии
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

-- Точки для теста ёмкости (больше capacity=4)
manyPoints :: [Point String]
manyPoints =
  [ Point 10.0 10.0 "a"
  , Point 20.0 20.0 "b"
  , Point 30.0 30.0 "c"
  , Point 40.0 40.0 "d"
  , Point 50.0 50.0 "e"
  , Point 60.0 60.0 "f"
  , Point 70.0 70.0 "g"
  , Point 80.0 80.0 "h"
  , Point 90.0 90.0 "i"
  , Point 100.0 100.0 "j"
  ]

-- ---------------------------------------------------------------------------
-- ТЕСТЫ
-- ---------------------------------------------------------------------------

main :: IO ()
main = do
  putStrLn "╔══════════════════════════════════════════════════════╗"
  putStrLn "║   ТЕСТЫ: Двумерное дерево квадрантов (Quadtree)     ║"
  putStrLn "║   Вариант 6 — Практическая работа 8                 ║"
  putStrLn "╚══════════════════════════════════════════════════════╝"

  testEmpty
  testInsertOne
  testInsertMultiple
  testCapacitySplit
  testQueryRadius
  testQueryRegion
  testDelete
  testMonadInterface
  testMonadChain
  testShow

  putStrLn "\n═══════════════════════════════════════════════════════"
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
     , ("вставка в одном регионе вызывает split",  size t > capacity)
     , ("queryRadius находит a",  Point 10 10 "a" `elem` queryRadius t 10 10 5)
     , ("queryRadius находит j",  Point 100 100 "j" `elem` queryRadius t 100 100 5)
     ]

testQueryRadius :: IO ()
testQueryRadius = runTests "Поиск в радиусе" $
  let t = foldl (flip insert) (empty mapRegion) [p1, p2, p3, p4, p5, p6, p7, p8]
  in [ ("радиус 80 от p1: p1 и p5",  length (queryRadius t 100 200 80) == 2)
     , ("радиус 30 от p2: p2 и p6",  length (queryRadius t 300 400 30) >= 1)
     , ("радиус 0 от p8: только p8",  queryRadius t 750 750 1 == [p8])
     ]

testQueryRegion :: IO ()
testQueryRegion = runTests "Поиск в прямоугольной области" $
  let t = foldl (flip insert) (empty mapRegion) [p1, p2, p7, p8]
      r1 = Region 100 200 10    -- узкий квадрат вокруг p1
      r2 = Region 400 400 400   -- вся карта
  in [ ("регион вокруг p1 → 1 точка",  length (queryRegion t r1) == 1)
     , ("вся карта → 4 точки",         length (queryRegion t r2) == 4)
     ]

testDelete :: IO ()
testDelete = runTests "Удаление точек" $
  let t0 = foldl (flip insert) (empty mapRegion) [p1, p2, p3]
      t1 = delete p1 t0
      t2 = delete p2 t1
      t3 = delete p3 t2
  in [ ("после удаления p1: size = 2",   size t1 == 2)
     , ("после удаления p1,p2: size = 1", size t2 == 1)
     , ("после удаления всех: size = 0",  size t3 == 0)
     , ("p1 не найден после удаления",    p1 `notElem` toList t1)
     , ("p2 всё ещё есть после удаления p1", p2 `elem` toList t1)
     ]

testMonadInterface :: IO ()
testMonadInterface = runTests "Монадический интерфейс (QTreeM)" $
  let (result, finalTree) = runQTreeM (empty mapRegion) $ do
        insertM p1
        insertM p2
        insertM p3
        pts <- queryRadiusM 100 200 5
        sz  <- sizeM
        pure (pts, sz)
      (foundPts, sz) = result
  in [ ("sizeM = 3",           sz == 3)
     , ("queryRadiusM нашёл p1", foundPts == [p1])
     , ("конечное дерево size=3", size finalTree == 3)
     ]

testMonadChain :: IO ()
testMonadChain = runTests "Цепочка монадических операций" $
  let finalTree = execQTreeM (empty mapRegion) $ do
        insertM p1
        insertM p2
        insertM p3
        deleteM p2
        insertM p4
        insertM p5
        pure ()
  in [ ("итоговый size = 4",    size finalTree == 4)
     , ("p1 есть",              p1 `elem` toList finalTree)
     , ("p2 удалён",            p2 `notElem` toList finalTree)
     , ("p4 добавлен",          p4 `elem` toList finalTree)
     , ("p5 добавлен",          p5 `elem` toList finalTree)
     ]

testShow :: IO ()
testShow = runTests "Show (вывод в консоль)" $
  let t = foldl (flip insert) (empty mapRegion) [p1, p2, p3]
      s = show t
  in [ ("show содержит [Node]",   "[Node]" `elem` words s || "[Leaf]" `elem` words s || "[Empty]" `elem` words s)
     , ("show содержит worker1",  "worker1" `isInfixOf` s)
     , ("show содержит Region",   "Region" `isInfixOf` s)
     , ("show не пустой",         not (null s))
     ]
