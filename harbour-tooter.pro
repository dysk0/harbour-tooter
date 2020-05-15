# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-tooter

CONFIG += sailfishapp

QT += network dbus sql
CONFIG += link_pkgconfig
PKGCONFIG += sailfishapp
PKGCONFIG += \
    nemonotifications-qt5

DEFINES += "APPVERSION=\\\"$${SPECVERSION}\\\""
DEFINES += "APPNAME=\\\"$${TARGET}\\\""

!exists( src/dbusAdaptor.h ) {
    system(qdbusxml2cpp config/ba.dysko.harbour.tooter.xml -i dbus.h -a src/dbusAdaptor)
}

config.path = /usr/share/$${TARGET}/config/
config.files = config/icon-lock-harbour-tooter.png

notification_categories.path = /usr/share/lipstick/notificationcategories
notification_categories.files = config/x-harbour.tooter.activity.*

dbus_services.path = /usr/share/dbus-1/services/
dbus_services.files = config/ba.dysko.harbour.tooter.service

interfaces.path = /usr/share/dbus-1/interfaces/
interfaces.files = config/ba.dysko.harbour.tooter.xml

SOURCES += src/harbour-tooter.cpp
SOURCES += src/imageuploader.cpp
SOURCES += src/filedownloader.cpp
SOURCES += src/notifications.cpp
SOURCES += src/dbusAdaptor.cpp
SOURCES += src/dbus.cpp

HEADERS += src/imageuploader.h
HEADERS += src/filedownloader.h
HEADERS += src/notifications.h
HEADERS += src/dbusAdaptor.h
HEADERS += src/dbus.h

DISTFILES += qml/harbour-tooter.qml \
    qml/pages/components/VisualContainer.qml \
    qml/pages/components/MiniStatus.qml \
    qml/pages/components/MiniHeader.qml \
    qml/pages/components/ItemUser.qml \
    qml/pages/components/MyList.qml \
    qml/pages/components/Navigation.qml \
    qml/pages/components/ProfileHeader.qml \
    qml/pages/components/MediaBlock.qml \
    qml/pages/components/MyImage.qml \
    qml/pages/components/ImageFullScreen.qml \
    qml/cover/CoverPage.qml \
    qml/pages/MainPage.qml \
    qml/pages/LoginPage.qml \
    qml/pages/Conversation.qml \
    qml/pages/components/Toot.qml \
    qml/pages/Browser.qml \
    qml/pages/Profile.qml \
    qml/pages/Settings.qml \
    qml/lib/API.js \
    qml/images/notification.svg \
    qml/images/verified.svg \
    qml/images/boosted.svg \
    qml/images/tooter.svg \
    qml/images/emojiselect.svg \
    qml/images/icon-m-profile.svg \
    qml/images/icon-l-profile.svg \
    qml/lib/Mastodon.js \
    qml/lib/Worker.js \
    config/icon-lock-harbour-tooter.png \
    config/x-harbour.tooter.activity.conf \
    rpm/harbour-tooter.changes \
    rpm/harbour-tooter.changes.run.in \
    rpm/harbour-tooter.spec \
    rpm/harbour-tooter.yaml \
    translations/*.ts \
    harbour-tooter.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-tooter-de.ts
TRANSLATIONS += translations/harbour-tooter-el.ts
TRANSLATIONS += translations/harbour-tooter-es.ts
TRANSLATIONS += translations/harbour-tooter-fi.ts
TRANSLATIONS += translations/harbour-tooter-fr.ts
TRANSLATIONS += translations/harbour-tooter-nl.ts
TRANSLATIONS += translations/harbour-tooter-nl_BE.ts
TRANSLATIONS += translations/harbour-tooter-oc.ts
TRANSLATIONS += translations/harbour-tooter-pl.ts
TRANSLATIONS += translations/harbour-tooter-ru.ts
TRANSLATIONS += translations/harbour-tooter-sr.ts
TRANSLATIONS += translations/harbour-tooter-sv.ts
TRANSLATIONS += translations/harbour-tooter-zh_CN.ts
TRANSLATIONS += translations/harbour-tooter-it.ts
