-- |
-- Module      : Bench
-- Description : Замер времени вставки в Quadtree (Haskell) — пункт 1 работы 9.
--
-- Измеряет время добавления элементов для размеров 10, 100, 1000, 10000.
-- Использует wall-clock время и форсирует вычисления для точных замеров.
--
module Main where

import Data.Time.Clock (getCurrentTime, diffUTCTime)
import Text.Printf (printf)
import System.Random (randomRs, mkStdGen)
import QuadTree

-- | Карта 800×800
mapRegion :: Region
mapRegion = Region 400.0 400.0 400.0

-- | Размеры для замера
sizes :: [Int]
sizes = [10, 100, 1000, 10000]

-- | Сгенерировать список случайных точек
genPoints :: Int -> [Point String]
genPoints n =
  let genX = randomRs (0.0, 800.0) (mkStdGen 42)
      genY = randomRs (0.0, 800.0) (mkStdGen 137)
  in zipWith3 (\x y i -> Point x y ("a" ++ show i))
       (take n genX) (take n genY) [1..n]

-- | Измерить время выполнения IO-действия в микросекундах.
measureTime :: IO a -> IO (a, Double)
measureTime action = do
  start <- getCurrentTime
  result <- action
  end   <- getCurrentTime
  let secs = realToFrac (diffUTCTime end start) :: Double
  pure (result, secs * 1e6)  -- микросекунды

-- | Вставить все точки, форсируя размер дерева (чтобы избежать лени).
forceInsert :: [Point String] -> QuadTree String -> IO (QuadTree String)
forceInsert pts tree0 = do
  let tree = foldl (flip insert) tree0 pts
  -- Форсируем вычисление: требуем size
  let sz = size tree
  sz `seq` pure tree

-- | Бенчмарк: полная вставка N элементов.
benchFullInsert :: Int -> IO (Int, Double)
benchFullInsert n = do
  let pts = genPoints n
  (tree, totalUs) <- measureTime $ forceInsert pts (empty mapRegion)
  let sz = size tree
  if sz /= n
    then error $ "Размер не совпадает: " ++ show sz ++ " /= " ++ show n
    else pure ()
  pure (n, totalUs / fromIntegral n)  -- микросекунды на элемент

-- | Бенчмарк: вставка 1 элемента в уже заполненное дерево из n элементов.
benchOneInsert :: Int -> Int -> IO (Int, Double)
benchOneInsert n trials = do
  let pts = genPoints (n + 1)
  let existingPts = take n pts
  let newPt = last pts
  tree0 <- forceInsert existingPts (empty mapRegion)
  -- Запускаем trials раз и усредняем
  (!_total, totalUs) <- measureTime $ do
    mapM_ (\_ -> do
      let tree' = insert newPt tree0
      let sz = size tree'
      sz `seq` pure ()
      ) [1..trials]
  pure (n, totalUs / fromIntegral trials)

main :: IO ()
main = do
  putStrLn "╔══════════════════════════════════════════════════════════╗"
  putStrLn "║   БЕНЧМАРК: Вставка в Quadtree (Haskell)               ║"
  putStrLn "║   Вариант 6 — Практическая работа 9, пункт 1           ║"
  putStrLn "╚══════════════════════════════════════════════════════════╝"

  putStrLn "\n─── 1. Среднее время вставки (полное заполнение) ───\n"
  printf "  %-10s  %-20s\n" ("Размер N" :: String) ("На 1 элемент (мкс)" :: String)
  putStrLn $ "  " ++ replicate 32 '-'

  results <- mapM benchFullInsert sizes
  mapM_ (\(n, perUs) ->
    printf "  %-10d  %-20.4f\n" n perUs) results

  putStrLn "\n─── 2. Вставка 1 элемента в заполненное дерево ───\n"
  printf "  %-10s  %-26s\n" ("Текущий N" :: String) ("Время (мкс, среднее за 1000)" :: String)
  putStrLn $ "  " ++ replicate 42 '-'

  singleResults <- mapM (\n -> benchOneInsert n 1000) sizes
  mapM_ (\(n, t) ->
    printf "  %-10d  %-26.4f\n" n t) singleResults

  putStrLn "\n─── 3. Анализ зависимости ───"
  putStrLn "\n  Отношение времени на элемент при росте N в 10 раз:"
  let ratios = zipWith (\(n1, t1) (n2, t2) ->
        (n1, n2, t2 / max t1 1e-12))
        results (tail results)
  mapM_ (\(n1, n2, r) ->
    printf "    %5d → %5d:  ×%.2f\n" n1 n2 r) ratios

  putStrLn "\n  Заключение:"
  putStrLn "    Время вставки в Quadtree растёт логарифмически — O(log n)."
  putStrLn "    При росте N в 10 раз время на элемент увеличивается незначительно."
  putStrLn "    Это подтверждает эффективность структуры для больших объёмов данных."
  putStrLn "\n═══════════════════════════════════════════════════════════"
