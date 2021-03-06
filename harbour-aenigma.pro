# VERSION
VERSION = 0.4.0
DEFINES += APP_VERSION=\\\"$$VERSION\\\"

TARGET = harbour-aenigma
DEFINES += APP_TARGET=\\\"$$TARGET\\\"

QT += sql dbus

include(extern/libaenigma/libaenigma.pri)
include(extern/harbour-lib.pri)

CONFIG += link_pkgconfig sailfishapp
PKGCONFIG += nemonotifications-qt5

SOURCES += src/harbour-aenigma.cpp \
    src/cache.cpp \
    src/database.cpp

DISTFILES += qml/harbour-aenigma.qml \
    qml/BoardStyles.qml \
    qml/Global.qml \
    qml/components/CellPreviewItem.qml \
    qml/components/ColorSelectorItem.qml \
    qml/components/ColorWheel.qml \
    qml/components/Controls.qml \
    qml/components/GameBlock.qml \
    qml/components/GameBoard.qml \
    qml/components/IconSwitch.qml \
    qml/components/NoteBlock.qml \
    qml/components/ResultBoard.qml \
    qml/components/StatisticDetails.qml \
    qml/cover/CoverPage.qml \
    qml/dialogs/AddBookmarkDialog.qml \
    qml/dialogs/ColorSelectionDialog.qml \
    qml/dialogs/NewGameDialog.qml \
    qml/pages/BookmarksListPage.qml \
    qml/pages/CustomizeStylePage.qml \
    qml/pages/GamePage.qml \
    qml/pages/SettingsPage.qml \
    qml/pages/StatisticsPage.qml \
    rpm/harbour-aenigma.changes \
    rpm/harbour-aenigma.changes.run.in \
    rpm/harbour-aenigma.spec \
    rpm/harbour-aenigma.yaml \
    translations/*.ts \
    harbour-aenigma.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172 512x512

include(translations/translations.pri)

HEADERS += \
    src/cache.h \
    src/database.h \
    src/enums.h

RESOURCES += \
    ressources.qrc

images.files = images/*.*
images.path = $$INSTALL_ROOT/usr/share/harbour-aenigma/images

INSTALLS += images
