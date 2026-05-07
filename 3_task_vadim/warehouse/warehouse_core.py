"""
Warehouse Management System — Core Module (Pure Python 3)
"""

from __future__ import annotations

import sys
from abc import ABC, abstractmethod
from dataclasses import dataclass


# ---------------------------------------------------------------------------
# 1.1 Data structures
# ---------------------------------------------------------------------------

@dataclass
class Point2D:
    x: int
    y: int


@dataclass
class Point3D:
    x: float
    y: float
    z: float


# ---------------------------------------------------------------------------
# 1.2 Palete (pallet)
# ---------------------------------------------------------------------------

class Palete:
    """A pallet with metal profiles in the warehouse."""

    __slots__ = ("x1", "x2", "x3", "x4", "article", "amt_pf",
                 "last_amt_pf", "pfl_name", "last_article")

    def __init__(
        self,
        x1: float = 0.0,
        x2: float = 0.0,
        x3: float = 0.0,
        x4: float = 0.0,
        name: str = "",
        art: int = 0,
        amt: int = 0,
        last_amt: int = 0,
        last_art: int = 0,
    ):
        self.x1 = x1
        self.x2 = x2
        self.x3 = x3
        self.x4 = x4
        self.article = art
        self.amt_pf = amt
        self.last_amt_pf = last_amt
        self.pfl_name = name
        self.last_article = last_art

    # -- methods --

    def set_coords(self, x1: float, x2: float, x3: float, x4: float) -> None:
        self.x1 = x1
        self.x2 = x2
        self.x3 = x3
        self.x4 = x4

    def get_coords(self) -> tuple[float, float, float, float]:
        return (self.x1, self.x2, self.x3, self.x4)

    def is_empty(self) -> bool:
        return self.amt_pf == 0

    def __str__(self) -> str:
        coords = self.get_coords()
        return (
            f"Palete(article={self.article}, name={self.pfl_name!r}, "
            f"amt={self.amt_pf}, last_amt={self.last_amt_pf}, "
            f"last_article={self.last_article}, "
            f"coords=({coords[0]:.1f}, {coords[1]:.1f}, {coords[2]:.1f}, {coords[3]:.1f}))"
        )

    # -- operators --

    def __iadd__(self, amount: int) -> Palete:
        if amount > 0:
            self.amt_pf += amount
        return self

    def __isub__(self, amount: int) -> Palete:
        if amount >= self.amt_pf:
            if self.amt_pf > 0:
                print(
                    f"Warning: taking more than available ({amount} >= {self.amt_pf}), "
                    f"emptying pallet article={self.article}",
                    file=sys.stderr,
                )
            self.amt_pf = 0
        else:
            self.amt_pf -= amount
        return self


# ---------------------------------------------------------------------------
# 1.3 Cam (camera)
# ---------------------------------------------------------------------------

class Cam:
    """Models a surveillance camera in the warehouse."""

    __slots__ = ("_x1", "_x2", "_x3", "_x4", "_phi", "_framesize")

    def __init__(
        self,
        x1: float = 0.0,
        x2: float = 0.0,
        x3: float = 0.0,
        x4: float = 0.0,
        phi: float = 0.0,
        framesize: float = 0.0,
    ):
        self._x1 = x1
        self._x2 = x2
        self._x3 = x3
        self._x4 = x4
        self._phi = phi
        self._framesize = framesize

    def set_position(self, x1: float, x2: float, x3: float, x4: float) -> None:
        self._x1 = x1
        self._x2 = x2
        self._x3 = x3
        self._x4 = x4

    def get_position(self) -> tuple[float, float, float, float]:
        return (self._x1, self._x2, self._x3, self._x4)

    def get_phi(self) -> float:
        return self._phi

    def get_framesize(self) -> float:
        return self._framesize

    def __str__(self) -> str:
        pos = self.get_position()
        return (
            f"Cam(pos=({pos[0]:.1f},{pos[1]:.1f},{pos[2]:.1f},{pos[3]:.1f}), "
            f"phi={self._phi:.1f}, framesize={self._framesize:.1f})"
        )


# ---------------------------------------------------------------------------
# 1.4 Worker
# ---------------------------------------------------------------------------

class Worker:
    __slots__ = ("id", "name")

    def __init__(self, id: int = 0, name: str = "") -> None:
        self.id = id
        self.name = name

    def get_id(self) -> int:
        return self.id

    def get_name(self) -> str:
        return self.name

    def __str__(self) -> str:
        return f"Worker(id={self.id}, name={self.name!r})"


# ---------------------------------------------------------------------------
# 1.5 RecordsW (worker record)
# ---------------------------------------------------------------------------

