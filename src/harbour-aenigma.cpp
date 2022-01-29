#include <QtQuick>

#include <QDir>
#include <QStandardPaths>

#include <sailfishapp.h>

#include "cache.h"
#include "database.h"
#include "enums.h"

#include "aenigma.h"
#include "sudoku.h"

Q_DECLARE_METATYPE(QVector<quint8>)
Q_DECLARE_METATYPE(QVector<quint16>)

int main(int argc, char *argv[])
{
    qRegisterMetaType<QVector<quint8> >();
    qRegisterMetaType<QVector<quint16> >();

    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> v(SailfishApp::createView());

    app->setApplicationVersion(APP_VERSION);
    app->setApplicationName("aenigma");
    app->setOrganizationDomain("org.nubecula");
    app->setOrganizationName("org.nubecula");

#ifdef QT_DEBUG
    #define uri "org.nubecula.aenigma"
#else
    const auto uri = "org.nubecula.aenigma";
#endif

    qmlRegisterUncreatableType<Aenigma::CellData>(uri, 1, 0, "CellData", "ENUM");
    qmlRegisterUncreatableType<Aenigma::Difficulty>(uri, 1, 0, "Difficulty", "ENUM");
    qmlRegisterUncreatableType<EditMode>(uri, 1, 0, "EditMode", "ENUM");
    qmlRegisterUncreatableType<Aenigma::GameState>(uri, 1, 0, "GameState", "ENUM");
    qmlRegisterUncreatableType<HighlightMode>(uri, 1, 0, "HighlightMode", "ENUM");
    qmlRegisterUncreatableType<Aenigma::Note>(uri, 1, 0, "Note", "ENUM");
    qmlRegisterUncreatableType<Styles>(uri, 1, 0, "Styles", "ENUM");

    qmlRegisterType<Cache>(uri, 1, 0, "Cache");
    qmlRegisterType<Aenigma::Sudoku>(uri, 1, 0, "Sudoku");

    auto context = v.data()->rootContext();

    //auto sudoku = new Sudoku(qApp);
    //context->setContextProperty("Sudoku", sudoku);

    auto db = new Database;
    context->setContextProperty("DB", db);

    v->setSource(SailfishApp::pathTo("qml/harbour-aenigma.qml"));
    v->show();

    return app->exec();
}
