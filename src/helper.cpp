#include "helper.h"

quint8 Helper::noteToNumber(Note::Number note)
{
    switch (note) {
    case Note::One:
        return 1;
    case Note::Two:
        return 2;
    case Note::Three:
        return 3;
    case Note::Four:
        return 4;
    case Note::Five:
        return 5;
    case Note::Six:
        return 6;
    case Note::Seven:
        return 7;
    case Note::Eight:
        return 8;
    case Note::Nine:
        return 9;
    default:
        return 0;
    }
}

quint16 Helper::numberToNote(quint8 number)
{
    switch (number) {
    case 1:
        return Note::One;
    case 2:
        return Note::Two;
    case 3:
        return Note::Three;
    case 4:
        return Note::Four;
    case 5:
        return Note::Five;
    case 6:
        return Note::Six;
    case 7:
        return Note::Seven;
    case 8:
        return Note::Eight;
    case 9:
        return Note::Nine;
    default:
        return Note::None;
    }
}
