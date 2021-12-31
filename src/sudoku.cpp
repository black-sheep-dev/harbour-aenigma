#include "sudoku.h"

#include <QDebug>
#include <QThreadPool>

#include "generator.h"
#include "helper.h"

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

bool Sudoku::setData(quint8 row, quint8 column, quint8 role, const QVariant &data, bool undo, quint16 undoId)
{
    if (row > rowSize || column > rowSize) {
        return false;
    }

    const quint8 index = Helper::index(row, column);

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

        if (m_autoCleanupNotes) {
            cleanupNotes(data.toUInt());
        }
        break;

    default:
        return false;
    }

    if (oldData == data) {
        return true;
    }

    if (!undo) {
        UndoStep step;

        if (undoId != 0) {
            step.id = undoId;
        } else {
            incrementUndoId();
            step.id = m_currentUndoId;
        }

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

bool Sudoku::isInArea(quint8 row, quint8 column, quint8 number) const
{
    return isInBox(row, column, number) || isInRow(row, number) || isInColumn(column, number);
}

bool Sudoku::isInBox(quint8 row, quint8 column, quint8 number) const
{
    const quint8 R = row - row % 3;
    const quint8 C = column - column % 3;

    for (quint8 i = 0; i < 3; ++i) {
        for (quint8 j = 0; j < 3; ++j) {
            if (number == m_game[Helper::index(R + i, C + j)]) return true;
        }
    }

    return false;
}

bool Sudoku::isInColumn(quint8 column, quint8 number) const
{
    for (quint8 i = 0; i < boxSize; ++i) {
        if (number == m_game[Helper::index(i, column)]) {
            return true;
        }
    }

    return false;
}

bool Sudoku::isInRow(quint8 row, quint8 number) const
{
    for (quint8 i = 0; i < boxSize; ++i) {
        if (number == m_game[Helper::index(row, i)]) {
            return true;
        }
    }

    return false;
}

quint8 Sudoku::noteToNumber(Note::Number note) const
{
    return Helper::noteToNumber(note);
}

quint16 Sudoku::numberToNote(quint8 number) const
{
    return Helper::numberToNote(number);
}

bool Sudoku::autoCleanupNotes() const
{
    return m_autoCleanupNotes;
}

void Sudoku::setAutoCleanupNotes(bool cleanup)
{
    if (m_autoCleanupNotes == cleanup)
        return;
    m_autoCleanupNotes = cleanup;
    emit autoCleanupNotesChanged();
}


bool Sudoku::autoNotes() const
{
    return m_autoNotes;
}

void Sudoku::setAutoNotes(bool enabled)
{
    if (m_autoNotes == enabled)
        return;
    m_autoNotes = enabled;
    emit autoNotesChanged();
}

quint16 Sudoku::currentUndoId() const
{
    return m_currentUndoId;
}

void Sudoku::setCurrentUndoId(quint16 id)
{
    if (m_currentUndoId == id)
        return;
    m_currentUndoId = id;
    emit currentUndoIdChanged();
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

const QTime &Sudoku::elapsedTime() const
{
    return m_elapsedTime;
}

void Sudoku::setElapsedTime(const QTime &msec)
{
    if (m_elapsedTime == msec)
        return;
    m_elapsedTime = msec;
    emit elapsedTimeChanged();
}

quint16 Sudoku::hintsCount() const
{
    return m_hintsCount;
}

void Sudoku::setHintsCount(quint16 count)
{
    if (m_hintsCount == count)
        return;
    m_hintsCount = count;
    emit hintsCountChanged();
}

const QDateTime &Sudoku::startTime() const
{
    return m_startTime;
}

void Sudoku::setStartTime(const QDateTime &time)
{
    if (m_startTime == time)
        return;
    m_startTime = time;
    emit startTimeChanged();
}


GameState::State Sudoku::state() const
{
    return m_state;
}

quint16 Sudoku::stepsCount() const
{
    return m_stepsCount;
}

void Sudoku::setStepsCount(quint16 count)
{
    if (m_stepsCount == count)
        return;
    m_stepsCount = count;
    emit stepsCountChanged();
}


quint8 Sudoku::unsolvedCellCount() const
{
    return m_unsolvedCellCount;
}

void Sudoku::incrementHintsCount()
{
    setHintsCount(m_hintsCount + 1);
}

void Sudoku::incrementStepsCount()
{
    setStepsCount(m_stepsCount + 1);
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
    m_currentUndoId = 0;

    m_notes.fill(0);
    m_game = m_puzzle;

    if (m_autoNotes) {
        m_notes = m_notesGenerated;
    }

    m_state = GameState::Ready;
    checkIfFinished();
    emit stateChanged();
}

void Sudoku::startStopWatch()
{
    m_resumeTime = QDateTime::currentDateTimeUtc();
    emit elapsedTimeChanged();
}

void Sudoku::stopStopWatch()
{
    setElapsedTime(m_elapsedTime.addMSecs(int(QDateTime::currentMSecsSinceEpoch() - m_resumeTime.toMSecsSinceEpoch())));
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

    UndoStep current;

    do {
        current = m_undoQueue.takeLast();
        setData(current.row, current.column, current.role, current.oldValue, true);

        if (m_undoQueue.isEmpty()) {
            break;
        }

    } while (current.id == m_undoQueue.last().id);
}

void Sudoku::onGeneratorFinished(const QVector<quint8>& puzzle, const QVector<quint8> &solution, const QVector<quint16> &notes)
{
    m_puzzle = puzzle;
    m_game = puzzle;
    m_solution = solution;

    if (m_autoNotes) {
        m_notes = notes;
        m_notesGenerated = notes;
    }

    // set start datetime and start stopwatch
    setStartTime(QDateTime::currentDateTimeUtc());
    startStopWatch();

    // emit state change
    m_state = GameState::Ready;
    emit stateChanged();

    checkIfFinished();
}

void Sudoku::checkIfFinished()
{
    // check if finished / no 0 left
    QVector<quint8> numbers(boxSize, 0);
    m_unsolvedCellCount = 0;
    for (const auto &number : m_game) {
        if (number == 0) {
            m_unsolvedCellCount++;
            continue;
        }
        numbers[number - 1]++;
    }

    emit unsolvedCellCountChanged();

    // emit if single number is complete
    for (int i = 0; i < boxSize; ++i) {
        emit numberFinished(i + 1, numbers[i] == boxSize);
    }

    //
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
    stopStopWatch();
    m_state = GameState::Solved;
    emit stateChanged();
}

void Sudoku::cleanupNotes(quint8 number)
{
    const quint16 id = m_currentUndoId++;

    for (int i = 0; i < gridSize; ++i) {
        const quint8 r = floor(i / rowSize);
        const quint8 c = i - r * rowSize;

        if (!isInArea(r, c, number)) continue;
        setData(r, c, CellData::Notes, m_notes[i] & ~Helper::numberToNote(number), false, id);
    }
}

void Sudoku::incrementUndoId()
{
    m_currentUndoId++;
    emit currentUndoIdChanged();
}
