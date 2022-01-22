#ifndef CACHE_H
#define CACHE_H

#include <QObject>

class Cache : public QObject
{
    Q_OBJECT

public:
    explicit Cache(QObject *parent = nullptr);

public slots:
    void cleanBookmarkScreenshots(const QString &keep = QString());

};

#endif // CACHE_H
