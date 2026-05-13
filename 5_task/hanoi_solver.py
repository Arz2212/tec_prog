#!/usr/bin/env python3
"""
Обёртка для вызова Prolog-решения Ханойской башни.

Использует subprocess для взаимодействия с SWI-Prolog.
"""

import subprocess
import sys
import re
from pathlib import Path


class HanoiSolver:

    PROLOG_FILE = Path(__file__).parent / "hanoi.pl"

    def __init__(self):
        if not self.PROLOG_FILE.exists():
            raise FileNotFoundError(f"Prolog-файл не найден: {self.PROLOG_FILE}")

    @staticmethod
    def _parse_moves(output: str) -> list[tuple[str, str]]:
        """Разбирает вывод Prolog в список ходов (from, to)."""
        moves = []
        pattern = re.compile(r"move\((\w+),(\w+)\)")
        for match in pattern.finditer(output):
            moves.append((match.group(1), match.group(2)))
        return moves

    def solve(self, n: int) -> list[tuple[str, str]]:
        """Решить Ханойскую башню для N дисков.

        Args:
            n: число дисков (1 ≤ n ≤ 10)

        Returns:
            Список ходов, каждый — кортеж (from, to).
        """
        if not (1 <= n <= 10):
            raise ValueError(f"N должно быть от 1 до 10, получено {n}")

        cmd = [
            "swipl", "-q",
            "-g", f"consult('{self.PROLOG_FILE}'),hanoi({n},Moves),writeln(Moves),halt.",
            "-t", "halt",
        ]
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=30,
        )
        if result.returncode != 0:
            raise RuntimeError(f"Prolog завершился с ошибкой:\n{result.stderr}")

        return self._parse_moves(result.stdout)

    def solve_as_strings(self, n: int) -> list[str]:
        """Вернуть решение в виде списка строк вида 'left -> right'."""
        moves = self.solve(n)
        return [f"{f} -> {t}" for f, t in moves]

    def validate(self, n: int, moves: list[tuple[str, str]]) -> bool:
        """Проверить корректность последовательности ходов для N дисков."""
        moves_term = "[" + ",".join(
            f"move({f},{t})" for f, t in moves
        ) + "]"
        cmd = [
            "swipl", "-q",
            "-g",
            f"consult('{self.PROLOG_FILE}'),"
            f"(validate({n},{moves_term})->writeln('OK');writeln('FAIL')),"
            f"halt.",
            "-t", "halt",
        ]
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=30,
        )
        return "OK" in result.stdout

    def moves_count(self, n: int) -> int:
        """Теоретическое минимальное число ходов: 2^n - 1."""
        return 2**n - 1

    def print_solution(self, n: int) -> None:
        moves = self.solve(n)
        expected = self.moves_count(n)
        print(f"\nХанойская башня: N = {n} дисков")
        print(f"Ожидаемое число ходов: {expected}")
        print(f"Фактическое число ходов: {len(moves)}")
        print()
        for i, (f, t) in enumerate(moves, 1):
            print(f"  Ход {i}: {f} -> {t}")


def main():
    if len(sys.argv) != 2:
        print(f"Использование: {sys.argv[0]} N")
        print("  N — число дисков (1–10)")
        sys.exit(1)

    try:
        n = int(sys.argv[1])
    except ValueError:
        print(f"Ошибка: N должно быть целым числом, получено '{sys.argv[1]}'")
        sys.exit(1)

    solver = HanoiSolver()
    try:
        solver.print_solution(n)
    except Exception as e:
        print(f"Ошибка: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
