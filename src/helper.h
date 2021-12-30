#ifndef HELPER_H
#define HELPER_H

#include "enums.h"

class Helper
{
public:
    Helper() = default;

    static quint8 noteToNumber(Note::Number note);
    static quint16 numberToNote(quint8 number);
};

#endif // HELPER_H
