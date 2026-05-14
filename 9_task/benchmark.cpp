
#include "QuadTree.h"
#include <iostream>
#include <iomanip>
#include <chrono>
#include <vector>
#include <memory>
#include <random>
#include <cmath>
#include <string>
#include <functional>

// ---------------------------------------------------------------------------
// ТИПЫ ДАННЫХ (из проекта муравьиной колонии)
// ---------------------------------------------------------------------------

/// Тип агента
enum class AgentType { Scout, Worker };

/// Данные сущности (агент или еда)
struct Entity {
    std::string entityType;  // "agent" или "food"
    AgentType role;          // значимо только для agent
    int energy;
    std::string id;

    Entity() : entityType("agent"), role(AgentType::Worker), energy(100), id("") {}
    Entity(const std::string& t, AgentType r, int e, const std::string& i)
        : entityType(t), role(r), energy(e), id(i) {}

    bool operator==(const Entity& other) const {
        return id == other.id;
    }
};

/// Агент (аналог Agent из проекта)
struct Agent {
    double x, y;
    AgentType role;
    int energy;
    std::string id;

    Agent(double x_, double y_, AgentType r, int e, const std::string& i)
        : x(x_), y(y_), role(r), energy(e), id(i) {}
};

// ---------------------------------------------------------------------------
// ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
// ---------------------------------------------------------------------------

/// Генератор случайных координат в диапазоне [0, limit)
double randomCoord(double limit) {
    static std::mt19937 rng(42);
    static std::uniform_real_distribution<double> dist(0.0, limit);
    return dist(rng);
}

/// Таймер высокого разрешения
class Timer {
    using Clock = std::chrono::high_resolution_clock;
    using TimePoint = Clock::time_point;
    TimePoint start_;
public:
    Timer() : start_(Clock::now()) {}
    /// Возвращает прошедшее время в микросекундах
    double elapsedUs() const {
        auto end = Clock::now();
        return std::chrono::duration<double, std::micro>(end - start_).count();
    }
};

// ---------------------------------------------------------------------------
// БЕНЧМАРК: ВСТАВКА
// ---------------------------------------------------------------------------

/// Измерить время полной вставки N элементов в Quadtree
void benchQuadtreeInsert(const std::vector<int>& sizes) {
    std::cout << "\n─── C++ Quadtree: вставка ───\n\n";
    std::cout << std::left
              << std::setw(10) << "Размер N"
              << std::setw(22) << "Общее время (мкс)"
              << std::setw(26) << "На 1 элемент (мкс)"
              << std::setw(26) << "1 вставка в полное (мкс)"
              << "\n";
    std::cout << std::string(84, '-') << "\n";

    for (int n : sizes) {
        // --- Полная вставка N элементов ---
        Timer t;
        QuadTree<Entity> tree(Region(400.0, 400.0, 400.0));
        for (int i = 0; i < n; ++i) {
            Entity ent("agent",
                       (i % 2 == 0) ? AgentType::Worker : AgentType::Scout,
                       100,
                       "agent_" + std::to_string(i));
            tree.insert(Point<Entity>(
                randomCoord(800.0), randomCoord(800.0), ent));
        }
        double totalUs = t.elapsedUs();

        if (tree.size() != n) {
            std::cerr << "ОШИБКА: размер дерева " << tree.size()
                      << " != " << n << "\n";
        }

        // --- Одна вставка в уже полное дерево ---
        Entity extra("agent", AgentType::Scout, 50, "extra");
        Timer t2;
        tree.insert(Point<Entity>(randomCoord(800.0), randomCoord(800.0), extra));
        double singleUs = t2.elapsedUs();

        std::cout << std::fixed << std::setprecision(2)
                  << std::setw(10) << n
                  << std::setw(22) << totalUs
                  << std::setw(26) << (n > 0 ? totalUs / n : 0.0)
                  << std::setw(26) << singleUs
                  << "\n";
    }
}

/// Измерить время вставки в std::vector (push_back)
void benchVectorInsert(const std::vector<int>& sizes) {
    std::cout << "\n─── std::vector: вставка (push_back) ───\n\n";
    std::cout << std::left
              << std::setw(10) << "Размер N"
              << std::setw(22) << "Общее время (мкс)"
              << std::setw(26) << "На 1 элемент (мкс)"
              << "\n";
    std::cout << std::string(58, '-') << "\n";

    for (int n : sizes) {
        Timer t;
        std::vector<std::unique_ptr<Agent>> agents;
        agents.reserve(n);  // как в оригинальном проекте
        for (int i = 0; i < n; ++i) {
            agents.push_back(std::make_unique<Agent>(
                randomCoord(800.0), randomCoord(800.0),
                (i % 2 == 0) ? AgentType::Worker : AgentType::Scout,
                100, "agent_" + std::to_string(i)));
        }
        double totalUs = t.elapsedUs();

        std::cout << std::fixed << std::setprecision(2)
                  << std::setw(10) << n
                  << std::setw(22) << totalUs
                  << std::setw(26) << (n > 0 ? totalUs / n : 0.0)
                  << "\n";
    }
}

