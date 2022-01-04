#ifndef UNDOSTEP_H
#define UNDOSTEP_H

#include <QDataStream>
#include <QVariant>

struct UndoStep {
    quint8 column{0};
    quint16 id{0};
    QVariant newValue;
    QVariant oldValue;
    quint8 role{0};
    quint8 row{0};

    friend QDataStream &operator<<(QDataStream &out, const UndoStep &step) {

        out << step.column;
        out << step.id;
        out << step.newValue;
        out << step.oldValue;
        out << step.role;
        out << step.row;

        return out;
    }

    friend QDataStream &operator>>(QDataStream &in, UndoStep &step) {

        in >> step.column;
        in >> step.id;
        in >> step.newValue;
        in >> step.oldValue;
        in >> step.role;
        in >> step.row;

        return in;
    }
};

#endif // UNDOSTEP_H
