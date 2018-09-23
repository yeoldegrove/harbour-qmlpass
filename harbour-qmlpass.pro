TARGET = harbour-qmlpass

CONFIG += sailfishapp_qml

DISTFILES += qml/qmlpass.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    qml/pages/ResultPage.qml \
    qml/pages/PassphrasePage.qml \
    qml/pages/GPGAgent.qml \
    rpm/harbour-qmlpass.changes \
    rpm/harbour-qmlpass.changes.run.in \
    rpm/harbour-qmlpass.spec \
    rpm/harbour-qmlpass.yaml \
    harbour-qmlpass.desktop \
    icons/108x108/harbour-qmlpass.png \
    icons/128x128/harbour-qmlpass.png \
    icons/256x256/harbour-qmlpass.png \
    icons/86x86/harbour-qmlpass.png

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

SOURCES += qml/pages/passwordstore.py \
    qml/pages/gpg.py