class RecordsW(Worker):
    __slots__ = ("timest", "timeend", "amm", "art")

    def __init__(
        self,
        id: int = 0,
        name: str = "",
        timest: int = 0,
        timeend: int = 0,
        amm: int = 0,
        art: int = 0,
    ) -> None:
        super().__init__(id, name)
        self.timest = timest
        self.timeend = timeend
        self.amm = amm
        self.art = art

    def get_start_time(self) -> int:
        return self.timest

    def get_end_time(self) -> int:
        return self.timeend

    def get_amount(self) -> int:
        return self.amm

    def get_article(self) -> int:
        return self.art

    def __str__(self) -> str:
        return (
            f"RecordsW(worker_id={self.id}, {self.timest}-{self.timeend}, "
            f"amm={self.amm}, art={self.art})"
        )


# ---------------------------------------------------------------------------
# 1.6 Machine
# ---------------------------------------------------------------------------

class Machine:
    __slots__ = ("id", "name")

    def __init__(self, id: int = 0, name: str = "") -> None:
        self.id = id
        self.name = name

    def get_id(self) -> int:
        return self.id

    def get_name(self) -> str:
        return self.name

    def __str__(self) -> str:
        return f"Machine(id={self.id}, name={self.name!r})"


# ---------------------------------------------------------------------------
# 1.7 RecordsM (machine record)
# ---------------------------------------------------------------------------

class RecordsM(Machine):
    __slots__ = ("timest", "timeend", "amm", "art")

    def __init__(
        self,
        id: int = 0,
        name: str = "",
        timest: int = 0,
        timeend: int = 0,
        amm: int = 0,
        art: int = 0,
    ) -> None:
        super().__init__(id, name)
        self.timest = timest
        self.timeend = timeend
        self.amm = amm
        self.art = art

    def get_start_time(self) -> int:
        return self.timest

    def get_end_time(self) -> int:
        return self.timeend

    def get_amount(self) -> int:
        return self.amm

    def get_article(self) -> int:
        return self.art

    def __str__(self) -> str:
        return (
            f"RecordsM(machine_id={self.id}, {self.timest}-{self.timeend}, "
            f"amm={self.amm}, art={self.art})"
        )


# ---------------------------------------------------------------------------
# 1.8 LocIm (image localisation)
# ---------------------------------------------------------------------------

class LocIm:
    """Stores recognition result of a profile on a camera frame."""

    __slots__ = ("cam_id", "points")

    def __init__(self, cam_id: int = 0) -> None:
        self.cam_id = cam_id
        self.points: list[Point2D] = []

    def add_point(self, x: int, y: int) -> None:
        self.points.append(Point2D(x, y))

    def clear(self) -> None:
        self.points.clear()

    def __str__(self) -> str:
        return f"LocIm(cam={self.cam_id}, points={len(self.points)})"


# ---------------------------------------------------------------------------
# 1.9 LocTr (3-D track)
# ---------------------------------------------------------------------------

class LocTr:
    """Stores a sequence of 3-D points for a profile trajectory."""

    __slots__ = ("article", "points")

    def __init__(self, article: int = 0) -> None:
        self.article = article
        self.points: list[Point3D] = []

    def add_point(self, x: float, y: float, z: float) -> None:
        self.points.append(Point3D(x, y, z))

    def get_article(self) -> int:
        return self.article

    def get_points(self) -> list[Point3D]:
        return self.points

    def __str__(self) -> str:
        return f"LocTr(article={self.article}, points={len(self.points)})"


# ---------------------------------------------------------------------------
# 1.10 Event hierarchy (polymorphism via ABC)
# ---------------------------------------------------------------------------

class Event(ABC):
    __slots__ = ("cam_id", "x", "y")

    def __init__(self, cam_id: int = 0, x: int = 0, y: int = 0) -> None:
        self.cam_id = cam_id
        self.x = x
        self.y = y

    @abstractmethod
    def show(self) -> None:
        ...


class WorkerPickupEvent(Event):
    """Worker picked up a profile."""

    __slots__ = ("worker_id", "article")

    def __init__(
        self, cam_id: int = 0, x: int = 0, y: int = 0,
        worker_id: int = 0, article: int = 0,
    ) -> None:
        super().__init__(cam_id, x, y)
        self.worker_id = worker_id
        self.article = article

    def show(self) -> None:
        print(
            f"WorkerPickupEvent: cam={self.cam_id}, worker={self.worker_id}, "
            f"article={self.article}, at ({self.x},{self.y})"
        )


