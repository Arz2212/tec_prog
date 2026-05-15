-- |
-- Демонстрация Quadtree в контексте муравьиной симуляции.
--
module Main where

import QuadTree

-- | Данные сущности
data Entity = Entity
  { entityType :: String, agentRole :: Maybe String, energy :: Int, entityId :: String
  } deriving (Show, Eq)

mkAgent :: String -> String -> Int -> Entity
mkAgent eid role en = Entity "agent" (Just role) en eid

mkFood :: String -> Int -> Entity
mkFood fid en = Entity "food" Nothing en fid

main :: IO ()
main = do
  putStrLn "╔══════════════════════════════════════════════════╗"
  putStrLn "║  ДЕМОНСТРАЦИЯ: Quadtree — муравьиная колония    ║"
  putStrLn "╚══════════════════════════════════════════════════╝"

  let mapR = Region 400.0 400.0 400.0

  -- 1. Вставка через foldl
  putStrLn "\n─── 1. Вставка сущностей ───"
  let entities =
        [ Point 400 400 (mkAgent "base" "Worker" 1000)
        , Point 200 300 (mkAgent "w1" "Worker" 100)
        , Point 500 200 (mkAgent "w3" "Worker" 80)
        , Point 600 500 (mkAgent "s1" "Scout" 120)
        , Point 100 100 (mkAgent "s2" "Scout" 150)
        , Point 700 700 (mkAgent "s3" "Scout" 90)
        , Point 150 400 (mkFood "f1" 500)
        , Point 650 350 (mkFood "f2" 300)
        , Point 300 600 (mkFood "f3" 200)
        ]
      tree = foldl (flip insert) (empty mapR) entities

  putStrLn $ "  Всего сущностей: " ++ show (size tree)

  -- 2. Поиск в радиусе
  putStrLn "\n─── 2. Поиск соседей в радиусе ───"
  let neighbors = queryRadius tree 200 300 80
  putStrLn $ "  Соседей w1 в радиусе 80: " ++ show (length neighbors)
  mapM_ (putStrLn . ("    → " ++) . show) neighbors

  -- 3. Монадическая цепочка
  putStrLn "\n─── 3. Монадическая цепочка ───"
  let (nbrs, finalTree) = runQTreeM (empty mapR) $ do
        insertM (Point 100 100 (mkAgent "a1" "Worker" 100))
        insertM (Point 120 120 (mkAgent "a2" "Scout" 100))
        insertM (Point 500 500 (mkFood "food1" 200))
        insertM (Point 130 110 (mkAgent "a3" "Worker" 80))
        ns <- queryRadiusM 100 100 50
        pure ns

  putStrLn $ "  Соседей вокруг (100,100) в радиусе 50: " ++ show (length nbrs)
  putStrLn $ "  Итоговый размер дерева: " ++ show (size finalTree)

  -- 4. Show
  putStrLn "\n─── 4. Вывод дерева (Show) ───"
  putStrLn $ "  " ++ show tree
  putStrLn "\n  ✅ Демонстрация завершена."
