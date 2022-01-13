#include "database.h"

#include <QDateTime>
#include <QDebug>
#include <QDir>
#include <QJsonArray>
#include <QSqlError>
#include <QSqlQuery>
#include <QStandardPaths>
#include <QVector>

#include "enums.h"

constexpr qint32 AENIGMA_DATABASE_APP_ID = 1798;
constexpr quint16 AENIGMA_DATABASE_VERSION = 1;
constexpr quint8 AENIGMA_LEVEL_COUNT = 4;

Database::Database(QObject *parent) : QObject(parent)
{
    open();
}

QJsonObject Database::getStatisticOverview() const
{
    // initalize empty object
    QJsonObject obj;

    QSqlQuery query(m_db);

    if (!query.exec(QStringLiteral("SELECT level, steps, hints, time FROM games ORDER BY created_at DESC"))) {
        qWarning() << "Failed to fetch data";
        return obj;
    }

    QVector<quint32> levels(AENIGMA_LEVEL_COUNT, 0);
    QVector<quint32> steps(AENIGMA_LEVEL_COUNT, 0);
    QVector<quint32> stepsMin(AENIGMA_LEVEL_COUNT, 4294967295);
    QVector<quint32> hints(AENIGMA_LEVEL_COUNT, 0);
    QVector<quint32> hintsMin(AENIGMA_LEVEL_COUNT, 0);
    QVector<qint64> times(AENIGMA_LEVEL_COUNT, 0);
    QVector<qint64> timesMin(AENIGMA_LEVEL_COUNT, 9223372036854775807);

    quint32 count{0};
    qint64 timesTotal{0};

    while (query.next()) {
        const quint8 level = query.value(0).toUInt();

        levels[level]++;

        const quint32 step = query.value(1).toUInt();
        steps[level] += step;
        stepsMin[level] = qMin(step, stepsMin[level]);

        const quint32 hint = query.value(2).toUInt();
        hints[level] += hint;
        hintsMin[level] = qMin(hint, hintsMin[level]);

        const qint64 time = query.value(3).toUInt();
        times[level] += time;
        timesTotal += time;
        timesMin[level] = qMin(time, timesMin[level]);

        count++;
    }

    obj.insert("total_count", int(count));
    obj.insert("total_time", int(timesTotal));

    QStringList diffLvl;
    diffLvl << "easy" << "medium" << "hard" << "insane";

    for (int i = 0; i < 4; ++i) {
        QJsonObject lvl;
        lvl.insert("games", int(levels[i]));
        lvl.insert("avg_steps", levels[i] ? int(steps[i] / levels[i]) : 0);
        lvl.insert("min_steps", int(stepsMin[i]));
        lvl.insert("avg_hints", levels[i] ? int(hints[i] / levels[i]) : 0);
        lvl.insert("min_hints", int(hintsMin[i]));
        lvl.insert("avg_time", levels[i] ? int(times[i] / levels[i]) : 0);
        lvl.insert("min_time", int(timesMin[i]));

        obj.insert(diffLvl[i], lvl);
    }

    return obj;
}

bool Database::addGame(quint8 level, quint32 steps, quint32 hints, qint64 time)
{
    QSqlQuery query(m_db);

    query.prepare(QStringLiteral("INSERT INTO games (level, steps, hints, time, created_at) "
                                 "VALUES (:level, :steps, :hints, :time, :created_at)"));

    query.bindValue(":level", level);
    query.bindValue(":steps", steps);
    query.bindValue(":hints", hints);
    query.bindValue(":time", time);
    query.bindValue(":created_at", QDateTime::currentMSecsSinceEpoch());

    if (!query.exec()) {
        qWarning() << "Could add game: " << query.lastError().text();
        return false;
    }

    return true;
}

bool Database::reset()
{
    QSqlQuery query(QStringLiteral("DROP TABLE IF EXISTS games"), m_db);

    if (!query.exec()) {
        qWarning() << "Failed to reset database";
        return false;
    }

    createTables();

    return true;
}

void Database::createTables()
{
    QSqlQuery query(m_db);

    // create table games
    bool ok = query.exec(QStringLiteral("CREATE TABLE IF NOT EXISTS games("
                                        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                                        "level INTEGER DEFAULT 0,"
                                        "steps INTEGER DEFAULT 0,"
                                        "hints INTEGER DEFAULT 0,"
                                        "time INTEGER DEFAULT 0,"
                                        "created_at INTEGER DEFAULT 0,"
                                        "updated_at INTEGER DEFAULT 0"
                                        ")"));

    if (!ok) {
        qWarning() << "Could not create table games: " << query.lastError().text();
    }
}

QVariant Database::getPragma(const QString &key)
{
    QSqlQuery query(m_db);
    query.exec(QString("PRAGMA %1").arg(key));
    query.next();

    return query.value(0);
}

void Database::open()
{
    QDir().mkpath(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation));

    const auto path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + QStringLiteral("/aenigma.db");

    bool exists = QFile(path).exists();

    m_db = QSqlDatabase::addDatabase("QSQLITE", QLatin1String("AENIGMA_DB"));
    m_db.setDatabaseName(path);

    if (!m_db.open()) {
        qWarning() << "Could not open database";
        return;
    }

    // check if database is valid and update if necessary
    if (exists) {
        const qint32 appId = getPragma("application_id").toInt();
        if (appId != AENIGMA_DATABASE_APP_ID) {
            qCritical() << "Unsupported database";
            return;
        }

        const quint8 version = getPragma("user_version").toUInt();

        if (version != AENIGMA_DATABASE_VERSION) {
            if (!update(version)) {
                 qCritical() << "Failed to update database";
                 return;
            }
        }
    }

    // create database
    QSqlQuery query(m_db);

    // set pragmas
    if (!exists) {
        query.exec(QStringLiteral("PRAGMA application_id = %1").arg(AENIGMA_DATABASE_APP_ID));
        query.exec(QStringLiteral("PRAGMA auto_vacuum = FULL"));
    }
    query.exec(QStringLiteral("PRAGMA user_version = %1").arg(AENIGMA_DATABASE_VERSION));

    // create tables
    createTables();
}

bool Database::update(quint8 version)
{
    Q_UNUSED(version)

    return false;
}
