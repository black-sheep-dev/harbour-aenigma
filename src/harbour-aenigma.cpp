#include <QtQuick>

#include <sailfishapp.h>

#include "enums.h"
#include "sudoku.h"

Q_DECLARE_METATYPE(QVector<quint8>)

int main(int argc, char *argv[])
{
    qRegisterMetaType<QVector<quint8> >();

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

    qmlRegisterUncreatableType<CellData>(uri, 1, 0, "CellData", "ENUM");
    qmlRegisterUncreatableType<Difficulty>(uri, 1, 0, "Difficulty", "ENUM");
    qmlRegisterUncreatableType<EditMode>(uri, 1, 0, "EditMode", "ENUM");
    qmlRegisterUncreatableType<GameState>(uri, 1, 0, "GameState", "ENUM");
    qmlRegisterUncreatableType<Note>(uri, 1, 0, "Note", "ENUM");

    auto context = v.data()->rootContext();

    auto sudoku = new Sudoku;
    context->setContextProperty("Sudoku", sudoku);


    v->setSource(SailfishApp::pathTo("qml/harbour-aenigma.qml"));
    v->show();

    return app->exec();
}
