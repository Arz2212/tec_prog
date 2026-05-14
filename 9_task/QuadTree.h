///
/// \file QuadTree.h
/// \brief Двумерное дерево квадрантов (Quadtree) — C++ реализация.
///
/// Переведено с Haskell-прототипа из работы 8.
/// Хранит точки в ограниченной 2D-области, поддерживает вставку,
/// удаление, поиск в радиусе и в прямоугольной области.
///
/// Применение: замена std::vector<unique_ptr<Agent>> в муравьиной симуляции
/// для ускорения поиска соседей в радиусе взаимодействия.
///
/// \author Студент
/// \version 1.0
/// \date 2026
///

#ifndef QUADTREE_H
#define QUADTREE_H

#include <vector>
#include <memory>
#include <cmath>
#include <algorithm>
#include <string>
#include <sstream>

// ---------------------------------------------------------------------------
// ТИПЫ ДАННЫХ
// ---------------------------------------------------------------------------

/// Ёмкость листа: сколько точек может храниться в листе до разбиения.
constexpr int QT_CAPACITY = 4;

/// 2D-точка с пользовательскими данными.
template <typename T>
struct Point {
    double x, y;
    T data;

    Point(double x_, double y_, const T& data_) : x(x_), y(y_), data(data_) {}

    bool operator==(const Point& other) const {
        return x == other.x && y == other.y && data == other.data;
    }
};

/// Прямоугольная область (центр + полуразмер).
struct Region {
    double cx, cy, half;

    Region(double cx_, double cy_, double half_)
        : cx(cx_), cy(cy_), half(half_) {}

    /// Принадлежит ли точка (x, y) региону?
    bool contains(double px, double py) const {
        return px >= cx - half && px < cx + half &&
               py >= cy - half && py < cy + half;
    }

    /// Пересекается ли регион с кругом?
    bool intersectsCircle(double qx, double qy, double r) const {
        double closestX = std::max(cx - half, std::min(qx, cx + half));
        double closestY = std::max(cy - half, std::min(qy, cy + half));
        double dx = qx - closestX;
        double dy = qy - closestY;
        return dx * dx + dy * dy <= r * r;
    }

    /// Пересекаются ли два региона?
    bool overlaps(const Region& other) const {
        return std::abs(cx - other.cx) <= half + other.half &&
               std::abs(cy - other.cy) <= half + other.half;
    }

    /// Разбить регион на 4 подрегиона.
    void split(Region& nw, Region& ne, Region& sw, Region& se) const {
        double h2 = half / 2.0;
        nw = Region(cx - h2, cy - h2, h2);
        ne = Region(cx + h2, cy - h2, h2);
        sw = Region(cx - h2, cy + h2, h2);
        se = Region(cx + h2, cy + h2, h2);
    }

    /// Определить квадрант точки: 0=NW, 1=NE, 2=SW, 3=SE.
    int quadrant(double px, double py) const {
        if (px < cx && py < cy)  return 0;
        if (px >= cx && py < cy) return 1;
        if (px < cx && py >= cy) return 2;
        return 3;
    }

    std::string toString() const {
        std::ostringstream oss;
        oss << "Region(cx=" << cx << ", cy=" << cy << ", half=" << half << ")";
        return oss.str();
    }
};

// ---------------------------------------------------------------------------
// ДЕРЕВО КВАДРАНТОВ
// ---------------------------------------------------------------------------

template <typename T>
class QuadTree {
public:
    enum Type { EMPTY, LEAF, NODE };

private:
    Type type_;
    Region region_;
    std::vector<Point<T>> points_;                           // для LEAF
    std::unique_ptr<QuadTree> nw_, ne_, sw_, se_;            // для NODE

    /// Создать пустой узел с 4 дочерними (для разбиения).
    void initChildren() {
        double h2 = region_.half / 2.0;
        nw_ = std::make_unique<QuadTree>(Region(region_.cx - h2, region_.cy - h2, h2));
        ne_ = std::make_unique<QuadTree>(Region(region_.cx + h2, region_.cy - h2, h2));
        sw_ = std::make_unique<QuadTree>(Region(region_.cx - h2, region_.cy + h2, h2));
        se_ = std::make_unique<QuadTree>(Region(region_.cx + h2, region_.cy + h2, h2));
    }

    /// Переместить все точки листа в дочерние узлы.
    void redistributeToChildren() {
        std::vector<Point<T>> pts = std::move(points_);
        points_.clear();
        type_ = NODE;
        initChildren();
        for (const auto& pt : pts) {
            insertIntoChildren(pt);
        }
    }

    /// Вставить точку в соответствующий дочерний узел.
    void insertIntoChildren(const Point<T>& pt) {
        switch (region_.quadrant(pt.x, pt.y)) {
            case 0: nw_->insert(pt); break;
            case 1: ne_->insert(pt); break;
            case 2: sw_->insert(pt); break;
            case 3: se_->insert(pt); break;
        }
    }

    /// Собрать точки из всех листьев (для склеивания).
    std::vector<Point<T>> collectLeaves() const {
        std::vector<Point<T>> result;
        collectLeavesRec(result);
        return result;
    }

    void collectLeavesRec(std::vector<Point<T>>& out) const {
        if (type_ == LEAF) {
            out.insert(out.end(), points_.begin(), points_.end());
        } else if (type_ == NODE) {
            nw_->collectLeavesRec(out);
            ne_->collectLeavesRec(out);
            sw_->collectLeavesRec(out);
            se_->collectLeavesRec(out);
        }
    }

