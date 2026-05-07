#!/usr/bin/env python3
"""
Integration tests for Warehouse Management System
"""

from warehouse_core import Warehouse, Palete, Worker, Machine, run_python_tests


def main() -> None:
    print("=== Running built-in Python tests ===")
    if run_python_tests():
        print("[PASS] Python core tests")
    else:
        print("[FAIL] Python core tests")
        return

    print("\n=== Integration test scenario ===")
    w = Warehouse()

    # Setup
    w.add_worker(Worker(1, "Alice"))
    w.add_machine(Machine(1, "Machine1"))

    pal_a = Palete(name="Profile A", art=1, amt=10)
    w.add_pallet(pal_a)

    pal_b = Palete(name="Profile B", art=2, amt=10)
    w.add_pallet(pal_b)

    # Operation 1: add 5 to pallet A (10 + 5 = 15)
    w.add_profile_to_pallet(1, 5, 1, 0, 1)

    # Operation 2: move 4 from A to B (A=11, B=14)
    w.move_profile_between_pallets(1, 2, 4, 1, 1, 2)

    # Operation 3: deliver 3 from B to machine (B=11)
    w.deliver_to_machine(2, 3, 1, 2, 3)

    # Verify
    a_amt = w.get_pallet_amount(1)
    b_amt = w.get_pallet_amount(2)

    print(f"Pallet A amount: {a_amt} (expected 11)")
    print(f"Pallet B amount: {b_amt} (expected 11)")

    if a_amt == 11 and b_amt == 11:
        print("[PASS] Integration test")
    else:
        print("[FAIL] Integration test")

    w.print_state()


if __name__ == "__main__":
    main()
