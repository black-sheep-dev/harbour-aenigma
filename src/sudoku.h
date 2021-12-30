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

    Q_PROPERTY(bool autoCleanupNotes READ autoCleanupNotes WRITE setAutoCleanupNotes NOTIFY autoCleanupNotesChanged)
    Q_PROPERTY(bool autoNotes READ autoNotes WRITE setAutoNotes NOTIFY autoNotesChanged)
    Q_PROPERTY(Difficulty::Level difficulty READ difficulty WRITE setDifficulty NOTIFY difficultyChanged)
    Q_PROPERTY(GameState::State state READ state NOTIFY stateChanged)
    Q_PROPERTY(quint8 unsolvedCellCount READ unsolvedCellCount NOTIFY unsolvedCellCountChanged)

public:    
    explicit Sudoku(QObject *parent = nullptr);

    Q_INVOKABLE QVariant data(quint8 row, quint8 column, quint8 role) const;
    Q_INVOKABLE bool setData(quint8 row, quint8 column, quint8 role, const QVariant &data, bool undo = false);

    Q_INVOKABLE quint8 cellCount() const;
    Q_INVOKABLE bool isInArea(quint8 row, quint8 column, quint8 number) const;
    Q_INVOKABLE bool isInBox(quint8 row, quint8 column, quint8 number) const;
    Q_INVOKABLE bool isInColumn(quint8 column, quint8 number) const;
    Q_INVOKABLE bool isInRow(quint8 row, quint8 number) const;
    Q_INVOKABLE quint8 noteToNumber(Note::Number note) const;
    Q_INVOKABLE quint16 numberToNote(quint8 number) const;

    // properties
    bool autoCleanupNotes() const;
    void setAutoCleanupNotes(bool cleanup);

    bool autoNotes() const;
    void setAutoNotes(bool enabled);

    Difficulty::Level difficulty() const;
    void setDifficulty(Difficulty::Level difficulty);

    GameState::State state() const;

    quint8 unsolvedCellCount() const;



signals:
    void dataChanged(quint8 row, quint8 column, quint8 role, const QVariant &data);
    void numberFinished(quint8 number, bool finished = true);

    // properties
    void autoNotesChanged();
    void difficultyChanged();
    void stateChanged();
    void unsolvedCellCountChanged(); 

    void autoCleanupNotesChanged();

public slots:
    void generate();
    void reset();
    void toogleNote(quint8 row, quint8 column, quint16 note);
    void undo();

private slots:
    void onGeneratorFinished(const QVector<quint8>& puzzle, const QVector<quint8> &solution, const QVector<quint16> &notes);

private:
    void checkIfFinished();
    void cleanupNotes(quint8 number);

    QVector<quint8> m_game{QVector<quint8>(gridSize, 0)};
    QVector<quint16> m_notes{QVector<quint16>(gridSize, 0)};
    QVector<quint8> m_puzzle{QVector<quint8>(gridSize, 0)};
    QVector<quint8> m_solution{QVector<quint8>(gridSize, 0)};
    QList<UndoStep> m_undoQueue;

    // properties
    bool m_autoNotes{false};
    Difficulty::Level m_difficulty{Difficulty::Easy};
    GameState::State m_state{GameState::Empty};
    quint8 m_unsolvedCellCount{0};
    bool m_autoCleanupNotes{false};
};

#endif // SUDOKU_H
