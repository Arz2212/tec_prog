#!/bin/bash
# Сборка и запуск: ./build.sh
# Требуется GHC с поддержкой -dynamic (в системе только динамические библиотеки base).
set -e
cd "$(dirname "$0")"
echo "=== Сборка демо ==="
ghc -dynamic -Wall -isrc app/Main.hs -o quadtree-demo
echo "=== Сборка тестов ==="
ghc -dynamic -Wall -isrc test/Test.hs -o quadtree-tests
echo "=== Запуск тестов ==="
./quadtree-tests
echo ""
echo "=== Запуск демо ==="
./quadtree-demo
