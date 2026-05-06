#!/usr/bin/env python3
"""
Warehouse Management System — Console UI v4.1 (with get_last_error support)
"""

from warehouse_core import Warehouse, Palete, Worker, Machine


def print_menu() -> None:
    print()
    print("=== Warehouse menu ===")
    print("1. Show warehouse state")
    print("2. Create pallet")
    print("3. Add worker")
    print("4. Add machine")
    print("5. Add profile to pallet")
    print("6. Move profile between pallets")
    print("7. Move pallet")
    print("8. Deliver profiles to machine")
    print("9. Show amount on pallet")
    print("10. Run simple tests")
    print("0. Exit")


# -- UI action functions --

def ui_show_state(w: Warehouse) -> None:
    w.print_state()


def ui_create_pallet(w: Warehouse) -> None:
    try:
        article = int(input("Article: "))
        name = input("Name: ")
        amt = int(input("Initial amount: "))
    except ValueError:
        print("Invalid input — expected integers.")
        return
    p = Palete(name=name, art=article, amt=amt)
    w.add_pallet(p)
    print("Pallet created.")


def ui_add_worker(w: Warehouse) -> None:
    try:
        wid = int(input("Worker ID: "))
    except ValueError:
        print("Invalid ID.")
        return
    name = input("Worker name: ")
    w.add_worker(Worker(wid, name))
    print("Worker added.")


def ui_add_machine(w: Warehouse) -> None:
    try:
        mid = int(input("Machine ID: "))
    except ValueError:
        print("Invalid ID.")
        return
    name = input("Machine name: ")
    w.add_machine(Machine(mid, name))
    print("Machine added.")


def ui_add_profile_to_pallet(w: Warehouse) -> None:
    try:
        article = int(input("Article: "))
        amount = int(input("Amount: "))
        worker_id = int(input("Worker ID: "))
    except ValueError:
        print("Invalid input.")
        return
    ok = w.add_profile_to_pallet(article, amount, worker_id, 0, 1)
    if ok:
        print("Profile added.")
    else:
        print("Operation failed.")


def ui_move_profile_between_pallets(w: Warehouse) -> None:
    try:
        from_art = int(input("From article: "))
        to_art = int(input("To article: "))
        amount = int(input("Amount: "))
        worker_id = int(input("Worker ID: "))
    except ValueError:
        print("Invalid input.")
        return
    ok = w.move_profile_between_pallets(from_art, to_art, amount, worker_id, 1, 2)
    if ok:
        print("Profile moved.")
    else:
        print("Operation failed.")


def ui_move_pallet(w: Warehouse) -> None:
    try:
        article = int(input("Article: "))
        x1 = float(input("x1: "))
        x2 = float(input("x2: "))
        x3 = float(input("x3: "))
        x4 = float(input("x4: "))
        worker_id = int(input("Worker ID: "))
    except ValueError:
        print("Invalid input.")
        return
    ok = w.move_pallet(article, x1, x2, x3, x4, worker_id, 0, 1)
    if ok:
        print("Pallet moved.")
    else:
        print("Operation failed.")


def ui_deliver_to_machine(warehouse_obj: Warehouse) -> None:
    try:
        article = int(input("Article: "))
        amount = int(input("Amount: "))
        machine_id = int(input("Machine ID: "))
    except ValueError:
        print("Invalid input.")
        return
    ok = warehouse_obj.deliver_to_machine(article, amount, machine_id, 0, 1)
    if not ok:
        msg = warehouse_obj.get_last_error()
        if msg:
            print(f"Operation failed: {msg}")
        else:
            print("Operation failed (unknown reason).")
    else:
        print("Profiles delivered to machine.")


def ui_show_amount(w: Warehouse) -> None:
    try:
        article = int(input("Article: "))
    except ValueError:
        print("Invalid article.")
        return
    amount = w.get_pallet_amount(article)
    if amount == -1:
        print("Pallet not found.")
    else:
        print(f"Amount on pallet {article}: {amount}")


def run_tests() -> None:
    """Run 3 lightweight UI-level tests."""
    w = Warehouse()

    # Test 1: add profile
    w.add_pallet(Palete(name="Test1", art=1, amt=10))
    w.add_worker(Worker(1, "Tester"))
    ok = w.add_profile_to_pallet(1, 5, 1, 0, 1)
    if ok and w.get_pallet_amount(1) == 15:
        print("[PASS] Test 1 (add profile)")
    else:
        print("[FAIL] Test 1 (add profile)")

    # Test 2: move profile
    w.add_pallet(Palete(name="Test2", art=2, amt=0))
    ok = w.move_profile_between_pallets(1, 2, 3, 1, 1, 2)
    if ok and w.get_pallet_amount(1) == 12 and w.get_pallet_amount(2) == 3:
        print("[PASS] Test 2 (move profile)")
    else:
        print("[FAIL] Test 2 (move profile)")

    # Test 3: error on non-existent pallet
    w2 = Warehouse()
    ok = w2.add_profile_to_pallet(999, 10, 1, 0, 1)
    if not ok:
        print("[PASS] Test 3 (error handling)")
    else:
        print("[FAIL] Test 3 (error handling)")


# -- main --

def main() -> None:
    warehouse = Warehouse()

    while True:
        print_menu()
        try:
            choice = input("Choice: ").strip()
        except (EOFError, KeyboardInterrupt):
            print()
            break

        if choice == "0":
            print("Goodbye!")
            break
        elif choice == "1":
            ui_show_state(warehouse)
        elif choice == "2":
            ui_create_pallet(warehouse)
        elif choice == "3":
            ui_add_worker(warehouse)
        elif choice == "4":
            ui_add_machine(warehouse)
        elif choice == "5":
            ui_add_profile_to_pallet(warehouse)
        elif choice == "6":
            ui_move_profile_between_pallets(warehouse)
        elif choice == "7":
            ui_move_pallet(warehouse)
        elif choice == "8":
            ui_deliver_to_machine(warehouse)
        elif choice == "9":
            ui_show_amount(warehouse)
        elif choice == "10":
            run_tests()
        else:
            print("Unknown choice. Try again.")


if __name__ == "__main__":
    main()
