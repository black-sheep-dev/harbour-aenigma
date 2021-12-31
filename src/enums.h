#ifndef ENUMS_H
#define ENUMS_H

#include <QObject>

class CellData
{
    Q_GADGET
public:
    enum Role {
        HasError,
        IsEditable,
        Notes,
        Solution,
        Value
    };
    Q_ENUM(Role)
};

class Difficulty
{
    Q_GADGET
public:
    enum Level {
        Easy,
        Medium,
        Hard,
        Insane
    };
    Q_ENUM(Level)
};

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

class GameState
{
    Q_GADGET
public:
    enum State {
        Empty,
        Generating,
        Ready,
        Playing,
        Solved,
        NotCorrect
    };
    Q_ENUM(State)
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

class Note
{
    Q_GADGET
public:
    enum Number {
        None    = 0x0000,
        One     = 0x0001,
        Two     = 0x0002,
        Three   = 0x0004,
        Four    = 0x0008,
        Five    = 0x0010,
        Six     = 0x0020,
        Seven   = 0x0040,
        Eight   = 0x0080,
        Nine    = 0x0100
    };
    Q_ENUM(Number);
    Q_DECLARE_FLAGS(Numbers, Number)
};
Q_DECLARE_OPERATORS_FOR_FLAGS(Note::Numbers)

class Styles
{
    Q_GADGET
public:
    enum Style {
        Default,
        BlackAndWhite,
        Paper
    };
    Q_ENUM(Style)
};

#endif // ENUMS_H
