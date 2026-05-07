# Prompt: Реализация системы управления складом (Warehouse Management System) на чистом Python

## Задача

Напиши проект "Система управления складом металлопрофиля" (Warehouse Management System) **полностью на Python 3** — без C++, без pybind11, без компиляции. Вся бизнес-логика, все классы, UI и тесты — только на Python. Можно использовать любые библиотеки Python (стандартные и сторонние), но **запрещено** использовать C++, C, Rust или любые другие компилируемые языки.

## Технологический стек (строго)

- **Только Python 3** — любой версии 3.x (рекомендуется 3.10+)
- Можно использовать любые Python-библиотеки:
  - Стандартная библиотека: `dataclasses`, `abc`, `typing`, `enum` и т.д.
  - Сторонние библиотеки при желании: `pydantic`, `rich`, `click`, `tabulate` и др. (не обязательно)
- Никакого C++, pybind11, Cython, Numba JIT-компиляции в нативный код
- Никакой компиляции — только `.py` файлы, запускаемые интерпретатором Python

## Структура файлов (создать всё в одной папке)

```
warehouse/
├── warehouse_core.py          # Ядро: все классы предметной области + тесты run_python_tests()
├── warehouse_ui.py            # Консольное меню (основная версия)
├── warehouse_ui_v4.1.py       # Консольное меню (с get_last_error)
├── test_warehouse.py          # Интеграционные тесты
├── test_warehouse_v4.1.py     # Расширенные тесты (включая deliver_to_missing_machine)
└── requirements.txt           # (опционально) зависимости, если используются сторонние библиотеки
```

Важно: **никакого build.sh**, **никакой компиляции**, **никаких .so/.pyd/.dll файлов**.

---

## Часть 1. Ядро: warehouse_core.py

Все классы реализованы на чистом Python в одном файле `warehouse_core.py`.

### 1.1 Структуры данных

```python
from dataclasses import dataclass

@dataclass
class Point2D:
    x: int
    y: int

@dataclass
class Point3D:
    x: float
    y: float
    z: float
```

### 1.2 Класс Palete (паллета)

Паллета с металлопрофилем на складе.

**Поля:**
| Поле | Тип | Назначение |
|------|-----|------------|
| x1, x2, x3, x4 | float | Координаты в пространстве склада |
| article | int | Артикул профиля |
| amt_pf | int | Текущее количество профиля |
| last_amt_pf | int | Количество после предыдущей смены |
| pfl_name | str | Наименование профиля |
| last_article | int | Артикул в предыдущую смену |

**Конструктор:**
- `__init__(self, x1=0.0, x2=0.0, x3=0.0, x4=0.0, name="", art=0, amt=0, last_amt=0, last_art=0)` — параметризованный со значениями по умолчанию.

**Методы:**
- `set_coords(self, x1, x2, x3, x4)` — установка всех 4 координат.
- `get_coords(self)` — возвращает кортеж `(x1, x2, x3, x4)`.
- `is_empty(self)` — возвращает True если `amt_pf == 0`.
- `__str__(self)` — строковое представление: артикул, имя, количество, координаты.

**Операторы:**
- `__iadd__(self, amount)` — пополнение паллеты. Если `amount > 0`, то `amt_pf += amount`. Отрицательные игнорируются. Возвращает `self`.
- `__isub__(self, amount)` — отбор с паллеты. Если `amount >= amt_pf`, то `amt_pf = 0` (списывает всё) и выводит предупреждение. Иначе `amt_pf -= amount`. Возвращает `self`.

### 1.3 Класс Cam (камера)

Моделирует камеру видеонаблюдения на складе.

**Поля (все private через `_` префикс):**
| Поле | Тип | Назначение |
|------|-----|------------|
| _x1, _x2, _x3, _x4 | float | Положение и ориентация камеры |
| _phi | float | Горизонтальный угол обзора |
| _framesize | float | Размер кадра |

**Конструктор:** `__init__(self, x1, x2, x3, x4, phi, framesize)` — параметризованный.