class WorkerAppearEvent(Event):
    """Worker with a profile appeared in the frame."""

    __slots__ = ("worker_id", "article")

    def __init__(
        self, cam_id: int = 0, x: int = 0, y: int = 0,
        worker_id: int = 0, article: int = 0,
    ) -> None:
        super().__init__(cam_id, x, y)
        self.worker_id = worker_id
        self.article = article

    def show(self) -> None:
        print(
            f"WorkerAppearEvent: cam={self.cam_id}, worker={self.worker_id}, "
            f"article={self.article}, at ({self.x},{self.y})"
        )


class DeliveryToMachineEvent(Event):
    """Profile delivered to a machine."""

    __slots__ = ("machine_id", "article")

    def __init__(
        self, cam_id: int = 0, x: int = 0, y: int = 0,
        machine_id: int = 0, article: int = 0,
    ) -> None:
        super().__init__(cam_id, x, y)
        self.machine_id = machine_id
        self.article = article

    def show(self) -> None:
        print(
            f"DeliveryToMachineEvent: cam={self.cam_id}, machine={self.machine_id}, "
            f"article={self.article}, at ({self.x},{self.y})"
        )


# ---------------------------------------------------------------------------
# 1.11 Warehouse (central class)
# ---------------------------------------------------------------------------

class Warehouse:
    """Central warehouse management class."""

    def __init__(self) -> None:
        self.pallets: list[Palete] = []
        self.cameras: list[Cam] = []
        self.workers: list[Worker] = []
        self.machines: list[Machine] = []
        self.worker_records: list[RecordsW] = []
        self.machine_records: list[RecordsM] = []
        self.image_positions: list[LocIm] = []
        self.track_positions: list[LocTr] = []
        self.last_error: str = ""

    # -- private helpers --

    def _find_pallet_by_article(self, article: int) -> int:
        for i, p in enumerate(self.pallets):
            if p.article == article:
                return i
        return -1

    def _find_machine_by_id(self, id: int) -> int:
        for i, m in enumerate(self.machines):
            if m.id == id:
                return i
        return -1

    def _set_error(self, msg: str) -> None:
        self.last_error = msg
        print(msg, file=sys.stderr)

    # -- public: manage objects --

    def add_camera(self, c: Cam) -> None:
        self.cameras.append(c)

    def add_worker(self, w: Worker) -> None:
        self.workers.append(w)

    def add_machine(self, m: Machine) -> None:
        self.machines.append(m)

    def add_pallet(self, p: Palete) -> None:
        if self._find_pallet_by_article(p.article) != -1:
            print(
                f"Warning: pallet with article {p.article} already exists",
                file=sys.stderr,
            )
        self.pallets.append(p)

    def create_empty_pallet(
        self, x1: float, x2: float, x3: float, x4: float,
        name: str, art: int,
    ) -> None:
        p = Palete(x1=x1, x2=x2, x3=x3, x4=x4, name=name, art=art, amt=0)
        self.add_pallet(p)

    def remove_pallet(self, article: int) -> bool:
        idx = self._find_pallet_by_article(article)
        if idx == -1:
            return False
        if not self.pallets[idx].is_empty():
            return False
        self.pallets.pop(idx)
        return True

    # -- public: profile operations --

    def add_profile_to_pallet(
        self, article: int, amount: int,
        worker_id: int, t_start: int, t_end: int,
    ) -> bool:
        if amount <= 0:
            self._set_error(f"add_profile_to_pallet: invalid amount {amount}")
            return False
        idx = self._find_pallet_by_article(article)
        if idx == -1:
            self._set_error(f"add_profile_to_pallet: pallet with article {article} not found")
            return False
        self.pallets[idx] += amount
        self.worker_records.append(
            RecordsW(worker_id, "", t_start, t_end, amount, article)
        )
        return True

    def take_profile_from_pallet(
        self, article: int, amount: int,
        worker_id: int, t_start: int, t_end: int,
    ) -> bool:
        idx = self._find_pallet_by_article(article)
        if idx == -1:
            self._set_error(f"take_profile_from_pallet: pallet with article {article} not found")
            return False
        if amount <= 0:
            self._set_error(f"take_profile_from_pallet: invalid amount {amount}")
            return False
        self.pallets[idx] -= amount
        self.worker_records.append(
            RecordsW(worker_id, "", t_start, t_end, amount, article)
        )
        return True

    def move_profile_between_pallets(
        self, from_article: int, to_article: int, amount: int,
        worker_id: int, t_start: int, t_end: int,
    ) -> bool:
        if not self.take_profile_from_pallet(from_article, amount, worker_id, t_start, t_end):
            return False
        if not self.add_profile_to_pallet(to_article, amount, worker_id, t_start, t_end):
            # ROLLBACK
            self.add_profile_to_pallet(from_article, amount, worker_id, t_start, t_end)
            return False
        return True

    def move_pallet(
        self, article: int,
        x1: float, x2: float, x3: float, x4: float,
        worker_id: int, t_start: int, t_end: int,
    ) -> bool:
        idx = self._find_pallet_by_article(article)
        if idx == -1:
            self._set_error(f"move_pallet: pallet with article {article} not found")
            return False
        self.pallets[idx].set_coords(x1, x2, x3, x4)
        self.worker_records.append(
            RecordsW(worker_id, "", t_start, t_end, 0, article)
        )
        return True

    def deliver_to_machine(
        self, article: int, amount: int,
        machine_id: int, t_start: int, t_end: int,
    ) -> bool:
        if amount <= 0:
            self._set_error("invalid amount")
            return False
        if self._find_machine_by_id(machine_id) == -1:
            self._set_error("machine does not exist")
            return False
        idx = self._find_pallet_by_article(article)
        if idx == -1:
            self._set_error("pallet not found")
            return False
        self.pallets[idx] -= amount
        self.machine_records.append(
            RecordsM(machine_id, "", t_start, t_end, amount, article)
        )
        return True

    def get_pallet_amount(self, article: int) -> int:
        idx = self._find_pallet_by_article(article)
        if idx == -1:
            return -1
        return self.pallets[idx].amt_pf

    # -- public: positioning --

    def add_image_location(self, li: LocIm) -> None:
        self.image_positions.append(li)

    def add_track_location(self, lt: LocTr) -> None:
        self.track_positions.append(lt)

    def check_visibility(self) -> None:
        has_stock = any(p.amt_pf > 0 for p in self.pallets)
        if has_stock and not self.image_positions:
            print(
                "Warning: warehouse has stock but vision system detects nothing",
                file=sys.stderr,
            )

    # -- misc --

    def get_last_error(self) -> str:
        return self.last_error

    def print_state(self) -> None:
        print(f"Pallets: {len(self.pallets)}")
        print(f"Workers: {len(self.workers)}")
        print(f"Machines: {len(self.machines)}")
        print(f"Worker records: {len(self.worker_records)}")
        print(f"Machine records: {len(self.machine_records)}")
        for i, p in enumerate(self.pallets):
            print(f"  [{i}] {p}")