// ---------------------------------------------------------------------------
// БЕНЧМАРК: ПОИСК В РАДИУСЕ (главная операция симуляции)
// ---------------------------------------------------------------------------

/// Поиск в радиусе для std::vector (полный перебор O(n))
std::vector<const Agent*> vectorQueryRadius(
    const std::vector<std::unique_ptr<Agent>>& agents,
    double qx, double qy, double r)
{
    std::vector<const Agent*> result;
    for (const auto& a : agents) {
        double dx = a->x - qx;
        double dy = a->y - qy;
        if (std::sqrt(dx * dx + dy * dy) <= r) {
            result.push_back(a.get());
        }
    }
    return result;
}

/// Сравнение поиска в радиусе
void benchRadiusQuery(const std::vector<int>& sizes) {
    std::cout << "\n─── Поиск в радиусе: Quadtree vs Vector ───\n\n";
    std::cout << std::left
              << std::setw(10) << "Размер N"
              << std::setw(22) << "Quadtree (мкс)"
              << std::setw(22) << "Vector (мкс)"
              << std::setw(20) << "Ускорение"
              << "\n";
    std::cout << std::string(74, '-') << "\n";

    const int queries = 100;  // количество запросов для усреднения

    for (int n : sizes) {
        // Строим оба контейнера с одинаковыми данными
        QuadTree<Entity> tree(Region(400.0, 400.0, 400.0));
        std::vector<std::unique_ptr<Agent>> vec;
        vec.reserve(n);

        // Фиксируем точки для воспроизводимости
        std::vector<std::pair<double, double>> coords;
        for (int i = 0; i < n; ++i) {
            coords.emplace_back(randomCoord(800.0), randomCoord(800.0));
        }

        for (int i = 0; i < n; ++i) {
            double x = coords[i].first;
            double y = coords[i].second;
            Entity ent("agent",
                       (i % 2 == 0) ? AgentType::Worker : AgentType::Scout,
                       100, "agent_" + std::to_string(i));
            tree.insert(Point<Entity>(x, y, ent));
            vec.push_back(std::make_unique<Agent>(
                x, y,
                (i % 2 == 0) ? AgentType::Worker : AgentType::Scout,
                100, "agent_" + std::to_string(i)));
        }

        // Случайные точки запросов
        std::vector<std::pair<double, double>> queryPoints;
        for (int i = 0; i < queries; ++i) {
            queryPoints.emplace_back(randomCoord(800.0), randomCoord(800.0));
        }

        // Quadtree запросы
        Timer t1;
        int foundQT = 0;
        for (const auto& qp : queryPoints) {
            auto res = tree.queryRadius(qp.first, qp.second, 80.0);
            foundQT += static_cast<int>(res.size());
        }
        double qtUs = t1.elapsedUs() / queries;

        // Vector запросы
        Timer t2;
        int foundVec = 0;
        for (const auto& qp : queryPoints) {
            auto res = vectorQueryRadius(vec, qp.first, qp.second, 80.0);
            foundVec += static_cast<int>(res.size());
        }
        double vecUs = t2.elapsedUs() / queries;

        // Проверка корректности
        if (foundQT != foundVec) {
            std::cerr << "ОШИБКА: Quadtree нашёл " << foundQT
                      << ", Vector нашёл " << foundVec << "\n";
        }

        double speedup = (vecUs > 0) ? vecUs / qtUs : 0.0;

        std::cout << std::fixed << std::setprecision(2)
                  << std::setw(10) << n
                  << std::setw(22) << qtUs
                  << std::setw(22) << vecUs
                  << std::setw(19) << speedup << "x"
                  << "\n";
    }
}

// ---------------------------------------------------------------------------
// ТЕСТЫ КОРРЕКТНОСТИ (как в Haskell)
// ---------------------------------------------------------------------------