**Методы:**
- `set_position(self, x1, x2, x3, x4)` — установка координат.
- `get_position(self)` — возвращает кортеж `(x1, x2, x3, x4)`.
- `get_phi(self)` — возвращает `_phi`.
- `get_framesize(self)` — возвращает `_framesize`.
- `__str__(self)` — строковое представление.

### 1.4 Класс Worker (работник)

**Поля:** `id` (int), `name` (str).

**Конструктор:** `__init__(self, id=0, name="")`

**Методы:** `get_id()`, `get_name()`, `__str__()`.

### 1.5 Класс RecordsW (запись работника)

Наследует Worker. Добавляет поля:
| Поле | Тип | Описание |
|------|-----|----------|
| timest | int | Время начала операции |
| timeend | int | Время окончания операции |
| amm | int | Количество перемещённого профиля |
| art | int | Артикул |

**Конструктор:** параметризованный, принимает все поля (id, name, timest, timeend, amm, art).

**Методы доступа:** `get_start_time()`, `get_end_time()`, `get_amount()`, `get_article()`.

### 1.6 Класс Machine (станок)

**Поля:** `id` (int), `name` (str).

**Конструктор:** `__init__(self, id=0, name="")`

**Методы:** `get_id()`, `get_name()`, `__str__()`.

### 1.7 Класс RecordsM (запись станка)

Наследует Machine. Добавляет те же поля что и RecordsW: `timest` (int), `timeend` (int), `amm` (int), `art` (int).

**Конструктор:** параметризованный.

**Методы доступа:** `get_start_time()`, `get_end_time()`, `get_amount()`, `get_article()`.

### 1.8 Класс LocIm (локализация на изображении)

Хранит результат распознавания профиля на кадре камеры.

**Поля:**
- `cam_id` (int) — идентификатор камеры
- `points` (list[Point2D]) — 2D-точки профиля на изображении

**Методы:**
- `add_point(self, x, y)` — добавляет Point2D(x, y) в points.
- `clear(self)` — очищает points.

### 1.9 Класс LocTr (трёхмерный трек)

Хранит последовательность 3D-точек траектории профиля.

**Поля:**
- `article` (int) — артикул отслеживаемого профиля
- `points` (list[Point3D]) — точки трека

**Методы:**
- `add_point(self, x, y, z)` — добавляет точку.
- `get_article(self)` — возвращает article.
- `get_points(self)` — возвращает список points.

### 1.10 Иерархия событий Event (полиморфизм через ABC)

**Базовый абстрактный класс Event (наследует ABC):**
- `cam_id` (int) — ID камеры
- `x` (int), `y` (int) — координаты на изображении
- `show(self)` — абстрактный метод (декорирован `@abstractmethod`).

**Производные классы:**

1. **WorkerPickupEvent(Event)** — работник взял профиль.
   - Доп. поля: `worker_id` (int), `article` (int).
   - `show()` выводит: `"WorkerPickupEvent: cam={cam_id}, worker={worker_id}, article={article}, at ({x},{y})"`.

2. **WorkerAppearEvent(Event)** — работник с профилем появился в кадре.
   - Доп. поля: `worker_id` (int), `article` (int).
   - `show()` выводит: `"WorkerAppearEvent: cam={cam_id}, worker={worker_id}, article={article}, at ({x},{y})"`.

3. **DeliveryToMachineEvent(Event)** — профиль доставлен к станку.
   - Доп. поля: `machine_id` (int), `article` (int).
   - `show()` выводит: `"DeliveryToMachineEvent: cam={cam_id}, machine={machine_id}, article={article}, at ({x},{y})"`.

### 1.11 Класс Warehouse (склад) — ЦЕНТРАЛЬНЫЙ КЛАСС

Содержит списки:

```python
self.pallets: list[Palete] = []
self.cameras: list[Cam] = []
self.workers: list[Worker] = []
self.machines: list[Machine] = []
self.worker_records: list[RecordsW] = []
self.machine_records: list[RecordsM] = []
self.image_positions: list[LocIm] = []
self.track_positions: list[LocTr] = []
self.last_error: str = ""
```

