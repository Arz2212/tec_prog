#!/usr/bin/env python3

import unittest
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from hanoi_solver import HanoiSolver


class TestHanoiSolver(unittest.TestCase):
    """Тесты класса HanoiSolver."""

    @classmethod
    def setUpClass(cls):
        cls.solver = HanoiSolver()

    # ---- Базовые тесты ----

    def test_n1(self):
        moves = self.solver.solve(1)
        self.assertEqual(moves, [("left", "right")])
        self.assertEqual(len(moves), 1)

    def test_n2(self):

        moves = self.solver.solve(2)
        self.assertEqual(len(moves), 3)  # 2^2 - 1 = 3

    def test_n3(self):
        moves = self.solver.solve(3)
        self.assertEqual(len(moves), 7)  # 2^3 - 1 = 7

    def test_n4(self):
        moves = self.solver.solve(4)
        self.assertEqual(len(moves), 15)

    def test_n5(self):
        moves = self.solver.solve(5)
        self.assertEqual(len(moves), 31)

    def test_n10(self):

        moves = self.solver.solve(10)
        self.assertEqual(len(moves), 1023)

    # ---- Проверка количества ходов ----

    def test_moves_count_formula(self):
        """Для всех N от 1 до 10: число ходов = 2^N - 1."""
        for n in range(1, 11):
            expected = 2**n - 1
            moves = self.solver.solve(n)
            self.assertEqual(
                len(moves), expected,
                f"N={n}: ожидалось {expected} ходов, получено {len(moves)}"
            )

    # ---- Валидация решений ----

    def test_validate_all(self):
        for n in range(1, 11):
            moves = self.solver.solve(n)
            self.assertTrue(
                self.solver.validate(n, moves),
                f"N={n}: решение не прошло валидацию"
            )


    def test_moves_have_valid_pegs(self):
        """Все ходы должны ссылаться на существующие стержни."""
        valid_pegs = {"left", "center", "right"}
        for n in range(1, 6):
            moves = self.solver.solve(n)
            for f, t in moves:
                self.assertIn(f, valid_pegs, f"N={n}: неверный стержень '{f}'")
                self.assertIn(t, valid_pegs, f"N={n}: неверный стержень '{t}'")
                self.assertNotEqual(f, t, f"N={n}: ход с '{f}' на '{f}'")

    def test_solve_as_strings(self):
        """Метод solve_as_strings должен возвращать строки вида 'from -> to'."""
        strings = self.solver.solve_as_strings(3)
        self.assertEqual(len(strings), 7)
        self.assertTrue(all("->" in s for s in strings))
        self.assertEqual(strings[0], "left -> right")

    # ---- Тесты на ошибки ----

    def test_invalid_n_zero(self):
        with self.assertRaises(ValueError):
            self.solver.solve(0)

    def test_invalid_n_negative(self):
        with self.assertRaises(ValueError):
            self.solver.solve(-1)

    def test_invalid_n_too_large(self):

        with self.assertRaises(ValueError):
            self.solver.solve(11)

    def test_invalid_moves_fail_validation(self):
        bad_moves = [
            ("left", "center"),   
            ("left", "center"),   
        ]
        self.assertFalse(self.solver.validate(3, bad_moves))

    def test_first_move(self):
        """Первый ход всегда: либо left->right, либо left->center."""
        for n in range(1, 11):
            moves = self.solver.solve(n)
            self.assertIn(moves[0][0], ["left"])
            self.assertIn(moves[0][1], ["right", "center"])

    def test_last_move(self):
        """Последний ход для чётного/нечётного N."""
        for n in range(1, 11):
            moves = self.solver.solve(n)
            self.assertEqual(moves[-1][1], "right")

    def test_moves_count_method(self):
        """Метод moves_count возвращает 2^n - 1."""
        for n in range(1, 11):
            self.assertEqual(self.solver.moves_count(n), 2**n - 1)


if __name__ == "__main__":
    unittest.main(verbosity=2)
