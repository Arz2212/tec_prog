#!/usr/bin/env bash
#   ./run_tests.sh          — запустить все тесты (Python + Prolog)
#   ./run_tests.sh python   — только Python-тесты
#   ./run_tests.sh prolog   — только Prolog-тесты


set -euo pipefail
cd "$(dirname "$0")"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' 

PASSED=0
FAILED=0
PROLOG_FILE="hanoi.pl"

# ---------------------------------------------------------------
# Проверка наличия SWI-Prolog
# ---------------------------------------------------------------
check_swipl() {
    if ! command -v swipl &>/dev/null; then
        echo -e "${RED}ОШИБКА: SWI-Prolog (swipl) не найден. Установите: sudo apt install swi-prolog${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ SWI-Prolog найден:${NC} $(swipl --version 2>&1 | head -1)"
}

# ---------------------------------------------------------------
# Проверка наличия Python 3
# ---------------------------------------------------------------
check_python() {
    if ! command -v python3 &>/dev/null; then
        echo -e "${RED}ОШИБКА: Python 3 не найден.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Python найден:${NC} $(python3 --version)"
}

# ---------------------------------------------------------------
# Prolog-тесты (встроенные запросы к SWI-Prolog)
# ---------------------------------------------------------------
run_prolog_tests() {
    echo ""
    echo -e "${CYAN}============================================${NC}"
    echo -e "${CYAN}  Prolog-тесты (hanoi.pl)${NC}"
    echo -e "${CYAN}============================================${NC}"
    echo ""

    declare -A prolog_tests=(
        ["hanoi(1) → 1 ход"]="hanoi(1,M),length(M,L),(L=:=1->writeln('PASS');writeln('FAIL'))."
        ["hanoi(2) → 3 хода"]="hanoi(2,M),length(M,L),(L=:=3->writeln('PASS');writeln('FAIL'))."
        ["hanoi(3) → 7 ходов"]="hanoi(3,M),length(M,L),(L=:=7->writeln('PASS');writeln('FAIL'))."
        ["hanoi(4) → 15 ходов"]="hanoi(4,M),length(M,L),(L=:=15->writeln('PASS');writeln('FAIL'))."
        ["hanoi(5) → 31 ход"]="hanoi(5,M),length(M,L),(L=:=31->writeln('PASS');writeln('FAIL'))."
        ["hanoi(10) → 1023 хода"]="hanoi(10,M),length(M,L),(L=:=1023->writeln('PASS');writeln('FAIL'))."
    )

    for test_name in "${!prolog_tests[@]}"; do
        query="${prolog_tests[$test_name]}"
        result=$(swipl -q \
            -g "consult('$PROLOG_FILE'),$query" \
            -t halt 2>&1) || true
        if echo "$result" | grep -q "PASS"; then
            echo -e "  ${GREEN}[PASS]${NC} $test_name"
            PASSED=$((PASSED + 1))
        else
            echo -e "  ${RED}[FAIL]${NC} $test_name (вывод: $result)"
            FAILED=$((FAILED + 1))
        fi
    done
}

# ---------------------------------------------------------------
# Python-тесты (unittest)
# ---------------------------------------------------------------
run_python_tests() {
    echo ""
    echo -e "${CYAN}============================================${NC}"
    echo -e "${CYAN}  Python-тесты (test_hanoi.py)${NC}"
    echo -e "${CYAN}============================================${NC}"
    echo ""

    result=$(python3 test_hanoi.py 2>&1)
    exit_code=$?

    echo "$result"

    # Подсчёт результатов из вывода unittest
    if echo "$result" | grep -q "FAILED"; then
        fails=$(echo "$result" | grep -oP 'failures=\K\d+' || echo "0")
        FAILED=$((FAILED + fails))
    fi
    if echo "$result" | grep -q "OK"; then
        # Считаем успешные тесты
        passes=$(echo "$result" | grep -oP '^Ran \d+ tests' | grep -oP '\d+' || echo "0")
        PASSED=$((PASSED + passes))
    fi
    if [ $exit_code -eq 0 ] && ! echo "$result" | grep -q "FAILED"; then
        echo -e "\n  ${GREEN}Все Python-тесты пройдены!${NC}"
    else
        echo -e "\n  ${RED}Некоторые Python-тесты не пройдены.${NC}"
        FAILED=$((FAILED + 1))
    fi
}

# ---------------------------------------------------------------
# Демонстрация решения
# ---------------------------------------------------------------
run_demo() {
    echo ""
    echo -e "${CYAN}============================================${NC}"
    echo -e "${CYAN}  Демонстрация решения (N=3)${NC}"
    echo -e "${CYAN}============================================${NC}"
    echo ""
    python3 hanoi_solver.py 3
}

# ---------------------------------------------------------------
# Главный блок
# ---------------------------------------------------------------
MODE="${1:-all}"

echo -e "${YELLOW}============================================${NC}"
echo -e "${YELLOW}  Тесты: Ханойская башня (Prolog + Python)${NC}"
echo -e "${YELLOW}============================================${NC}"

check_swipl
check_python

case "$MODE" in
    all)
        run_prolog_tests
        run_python_tests
        run_demo
        ;;
    prolog)
        run_prolog_tests
        ;;
    python)
        run_python_tests
        ;;
    demo)
        run_demo
        ;;
    *)
        echo -e "${RED}Неизвестный режим: $MODE${NC}"
        echo "Допустимые: all, prolog, python, demo"
        exit 1
        ;;
esac

# ---------------------------------------------------------------
# Итог
# ---------------------------------------------------------------
echo ""
echo -e "${YELLOW}============================================${NC}"
echo -e "  Итого: ${GREEN}$PASSED пройдено${NC}, ${RED}$FAILED провалено${NC}"
echo -e "${YELLOW}============================================${NC}"

if [ "$FAILED" -gt 0 ]; then
    exit 1
else
    exit 0
fi
