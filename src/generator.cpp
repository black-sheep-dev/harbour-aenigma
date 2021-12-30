#include "generator.h"

#include "helper.h"

Generator::Generator(Difficulty::Level difficulty, QObject *parent) :
    QObject(parent),
    m_difficulty(difficulty)
{    

}

quint8 Generator::dice()
{
    static std::random_device rd;
    static std::ranlux24 generator(rd());
    static std::uniform_int_distribution<unsigned short> distribution(1, boxSize);
    return distribution(generator);
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


QVector<quint8> Generator::getShuffledNumbers() const
{
    QVector<quint8> numbers;
    numbers.resize(boxSize);

    for (quint8 i = 0; i < boxSize; ++i) {
        numbers[i] = i + 1;
    }

    std::random_shuffle(numbers.begin(), numbers.end());

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

void Generator::removeElements(QVector<quint8> &board, quint8 n)
{
    quint8 pos{0};
    quint8 value{0};

    for (quint8 i = 0; i < n;) {
        pos = Helper::index(dice() - 1, dice() - 1);
        value = board[pos];
        if (value != 0) {
            board[pos] = 0;
            if (numberOfSolutions(board) > 1) {
                board[pos] = value;
                continue;
            }
            ++i;
        }
    }
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
        const quint8 row = floor(i / rowSize);
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

    qint8 pos = findEmptyCell(board);

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
    QVector<quint8> solution(gridSize, 0);
    generateBoard(solution);

    QVector<quint8> puzzle(solution);
    removeElements(puzzle, m_difficulties[m_difficulty]);

    QVector<quint16> notes(gridSize, Note::None);
    generateNotes(notes, puzzle);

    emit finished(puzzle, solution, notes);
}
