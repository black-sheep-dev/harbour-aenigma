#ifndef ENUMS_H
#define ENUMS_H

#include <QObject>

class EditMode
{
    Q_GADGET
public:
    enum Mode {
        None,
        Add,
        Note,
        Delete,
        Hint
    };
    Q_ENUM(Mode)
};

class HighlightMode
{
    Q_GADGET
public:
    enum Mode {
        None,
        Cell,
        Complete
    };
    Q_ENUM(Mode)
};

class Styles
{
    Q_GADGET
public:
    enum Style {
        Default,
        BlackAndWhite,
        Paper,
        DarkShadow,
        Custom
    };
    Q_ENUM(Style)
};

#endif // ENUMS_H