#### Приватные вспомогательные методы

- `_find_pallet_by_article(self, article)` — ищет в pallets паллету с артикулом == article. Возвращает индекс или -1.

- `_find_machine_by_id(self, id)` — ищет в machines станок с id == id. Возвращает индекс или -1.

- `_set_error(self, msg)` — присваивает `last_error = msg` и выводит msg в stderr.

#### Публичные методы управления объектами

| Метод | Сигнатура | Логика |
|-------|-----------|--------|
| add_camera | `add_camera(self, c: Cam)` | append в cameras |
| add_worker | `add_worker(self, w: Worker)` | append в workers |
| add_machine | `add_machine(self, m: Machine)` | append в machines |
| add_pallet | `add_pallet(self, p: Palete)` | Если паллета с таким article уже существует — вывод предупреждения. Затем append. |
| create_empty_pallet | `create_empty_pallet(self, x1, x2, x3, x4, name, art)` | Создаёт Palete с amt_pf=0 и добавляет через add_pallet. |
| remove_pallet | `remove_pallet(self, article) -> bool` | Если паллета не найдена ИЛИ не пуста — возвращает False. Иначе удаляет и возвращает True. |

#### Публичные методы операций с профилем

Все операции с профилем создают соответствующие записи в worker_records или machine_records.

- `add_profile_to_pallet(self, article, amount, worker_id, t_start, t_end) -> bool`
  — Если amount <= 0 или паллета не найдена → `_set_error(...)` → return False.
  — Иначе: `pallets[idx] += amount`; `worker_records.append(RecordsW(worker_id, "", t_start, t_end, amount, article))`; return True.

- `take_profile_from_pallet(self, article, amount, worker_id, t_start, t_end) -> bool`
  — Если паллета не найдена или amount <= 0 → return False.
  — `pallets[idx] -= amount`; `worker_records.append(...)`; return True.

- `move_profile_between_pallets(self, from_article, to_article, amount, worker_id, t_start, t_end) -> bool`
  — Вызывает `take_profile_from_pallet(from_article, ...)` — если False, return False.
  — Вызывает `add_profile_to_pallet(to_article, ...)` — если False, делает ROLLBACK (возвращает профиль обратно) и return False.
  — return True.

- `move_pallet(self, article, x1, x2, x3, x4, worker_id, t_start, t_end) -> bool`
  — Поиск паллеты по article. Если не найдена → return False.
  — `pallets[idx].set_coords(x1, x2, x3, x4)`.
  — `worker_records.append(RecordsW(worker_id, "", t_start, t_end, 0, article))`.
  — return True.

- `deliver_to_machine(self, article, amount, machine_id, t_start, t_end) -> bool`
  — Если amount <= 0 → `_set_error("invalid amount")` → return False.
  — Если станок не найден → `_set_error("machine does not exist")` → return False.
  — Если паллета не найдена → `_set_error("pallet not found")` → return False.
  — `pallets[idx] -= amount`.
  — `machine_records.append(RecordsM(machine_id, "", t_start, t_end, amount, article))`.
  — return True.

- `get_pallet_amount(self, article) -> int`
  — Поиск паллеты. Если найдена → возвращает `pallets[idx].amt_pf`. Иначе возвращает -1.

#### Публичные методы позиционирования

- `add_image_location(self, li: LocIm)` — append в image_positions.
- `add_track_location(self, lt: LocTr)` — append в track_positions.
- `check_visibility(self)` — если есть хоть одна паллета с `amt_pf > 0`, а `image_positions` пуст — выводит предупреждение: "Warning: warehouse has stock but vision system detects nothing".

#### Прочие методы

- `get_last_error(self) -> str` — возвращает last_error.
- `print_state(self)` — выводит в stdout:
  - Количество паллет, работников, станков.
  - Количество записей в worker_records и machine_records.
  - Для каждой паллеты вызывает `str(pallets[i])`.

