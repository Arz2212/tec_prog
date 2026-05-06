#!/bin/bash
# Скрипт запуска всех тестов для задач 1А, 2А, 3Б, 4Б, 5А

# Настройка окружения Haskell
source "$HOME/.ghcup/env" 2>/dev/null

TESTS_DIR="$(dirname "$0")"
PASSED=0
FAILED=0
RESULTS=""

echo "========================================"
echo "  ЗАПУСК ВСЕХ ТЕСТОВ (6rab)"
echo "========================================"
echo ""

run_test() {
    local task="$1"
    local test_file="$TESTS_DIR/test_${task}.hs"

    echo "--- Задача ${task^^} ---"
    if runghc -i"$TESTS_DIR" "$test_file" 2>&1; then
        echo "  ↳ ЗАДАЧА ${task^^}: ПРОЙДЕНА"
        PASSED=$((PASSED + 1))
        RESULTS="$RESULTS  ✓ Задача ${task^^}: ПРОЙДЕНА\n"
    else
        echo "  ↳ ЗАДАЧА ${task^^}: НЕ ПРОЙДЕНА"
        FAILED=$((FAILED + 1))
        RESULTS="$RESULTS  ✗ Задача ${task^^}: НЕ ПРОЙДЕНА\n"
    fi
    echo ""
}

run_test "task1a"
run_test "task2a"
run_test "task3b"
run_test "task4b"
run_test "task5a"

echo "========================================"
echo "  РЕЗУЛЬТАТЫ"
echo "========================================"
echo ""
echo -e "$RESULTS"
echo "Пройдено: $PASSED / $((PASSED + FAILED))"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "✓ ВСЕ ТЕСТЫ ПРОЙДЕНЫ"
    exit 0
else
    echo "✗ $FAILED тест(ов) не пройдено"
    exit 1
fi
