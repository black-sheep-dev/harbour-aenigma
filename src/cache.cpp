#include "cache.h"

#include <QDebug>
#include <QDir>
#include <QDirIterator>
#include <QFile>
#include <QStandardPaths>

Cache::Cache(QObject *parent) : QObject(parent)
{
    QDir().mkpath(QStandardPaths::writableLocation(QStandardPaths::CacheLocation) + QStringLiteral("/bookmarks/"));
}

void Cache::cleanBookmarkScreenshots(const QString &keep)
{
    QDirIterator it(QStandardPaths::writableLocation(QStandardPaths::CacheLocation) + QStringLiteral("/bookmarks/"), QDir::Files);

    while (it.hasNext()) {
        const QString file = it.next();

        if (!keep.isEmpty() && file.contains(keep)) {
            continue;
        }

        QFile().remove(file);
    }
}
