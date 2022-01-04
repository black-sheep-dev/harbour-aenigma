#include "sudoku.h"

#include <QDebug>
#include <QtMath>
#include <QThreadPool>

#include "generator.h"
#include "helper.h"

constexpr quint64 AENIGMA_GAME_DATA_MAGIC = 0x41454e49474d41;
constexpr quint16 AENIGMA_GAME_DATA_VERSION = 1;

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

QString Sudoku::gameStateData() const
{
    QByteArray out;

    QDataStream stream(&out, QIODevice::WriteOnly);
    stream.setVersion(QDataStream::Qt_5_6);

    stream << AENIGMA_GAME_DATA_MAGIC;
    stream << AENIGMA_GAME_DATA_VERSION;

    stream << m_elapsedTime;
    stream << quint8(m_gameState);
    stream << m_hintsCount;
    stream << m_stepsCount;

    stream << m_game;
    stream << m_notes;
    stream << m_notesGenerated;
    stream << m_puzzle;
    stream << m_solution;

    stream << m_currentUndoId;
    stream << m_undoQueue;

    return out.toBase64();
}

void Sudoku::setGameStateData(const QString &data)
{
    QByteArray in = QByteArray::fromBase64(data.toUtf8());

    QDataStream stream(&in, QIODevice::ReadOnly);

    quint64 magic{0};
    stream >> magic;

    if (magic != AENIGMA_GAME_DATA_MAGIC) {
        qWarning() << "No valid game data";
        return;
    }

    // reset current game
    reset();

    // load game data
    quint16 version{0};
    stream >> version;

    stream >> m_elapsedTime;
    emit elapsedTimeChanged();

    quint8 state;
    stream >> state;
    m_gameState = GameState::State(state);

    stream >> m_hintsCount;
    stream >> m_stepsCount;

    stream >> m_game;
    stream >> m_notes;
    stream >> m_notesGenerated;
    stream >> m_puzzle;
    stream >> m_solution;

    stream >> m_currentUndoId;
    stream >> m_undoQueue;

    emit gameStateChanged();
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

GameState::State Sudoku::gameState() const
{
    return m_gameState;
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
    m_gameState = GameState::Generating;
    emit gameStateChanged();

    auto generator = new Generator(m_difficulty);
    generator->setAutoDelete(true);
    connect(generator, &Generator::finished, this, &Sudoku::onGeneratorFinished);
    connect(generator, &Generator::failed, this, &Sudoku::onGeneratorFailed);

    QThreadPool::globalInstance()->start(generator);
}

void Sudoku::pause()
{
    if (m_gameState != GameState::Playing) {
        return;
    }

    m_gameState = GameState::Pause;
    emit gameStateChanged();
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

    // reset stats
    stop();
    setStepsCount(0);
    setHintsCount(0);
    setStartTime(QDateTime::currentDateTime());
    setElapsedTime(QTime(0,0,0,0));
    m_resumeTime = 0;

    // check
    checkIfFinished();
}

void Sudoku::start()
{
    if (m_gameState == GameState::Playing) {
        return;
    }

    m_resumeTime = QDateTime::currentMSecsSinceEpoch();
    m_gameState = GameState::Playing;
    emit gameStateChanged();
}

void Sudoku::stop()
{
    if (m_gameState != GameState::Playing) {
        return;
    }

    setElapsedTime(QTime(m_elapsedTime).addMSecs(QDateTime::currentMSecsSinceEpoch() - m_resumeTime));
    emit elapsedTimeChanged();
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

    start();

    UndoStep current;

    do {
        current = m_undoQueue.takeLast();
        setData(current.row, current.column, current.role, current.oldValue, true);

        if (m_undoQueue.isEmpty()) {
            break;
        }

    } while (current.id == m_undoQueue.last().id);
}

void Sudoku::onGeneratorFailed()
{
    m_gameState = GameState::Empty;
    emit gameStateChanged();
    emit generatorFailed();
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

    // set start datetime
    setStartTime(QDateTime::currentDateTimeUtc());

    // emit state change
    m_gameState = GameState::Ready;
    emit gameStateChanged();

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

    // return if not solved
    if (m_unsolvedCellCount > 0) {
        start();
        return;
    }

    // check for errors
    for (quint8 i = 0; i < gridSize; ++i) {
        if (m_game[i] != m_solution[i]) {
            m_gameState = GameState::NotCorrect;
            emit gameStateChanged();
            return;
        }
    }

    // end puzzle
    stop();
    m_gameState = GameState::Solved;
    emit gameStateChanged();
}

void Sudoku::cleanupNotes(quint8 number)
{
    const quint16 id = m_currentUndoId++;

    for (int i = 0; i < gridSize; ++i) {
        const quint8 r = qFloor(i / rowSize);
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
