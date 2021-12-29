#include "sudoku.h"

#include <QDebug>
#include <QThreadPool>

#include "generator.h"

Sudoku::Sudoku(QObject *parent) : QObject(parent)
{

}

QVariant Sudoku::data(quint8 row, quint8 column, quint8 role) const
{
    if (row > rowSize || column > rowSize) {
        return QVariant();
    }

    const quint8 index = row * rowSize + column;

    switch (role) {
    case CellData::HasError:
        if (m_game[index] == 0) {
            return false;
        }
        return m_game[index] != m_solution[index];

    case CellData::IsEditable:
        return m_puzzle[index] == 0;

    case CellData::Notes:
        return m_notes[index];

    case CellData::Solution:
        return m_solution[index];

    case CellData::Value:
        return m_game[index];

    default:
        return QVariant();
    }
}

bool Sudoku::setData(quint8 row, quint8 column, quint8 role, const QVariant &data, bool undo)
{
    if (row > rowSize || column > rowSize) {
        return false;
    }

    const quint8 index = this->index(row, column);

    QVariant oldData;

    switch (role) {
    case CellData::Notes:
        oldData = m_notes[index];
        m_notes.replace(index, data.toUInt());
        break;

    case CellData::Value:
        if (m_puzzle[index] != 0) {
            return false;
        }
        oldData = m_game[index];
        m_game.replace(index, data.toUInt());
        checkIfFinished();
        break;

    default:
        return false;
    }

    if (oldData == data) {
        return true;
    }

    if (!undo) {
        UndoStep step;
        step.row = row;
        step.column = column;
        step.role = role;
        step.newValue = data;
        step.oldValue = oldData;
        m_undoQueue.append(step);
    }

    emit dataChanged(row, column, role, data);

    return true;
}

quint8 Sudoku::cellCount() const
{
    return m_game.count();
}

bool Sudoku::isInBox(quint8 row, quint8 column, quint8 number) const
{
    const quint8 R = row - row % 3;
    const quint8 C = column - column % 3;

    for (quint8 i = 0; i < 3; ++i) {
        for (quint8 j = 0; j < 3; ++j) {
            if (number == m_game[index(R + i, C + j)]) return true;
        }
    }

    return false;
}

bool Sudoku::isInColumn(quint8 column, quint8 number) const
{
    for (quint8 i = 0; i < boxSize; ++i) {
        if (number == m_game[index(i, column)]) {
            return true;
        }
    }

    return false;
}

bool Sudoku::isInRow(quint8 row, quint8 number) const
{
    for (quint8 i = 0; i < boxSize; ++i) {
        if (number == m_game[index(row, i)]) {
            return true;
        }
    }

    return false;
}

quint16 Sudoku::numberToNote(quint8 number) const
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

quint8 Sudoku::noteToNumber(Note::Number number) const
{
    switch (number) {
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

Difficulty::Level Sudoku::difficulty() const
{
    return m_difficulty;
}

void Sudoku::setDifficulty(Difficulty::Level difficulty)
{
    if (m_difficulty == difficulty)
        return;
    m_difficulty = difficulty;
    emit difficultyChanged();
}

GameState::State Sudoku::state() const
{
    return m_state;
}

quint8 Sudoku::unsolvedCellCount() const
{
    return m_unsolvedCellCount;
}

void Sudoku::generate()
{
    m_state = GameState::Generating;
    emit stateChanged();

    auto generator = new Generator(m_difficulty);
    generator->setAutoDelete(true);
    connect(generator, &Generator::finished, this, &Sudoku::onGeneratorFinished);

    QThreadPool::globalInstance()->start(generator);
}

void Sudoku::reset()
{
    m_undoQueue.clear();
    m_game = m_puzzle;
    m_state = GameState::Ready;
    emit stateChanged();
}

void Sudoku::toogleNote(quint8 row, quint8 column, quint16 note)
{
    if (row > rowSize || column > rowSize) {
        return;
    }

    const quint8 index = row * rowSize + column;
    quint16 notes = m_notes[index];
    notes ^= note;

    emit setData(row, column, CellData::Notes, notes);
}

void Sudoku::undo()
{
    if (m_undoQueue.isEmpty()) {
        return;
    }

    auto step = m_undoQueue.takeLast();
    setData(step.row, step.column, step.role, step.oldValue, true);
}

void Sudoku::onGeneratorFinished(const QVector<quint8>& puzzle, const QVector<quint8> &solution)
{
    m_puzzle = puzzle;
    m_game = puzzle;
    m_solution = solution;

    // emit state change
    m_state = GameState::Ready;
    emit stateChanged();

    checkIfFinished();
}

void Sudoku::checkIfFinished()
{
    // check if finished / no 0 left
    m_unsolvedCellCount = 0;
    for (const auto &number : m_game) {
        if (number == 0) {
            m_unsolvedCellCount++;
        }
    }

    emit unsolvedCellCountChanged();
    if (m_unsolvedCellCount > 0) {
        if (m_state != GameState::Playing) {
            m_state = GameState::Playing;
            emit stateChanged();
        }
        return;
    }

    // check for errors
    for (quint8 i = 0; i < gridSize; ++i) {
        if (m_game[i] != m_solution[i]) {
            m_state = GameState::NotCorrect;
            emit stateChanged();
            return;
        }
    }

    // end puzzle
    m_state = GameState::Solved;
    emit stateChanged();
}