### 1.12 Функция run_python_tests()

`run_python_tests() -> bool` — запускает 5 встроенных тестов. Возвращает True если все пройдены.

**Тест 1: Операторы Palete**
- Создать Palete(name="Test", art=100, amt=10)
- `+= 5` → ожидается 15
- `-= 3` → ожидается 12
- Если не 12 → вывести "TEST 1 FAILED"

**Тест 2: Складские операции**
- Создать Warehouse. Добавить 2 паллеты: A(article=1, amt=10), B(article=2, amt=10).
- `add_worker(Worker(1, "Tester"))`.
- `add_profile_to_pallet(1, 10, 1, 0, 1)` — A становится 20.
- `move_profile_between_pallets(1, 2, 4, 1, 1, 2)` — A=16, B=14.
- Проверка: `get_pallet_amount(1) == 16`, `get_pallet_amount(2) == 14`.
- Если нет → "TEST 2 FAILED".

**Тест 3: Обработка ошибок**
- Создать пустой Warehouse.
- `add_profile_to_pallet(999, 10, 1, 0, 1)` — ожидается False.
- Если True → "TEST 3 FAILED".

**Тест 4: Доставка к станку**
- Warehouse с паллетой (article=100, amt=20) и станком (id=1, name="Machine1").
- `deliver_to_machine(100, 5, 1, 0, 1)`.
- `get_pallet_amount(100)` должен быть 15.
- Если не 15 → "TEST 4 FAILED".

**Тест 5: Полиморфизм Event**
- Создать список `events: list[Event]`.
- Добавить по одному WorkerPickupEvent, WorkerAppearEvent, DeliveryToMachineEvent.
- Вызвать `show()` для каждого (вывод в stdout).
- Тест считается пройденным, если все три вызова отработали без исключений.

---

## Часть 2. Python: warehouse_ui.py

Консольное меню в бесконечном цикле.

```python
from warehouse_core import Warehouse, Palete, Worker, Machine

warehouse = Warehouse()
```

**Функция `print_menu()`:**
```
=== Warehouse menu ===
1. Show warehouse state
2. Create pallet
3. Add worker
4. Add machine
5. Add profile to pallet
6. Move profile between pallets
7. Move pallet
8. Deliver profiles to machine
9. Show amount on pallet
10. Run simple tests
0. Exit
```

**Функции ui_* (каждая принимает warehouse_obj):**

1. `ui_create_pallet(w)` — запрашивает article, name, initial amount. Создаёт Palete, заполняет поля. Вызывает w.add_pallet(p). "Pallet created."

2. `ui_add_worker(w)` — запрашивает id, name. w.add_worker(Worker(id, name)). "Worker added."

3. `ui_add_machine(w)` — запрашивает id, name. w.add_machine(Machine(id, name)). "Machine added."

4. `ui_add_profile_to_pallet(w)` — запрашивает article, amount, worker_id. Вызывает w.add_profile_to_pallet(article, amount, worker_id, 0, 1). Если True → "Profile added." Иначе → "Operation failed."

5. `ui_move_profile_between_pallets(w)` — запрашивает from_article, to_article, amount, worker_id. w.move_profile_between_pallets(...). Вывод результата.

6. `ui_move_pallet(w)` — запрашивает article, x1-x4, worker_id. w.move_pallet(...). Вывод результата.

7. `ui_deliver_to_machine(w)` — запрашивает article, amount, machine_id. w.deliver_to_machine(article, amount, machine_id, 0, 1). Если True → "Delivered." Иначе → "Delivery failed."

8. `ui_show_amount(w)` — запрашивает article. amount = w.get_pallet_amount(article). Если -1 → "Pallet not found." Иначе → f"Amount on pallet {article}: {amount}"

**Функция `run_tests()`:**
Выполняет 3 Python-теста и выводит [PASS] / [FAIL]:
1. Пополнение (add_profile_to_pallet)
2. Перемещение (move_profile_between_pallets)
3. Обработка ошибок (пополнение несуществующей паллеты — ожидание False)

