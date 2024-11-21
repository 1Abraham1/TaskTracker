TARGET = ru.template.TaskTracker

CONFIG += \
    auroraapp

PKGCONFIG += \

SOURCES += \
    src/custom.cpp \
    src/main.cpp \
    src/task.cpp

HEADERS += \
    src/custom.h \
    src/task.h

DISTFILES += \
    ../../Загрузки/delete_icon.png \
    qml/icons/delete_icon.png \
    qml/icons/white_circle.png \
    qml/pages/AddEventPage.qml \
    qml/pages/DBTaskPage.qml \
    qml/pages/DayPage.qml \
    qml/pages/DeleteDialog.qml \
    qml/pages/GraphicEditorPage.qml \
    qml/pages/ShowAllTasks.qml \
    qml/pages/ShowTaskPage.qml \
    qml/pages/func.js \
    rpm/ru.template.TaskTracker.spec \

AURORAAPP_ICONS = 86x86 108x108 128x128 172x172

CONFIG += auroraapp_i18n

TRANSLATIONS += \
    translations/ru.template.TaskTracker.ts \
    translations/ru.template.TaskTracker-ru.ts \
