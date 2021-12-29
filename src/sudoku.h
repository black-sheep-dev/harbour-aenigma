#ifndef SUDOKU_H
#define SUDOKU_H

#include <QObject>

#include <QList>
#include <QVariant>
#include <QVector>

#include "enums.h"
#include "global.h"

struct UndoStep {
    quint8 column{0};
    QVariant newValue;
    QVariant oldValue;
    quint8 role{0};
    quint8 row{0};
};

class Sudoku : public QObject
{
    Q_OBJECT

    Q_PROPERTY(Difficulty::Level difficulty READ difficulty WRITE setDifficulty NOTIFY difficultyChanged)
    Q_PROPERTY(GameState::State state READ state NOTIFY stateChanged)
    Q_PROPERTY(quint8 unsolvedCellCount READ unsolvedCellCount NOTIFY unsolvedCellCountChanged)

public:    
    explicit Sudoku(QObject *parent = nullptr);

    Q_INVOKABLE QVariant data(quint8 row, quint8 column, quint8 role) const;
    Q_INVOKABLE bool setData(quint8 row, quint8 column, quint8 role, const QVariant &data, bool undo = false);

    Q_INVOKABLE quint8 cellCount() const;
    Q_INVOKABLE bool isInBox(quint8 row, quint8 column, quint8 number) const;
    Q_INVOKABLE bool isInColumn(quint8 column, quint8 number) const;
    Q_INVOKABLE bool isInRow(quint8 row, quint8 number) const;
    Q_INVOKABLE quint8 noteToNumber(Note::Number number) const;
    Q_INVOKABLE quint16 numberToNote(quint8 number) const;

    // properties
    Difficulty::Level difficulty() const;
    void setDifficulty(Difficulty::Level difficulty);

    GameState::State state() const;

    quint8 unsolvedCellCount() const;

signals:
    void dataChanged(quint8 row, quint8 column, quint8 role, const QVariant &data);

    // properties
    void difficultyChanged();
    void stateChanged();
    void unsolvedCellCountChanged();

public slots:
    void generate();
    void reset();
    void toogleNote(quint8 row, quint8 column, quint16 note);
    void undo();

private slots:
    void onGeneratorFinished(const QVector<quint8>& puzzle, const QVector<quint8> &solution);

private:
    void checkIfFinished();
    quint8 index(quint8 i, quint8 j) const { return i * 9 + j; }

    QVector<quint8> m_game{QVector<quint8>(gridSize, 0)};
    QVector<quint16> m_notes{QVector<quint16>(gridSize, 0)};
    QVector<quint8> m_puzzle{QVector<quint8>(gridSize, 0)};
    QVector<quint8> m_solution{QVector<quint8>(gridSize, 0)};
    QList<UndoStep> m_undoQueue;

    // properties
    Difficulty::Level m_difficulty{Difficulty::Easy};
    GameState::State m_state{GameState::Empty};
    quint8 m_unsolvedCellCount{0};
};

#endif // SUDOKU_H