void runCorrectnessTests() {
    std::cout << "─── Тесты корректности C++ Quadtree ───\n\n";
    int passed = 0, total = 0;

    auto check = [&](const std::string& name, bool cond) {
        total++;
        if (cond) {
            passed++;
            std::cout << "  ✓ " << name << "\n";
        } else {
            std::cout << "  ✗ " << name << "  <--- ПРОВАЛЕН\n";
        }
    };

    Region mapR(400.0, 400.0, 400.0);

    // Пустое дерево
    {
        QuadTree<Entity> t(mapR);
        check("size = 0", t.size() == 0);
        check("toList = []", t.toList().empty());
        check("queryRadius → []",
              t.queryRadius(400, 400, 200).empty());
    }

    // Вставка одной точки
    {
        QuadTree<Entity> t(mapR);
        Point<Entity> p1(100, 200, Entity("agent", AgentType::Worker, 100, "w1"));
        t.insert(p1);
        check("size = 1", t.size() == 1);
        check("toList содержит p1", t.toList().size() == 1);
        check("queryRadius находит p1",
              t.queryRadius(100, 200, 10).size() == 1);
        check("queryRadius далеко → []",
              t.queryRadius(700, 700, 10).empty());
    }

    // Вставка нескольких + разбиение
    {
        QuadTree<Entity> t(mapR);
        for (int i = 0; i < 10; ++i) {
            t.insert(Point<Entity>(i * 10.0, i * 10.0,
                     Entity("agent", AgentType::Worker, 100,
                            "a" + std::to_string(i))));
        }
        check("size = 10", t.size() == 10);
        check("toList.size = 10", t.toList().size() == 10);
    }

    // Поиск в радиусе
    {
        QuadTree<Entity> t(mapR);
        Point<Entity> p1(100, 200, Entity("agent", AgentType::Worker, 100, "w1"));
        Point<Entity> p2(150, 250, Entity("agent", AgentType::Worker, 100, "w3"));
        Point<Entity> p3(700, 700, Entity("agent", AgentType::Scout, 90, "s3"));
        t.insert(p1); t.insert(p2); t.insert(p3);

        check("радиус 80: 2 точки",
              t.queryRadius(100, 200, 80).size() == 2);
        check("радиус 1 от (700,700): 1 точка",
              t.queryRadius(700, 700, 1).size() == 1);
    }

    // Удаление
    {
        QuadTree<Entity> t(mapR);
        Point<Entity> p1(100, 200, Entity("agent", AgentType::Worker, 100, "w1"));
        Point<Entity> p2(300, 400, Entity("agent", AgentType::Scout, 100, "s1"));
        Point<Entity> p3(500, 600, Entity("agent", AgentType::Worker, 100, "w2"));
        t.insert(p1); t.insert(p2); t.insert(p3);
        t.remove(p1);
        check("после удаления: size = 2", t.size() == 2);
        t.remove(p2); t.remove(p3);
        check("после удаления всех: size = 0", t.size() == 0);
    }

    std::cout << "\n  ✅ " << passed << " из " << total << " тестов пройдены\n\n";
}

// ---------------------------------------------------------------------------
// MAIN
// ---------------------------------------------------------------------------

int main() {
    std::cout << "╔══════════════════════════════════════════════════════════╗\n";
    std::cout << "║   БЕНЧМАРК: Quadtree vs Vector (C++)                    ║\n";
    std::cout << "║   Вариант 6 — Практическая работа 9, пункты 2,3        ║\n";
    std::cout << "╚══════════════════════════════════════════════════════════╝\n";

    // 0. Тесты корректности
    runCorrectnessTests();

    // 1. Вставка
    std::vector<int> sizes = {10, 100, 1000, 10000};
    benchQuadtreeInsert(sizes);
    benchVectorInsert(sizes);

    // 2. Поиск в радиусе — ключевое сравнение
    benchRadiusQuery(sizes);

    // 3. Вывод
    std::cout << "\n═══════════════════════════════════════════════════════════\n";
    std::cout << "  ВЫВОДЫ:\n";
    std::cout << "  • Вставка в Quadtree: O(log n) — логарифмический рост\n";
    std::cout << "  • Вставка в Vector: O(1) амортизированное — быстрее вставки\n";
    std::cout << "  • Поиск в радиусе (Quadtree): O(log n) — значительно быстрее\n";
    std::cout << "  • Поиск в радиусе (Vector): O(n) — линейный рост\n";
    std::cout << "  • Для муравьиной симуляции Quadtree выгоден при большом\n";
    std::cout << "    числе агентов, т.к. поиск соседей — основная операция\n";
    std::cout << "═══════════════════════════════════════════════════════════\n";

    return 0;
}