    /// Попытаться склеить узел обратно в лист/empty.
    void collapse() {
        if (type_ != NODE) return;

        auto allPts = collectLeaves();
        if (allPts.empty()) {
            type_ = EMPTY;
            nw_.reset(); ne_.reset(); sw_.reset(); se_.reset();
        } else if (allPts.size() <= QT_CAPACITY) {
            type_ = LEAF;
            points_ = std::move(allPts);
            nw_.reset(); ne_.reset(); sw_.reset(); se_.reset();
        }
    }

public:
    /// Создать пустое дерево, покрывающее заданный регион.
    explicit QuadTree(const Region& r)
        : type_(EMPTY), region_(r) {}

    /// Вставить точку.
    void insert(const Point<T>& pt) {
        if (!region_.contains(pt.x, pt.y)) return;

        switch (type_) {
        case EMPTY:
            type_ = LEAF;
            points_.push_back(pt);
            break;

        case LEAF:
            points_.push_back(pt);
            if (points_.size() > QT_CAPACITY) {
                redistributeToChildren();
            }
            break;

        case NODE:
            insertIntoChildren(pt);
            break;
        }
    }

    /// Удалить точку (по полному совпадению).
    void remove(const Point<T>& pt) {
        if (!region_.contains(pt.x, pt.y)) return;

        switch (type_) {
        case EMPTY:
            break;

        case LEAF: {
            auto it = std::find(points_.begin(), points_.end(), pt);
            if (it != points_.end()) {
                points_.erase(it);
                if (points_.empty()) {
                    type_ = EMPTY;
                }
            }
            break;
        }

        case NODE:
            switch (region_.quadrant(pt.x, pt.y)) {
                case 0: nw_->remove(pt); break;
                case 1: ne_->remove(pt); break;
                case 2: sw_->remove(pt); break;
                case 3: se_->remove(pt); break;
            }
            collapse();
            break;
        }
    }

    /// Поиск всех точек в круговом радиусе.
    std::vector<Point<T>> queryRadius(double qx, double qy, double r) const {
        std::vector<Point<T>> result;
        queryRadiusRec(qx, qy, r, result);
        return result;
    }

    void queryRadiusRec(double qx, double qy, double r,
                        std::vector<Point<T>>& out) const {
        if (!region_.intersectsCircle(qx, qy, r)) return;

        switch (type_) {
        case EMPTY:
            break;

        case LEAF:
            for (const auto& pt : points_) {
                double dx = pt.x - qx;
                double dy = pt.y - qy;
                if (std::sqrt(dx * dx + dy * dy) <= r) {
                    out.push_back(pt);
                }
            }
            break;

        case NODE:
            nw_->queryRadiusRec(qx, qy, r, out);
            ne_->queryRadiusRec(qx, qy, r, out);
            sw_->queryRadiusRec(qx, qy, r, out);
            se_->queryRadiusRec(qx, qy, r, out);
            break;
        }
    }

    /// Поиск всех точек в прямоугольной области.
    std::vector<Point<T>> queryRegion(const Region& qr) const {
        std::vector<Point<T>> result;
        queryRegionRec(qr, result);
        return result;
    }

    void queryRegionRec(const Region& qr, std::vector<Point<T>>& out) const {
        if (!region_.overlaps(qr)) return;

        switch (type_) {
        case EMPTY:
            break;

        case LEAF:
            for (const auto& pt : points_) {
                if (qr.contains(pt.x, pt.y)) {
                    out.push_back(pt);
                }
            }
            break;

        case NODE:
            nw_->queryRegionRec(qr, out);
            ne_->queryRegionRec(qr, out);
            sw_->queryRegionRec(qr, out);
            se_->queryRegionRec(qr, out);
            break;
        }
    }

    /// Количество точек.
    int size() const {
        switch (type_) {
        case EMPTY: return 0;
        case LEAF:  return static_cast<int>(points_.size());
        case NODE:  return nw_->size() + ne_->size() + sw_->size() + se_->size();
        }
        return 0;
    }

    /// Все точки в виде списка.
    std::vector<Point<T>> toList() const {
        std::vector<Point<T>> result;
        toListRec(result);
        return result;
    }

    void toListRec(std::vector<Point<T>>& out) const {
        switch (type_) {
        case EMPTY: break;
        case LEAF:
            out.insert(out.end(), points_.begin(), points_.end());
            break;
        case NODE:
            nw_->toListRec(out);
            ne_->toListRec(out);
            sw_->toListRec(out);
            se_->toListRec(out);
            break;
        }
    }

    /// Получить регион.
    const Region& getRegion() const { return region_; }

    /// Получить тип узла.
    Type getType() const { return type_; }

    /// Строковое представление (для отладки).
    std::string toString(int indent = 0) const {
        std::string pad(indent * 2, ' ');
        std::ostringstream oss;

        switch (type_) {
        case EMPTY:
            oss << pad << "[Empty] " << region_.toString();
            break;
        case LEAF:
            oss << pad << "[Leaf] " << region_.toString()
                << " points=" << points_.size() << "\n";
            for (const auto& pt : points_) {
                oss << pad << "  • (" << pt.x << ", " << pt.y
                    << " | " << pt.data << ")\n";
            }
            break;
        case NODE:
            oss << pad << "[Node] " << region_.toString()
                << " total=" << size() << "\n";
            oss << pad << "  NW:\n" << nw_->toString(indent + 2);
            oss << pad << "  NE:\n" << ne_->toString(indent + 2);
            oss << pad << "  SW:\n" << sw_->toString(indent + 2);
            oss << pad << "  SE:\n" << se_->toString(indent + 2);
            break;
        }
        return oss.str();
    }
};

#endif // QUADTREE_H
