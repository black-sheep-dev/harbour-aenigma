TRANSLATIONS += \
    translations/harbour-aenigma.ts \
    translations/harbour-aenigma-de.ts \
    translations/harbour-aenigma-hu.ts \
    translations/harbour-aenigma-es.ts \
    translations/harbour-aenigma-pl.ts \
    translations/harbour-aenigma-nl.ts


qm.input    = TRANSLATIONS
qm.output   = translations/${QMAKE_FILE_BASE}.qm
qm.commands = @echo "compiling ${QMAKE_FILE_NAME}"; \
                lrelease -idbased -silent ${QMAKE_FILE_NAME} -qm ${QMAKE_FILE_OUT}
qm.CONFIG   = target_predeps no_link

QMAKE_EXTRA_COMPILERS += qm

translations.files = $$OUT_PWD/translations
translations.path  = $$PREFIX/share/$$TARGET

INSTALLS += translations