# ---------------------------------------------------------------------------
# 1.12 Built-in tests
# ---------------------------------------------------------------------------

def run_python_tests() -> bool:
    """Run 5 built-in tests. Returns True if all pass."""
    all_passed = True

    # -- Test 1: Palete operators --
    p = Palete(name="Test", art=100, amt=10)
    p += 5
    p -= 3
    if p.amt_pf != 12:
        print("TEST 1 FAILED")
        all_passed = False

    # -- Test 2: Warehouse operations --
    w = Warehouse()
    w.add_pallet(Palete(name="A", art=1, amt=10))
    w.add_pallet(Palete(name="B", art=2, amt=10))
    w.add_worker(Worker(1, "Tester"))
    w.add_profile_to_pallet(1, 10, 1, 0, 1)   # A = 20
    w.move_profile_between_pallets(1, 2, 4, 1, 1, 2)  # A=16, B=14
    if w.get_pallet_amount(1) != 16 or w.get_pallet_amount(2) != 14:
        print("TEST 2 FAILED")
        all_passed = False

    # -- Test 3: Error handling --
    w2 = Warehouse()
    res = w2.add_profile_to_pallet(999, 10, 1, 0, 1)
    if res:
        print("TEST 3 FAILED")
        all_passed = False

    # -- Test 4: Delivery to machine --
    w3 = Warehouse()
    w3.add_pallet(Palete(name="P", art=100, amt=20))
    w3.add_machine(Machine(1, "Machine1"))
    w3.deliver_to_machine(100, 5, 1, 0, 1)
    if w3.get_pallet_amount(100) != 15:
        print("TEST 4 FAILED")
        all_passed = False

    # -- Test 5: Event polymorphism --
    events: list[Event] = [
        WorkerPickupEvent(cam_id=1, x=10, y=20, worker_id=5, article=100),
        WorkerAppearEvent(cam_id=2, x=30, y=40, worker_id=6, article=200),
        DeliveryToMachineEvent(cam_id=3, x=50, y=60, machine_id=7, article=300),
    ]
    try:
        for ev in events:
            ev.show()
    except Exception:
        print("TEST 5 FAILED")
        all_passed = False

    return all_passed


# ---------------------------------------------------------------------------
# Standalone run
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    ok = run_python_tests()
    if ok:
        print("All built-in tests PASSED")
    else:
        print("Some tests FAILED")
        sys.exit(1)
