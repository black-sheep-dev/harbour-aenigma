#ifndef DATABASE_H
#define DATABASE_H

#include <QObject>

#include <QJsonArray>
#include <QJsonObject>
#include <QSqlDatabase>
#include <QVariant>

template <typename T>
inline QJsonArray const toJsonArray(QVector<T> const &array) {
    QJsonArray arr;
    for (const auto &value : array) {
        arr.append(value);
    }

    return arr;
};

class Database : public QObject
{
    Q_OBJECT
public:
    explicit Database(QObject *parent = nullptr);

    Q_INVOKABLE QJsonObject getStatisticOverview() const;

public slots:
    bool addGame(quint8 level, quint32 steps, quint32 hints, qint64 time);
    bool reset();

private:
    void createTables();
    QVariant getPragma(const QString &key);
    void open();
    bool update(quint8 version);


    QSqlDatabase m_db;
};

#endif // DATABASE_H