**Функция `main()`:**
- Импорт из warehouse_core.
- Создаёт Warehouse.
- Бесконечный цикл: print_menu(), read choice, switch по выбору.
- 0 → break (выход).
- 10 → run_tests().
- Остальные → соответствующие ui_* функции.

---

## Часть 3. Python: warehouse_ui_v4.1.py

Копия warehouse_ui.py с одним отличием: **ui_deliver_to_machine** использует `get_last_error()`:

```python
def ui_deliver_to_machine(warehouse_obj):
    article = int(input("Article: "))
    amount = int(input("Amount: "))
    machine_id = int(input("Machine ID: "))
    ok = warehouse_obj.deliver_to_machine(article, amount, machine_id, 0, 1)
    if not ok:
        msg = warehouse_obj.get_last_error()
        if msg:
            print(f"Operation failed: {msg}")
        else:
            print("Operation failed (unknown reason).")
    else:
        print("Profiles delivered to machine.")
```

---

## Часть 4. Python: test_warehouse.py

```python
from warehouse_core import Warehouse, Palete, Worker, Machine, run_python_tests

def main():
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
```

---

## Часть 5. Python: test_warehouse_v4.1.py

Всё то же что в test_warehouse.py, плюс дополнительный тест:

```python
def test_deliver_to_missing_machine():
    print("\n=== Test: deliver to missing machine ===")
    w = Warehouse()

    p = Palete(name="Profile A", art=1, amt=10)
    w.add_pallet(p)

    # Попытка доставки к несуществующему станку 999
    ok = w.deliver_to_machine(1, 5, 999, 0, 1)

    if not ok:
        err = w.get_last_error()
        if err:
            print(f"[PASS] Correctly rejected. Error: {err}")
        else:
            print("[FAIL] Rejected but no error message")
    else:
        print("[FAIL] Should have been rejected")

# Вызвать в main() после стандартных тестов
```

---

## Часть 6. Требования к коду

### warehouse_core.py (основной модуль)

- Все классы в одном файле.
- Можно использовать:
  - `dataclasses` для структур (Point2D, Point3D).
  - `abc.ABC` и `@abstractmethod` для полиморфной иерархии Event.
  - Любые другие модули стандартной библиотеки.
- Операторы `__iadd__` и `__isub__` для класса Palete.
- Полиморфизм через наследование от абстрактного класса Event.
- Функция `run_python_tests()` встроена в этот же модуль.

### warehouse_ui.py / warehouse_ui_v4.1.py

- Только стандартная библиотека (input, print, циклы).
- Импорт из warehouse_core: `from warehouse_core import Warehouse, Palete, Worker, Machine`.
- Кодировка UTF-8.
- В v4.1 — улучшенная обработка ошибок через `get_last_error()`.

### test_warehouse.py / test_warehouse_v4.1.py

- Импорт из warehouse_core.
- Вывод [PASS]/[FAIL] для каждого теста.
- В v4.1 добавлен тест `test_deliver_to_missing_machine`.

---

## Ожидаемый результат после выполнения

1. `python3 warehouse_core.py` — ничего не выводит (или выводит если есть `if __name__ == "__main__": run_python_tests()`).
2. `python3 warehouse_ui.py` — интерактивное меню.
3. `python3 test_warehouse.py` — PASS всех тестов.
4. `python3 test_warehouse_v4.1.py` — PASS всех тестов + test_deliver_to_missing_machine.

---

## Что НЕ нужно делать

- ❌ Никакого C++, C, Rust, Cython, Numba — только чистый Python.
- ❌ Никакой компиляции: ни build.sh, ни Makefile, ни CMakeLists.txt.
- ❌ Никаких .so, .pyd, .dll файлов.
- ❌ Никакого pybind11.
- ❌ Никаких внешних нативных расширений.
- ❌ Никаких Docker-файлов (если только пользователь явно не попросит).
- ✅ Можно использовать любые Python-библиотеки из PyPI.
