TARGET = qmlpass

CONFIG += sailfishapp_qml

DISTFILES += qml/qmlpass.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    qml/pages/ResultPage.qml \
    qml/pages/PassphrasePage.qml \
    qml/pages/GPGAgent.qml \
    rpm/qmlpass.changes \
    rpm/qmlpass.changes.run.in \
    rpm/qmlpass.spec \
    rpm/qmlpass.yaml \
    qmlpass.desktop \
    icons/108x108/qmlpass.png \
    icons/128x128/qmlpass.png \
    icons/256x256/qmlpass.png \
    icons/86x86/qmlpass.png

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

SOURCES += qml/pages/passwordstore.py \
    qml/pages/gpg.py
