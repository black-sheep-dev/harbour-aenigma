#include "generator.h"

#include <QDateTime>
#include <QtMath>

#include "helper.h"

constexpr quint32 MAX_SOLUTION_TRIES{5000000};

Generator::Generator(Difficulty::Level difficulty, QObject *parent) :
    QObject(parent),
    m_difficulty(difficulty)
{    

}

quint8 Generator::dice()
{
    return qrand() % boxSize + 1;
}

void Generator::fillBox(quint8 row, quint8 col, QVector<quint8> &board, quint8 (*dice)())
{
    for (quint8 i = row * 3; i < (row + 1) * 3; ++i) {
        for (quint8 j = col * 3; j < (col + 1) * 3; ++j) {
            bool filled = false;
            while (!filled) {
                quint8 num = dice();

                if (isValidBox(num, i, j, board)) {
                    board[Helper::index(i, j)] = num;
                    filled = true;
                }
            }
        }
    }
}

qint8 Generator::findEmptyCell(QVector<quint8> &board)
{
    qint8 pos = -1;

    for (qint8 i = 0; i < gridSize && pos == -1; ++i) {
        if (board[i] == 0) {
            pos = i;
        }
    }

    return pos;
}


QVector<quint8> Generator::getShuffledNumbers()
{
    QVector<quint8> numbers;
    numbers.resize(boxSize);

    for (quint8 i = 0; i < boxSize; ++i) {
        numbers[i] = i + 1;
    }

    shuffleVector(numbers);

    return numbers;
}

bool Generator::isValid(quint8 num, quint8 row, quint8 col, const QVector<quint8> &board)
{
    return isValidBox(num, row, col, board) && isValidCol(num, col, board) && isValidRow(num, row, board);
}

bool Generator::isValidBox(quint8 num, quint8 row, quint8 col, const QVector<quint8> &board)
{
    const quint8 R = row - row % 3;
    const quint8 C = col - col % 3;

    for (quint8 i = 0; i < 3; ++i) {
        for (quint8 j = 0; j < 3; ++j) {
            if (num == board[Helper::index(R + i, C + j)]) return false;
        }
    }

    return true;
}

bool Generator::isValidCol(quint8 num, quint8 col, const QVector<quint8> &board)
{
    for (quint8 i = 0; i < boxSize; ++i) {
        if (num == board[Helper::index(i, col)]) {
            return false;
        }
    }

    return true;
}

bool Generator::isValidRow(quint8 num, quint8 row, const QVector<quint8> &board)
{
    for (quint8 i = 0; i < boxSize; ++i) {
        if (num == board[Helper::index(row, i)]) {
            return false;
        }
    }

    return true;
}

quint8 Generator::numberOfSolutions(QVector<quint8> &board, quint8 pos, quint8 count)
{  
    m_solutionTriesCounter++;

    if (m_solutionTriesCounter > MAX_SOLUTION_TRIES) {
        return 0;
    }

    if (pos == gridSize) {
        return 1 + count;
    }

    if (board[pos] != 0) {
        return numberOfSolutions(board, pos + 1, count);
    } else {
        for (quint8 val = 1; val <= boxSize && count < 2; ++val) {
            if (isValid(val, pos / boxSize, pos % boxSize, board)) {
                board[pos] = val;
                count = numberOfSolutions(board, pos + 1, count);
            }
        }
        board[pos] = 0;
        return count;
    }
}

bool Generator::removeElements(QVector<quint8> &board, quint8 n)
{
    quint8 pos{0};
    quint8 value{0};

    for (quint8 i = 0; i < n;) {
        pos = Helper::index(dice() - 1, dice() - 1);
        value = board[pos];
        if (value != 0) {
            board[pos] = 0;
            const quint8 solutions = numberOfSolutions(board);
            if (solutions > 1) {
                board[pos] = value;
                continue;
            } else if (solutions == 0) {
                return false;
            }
            ++i;
        }
    }

    return true;
}

void Generator::shuffleVector(QVector<quint8> &vector)
{
    quint8 i{0};
    quint8 j{0};

    quint8 cnt{0};
    while (cnt < vector.size()) {
        i = dice() - 1;
        j = dice() - 1;
        if (i != j) {
            swapNumber(i, j, vector);
            cnt++;
        }
    }
}

void Generator::swapNumber(quint8 i, quint8 j, QVector<quint8> &vector)
{
    quint8 temp = vector[i];
    vector[i] = vector[j];
    vector[j] = temp;
}

void Generator::generateBoard(QVector<quint8> &board)
{
    board.fill(0);

    for (quint8 i = 0; i < 3; ++i) {
        fillBox(i, i, board, dice);
    }

    solveBoard(board);
}

void Generator::generateNotes(QVector<quint16> &notes, const QVector<quint8> &board)
{
    notes.fill(Note::None);

    for (int i = 0; i < gridSize; ++i) {
        if (board[i] != 0) continue;
        const quint8 row = qFloor(i / rowSize);
        const quint8 col = i - row * rowSize;

        for (int n = 1; n <= boxSize; ++n) {
            if (!isValid(n, row, col, board)) continue;
            notes[i] |= Helper::numberToNote(n);
        }
    }
}

bool Generator::solveBoard(QVector<quint8> &board)
{
    QVector<quint8> numbers(getShuffledNumbers());

    const qint8 pos = findEmptyCell(board);

    if (pos == -1) {
        return true;
    }

    for (quint8 num = 0; num < boxSize; num++) {
        const unsigned short number = numbers[num];
        if (isValid(number, pos / boxSize, pos % boxSize, board)) {
            board[pos] = number;
            if (solveBoard(board)) {
                return true;
            } else {
                board[pos] = 0;
            }
        }
    }
    return false;
}

void Generator::run()
{
    // seeding random number generator
    qsrand(QDateTime::currentMSecsSinceEpoch());

    // generate board
    QVector<quint8> solution(gridSize, 0);
    generateBoard(solution);

    // generate puzzle
    QVector<quint8> puzzle(solution);
    if (!removeElements(puzzle, m_difficulties[m_difficulty])) {
        emit failed();
        return;
    }

    // generate notes
    QVector<quint16> notes(gridSize, Note::None);
    generateNotes(notes, puzzle);

    // emit finished
    emit finished(puzzle, solution, notes);
}
