#ifndef GENERATOR_H
#define GENERATOR_H

#include <QRunnable>
#include <QObject>

#include <QVector>

#include "enums.h"
#include "global.h"

class Generator : public QObject, public QRunnable
{
    Q_OBJECT

public:
    explicit Generator(Difficulty::Level difficulty = Difficulty::Easy, QObject *parent = nullptr);

signals:
    void finished(QVector<quint8> puzzle, QVector<quint8> solution, QVector<quint16> notes);

private:
    // helper functions
    static quint8 dice();
    void fillBox(quint8 row, quint8 col, QVector<quint8> &board, quint8 (*dice)());
    qint8 findEmptyCell(QVector<quint8> &board);
    QVector<quint8> getShuffledNumbers();
    bool isValid(quint8 num, quint8 row, quint8 col, const QVector<quint8> &board);
    bool isValidBox(quint8 num, quint8 row, quint8 col, const QVector<quint8> &board);
    bool isValidCol(quint8 num, quint8 col, const QVector<quint8> &board);
    bool isValidRow(quint8 num, quint8 row, const QVector<quint8> &board);
    quint8 numberOfSolutions(QVector<quint8> &board, quint8 pos = 0, quint8 count = 0);
    void removeElements(QVector<quint8> &board, quint8 n);
    void shuffleVector(QVector<quint8> &vector);
    void swapNumber(quint8 i, quint8 j, QVector<quint8> &vector);

    // main functions
    void generateBoard(QVector<quint8> &board);
    void generateNotes(QVector<quint16> &notes, const QVector<quint8> &board);
    bool solveBoard(QVector<quint8> &board);

    Difficulty::Level m_difficulty{Difficulty::Easy};
    QVector<quint8> m_difficulties{25,35,45,55};

    // QRunnable interface
public:
    void run() override;
};

#endif // GENERATOR_H
