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

QT += network dbus sql

CONFIG += sailfishapp

SOURCES += src/harbour-tooter.cpp \
    src/imageuploader.cpp

OTHER_FILES += qml/harbour-tooter.qml \
    qml/cover/CoverPage.qml \
    qml/pages/MainPage.qml \
    qml/pages/LoginPage.qml \
    qml/pages/components/MyList.qml \
    qml/pages/components/Navigation.qml \
    qml/pages/Conversation.qml \
    qml/pages/components/Toot.qml \
    qml/pages/Browser.qml \
    qml/pages/Profile.qml \
    qml/pages/components/ProfileHeader.qml \
    rpm/harbour-tooter.changes.in \
    rpm/harbour-tooter.spec \
    rpm/harbour-tooter.yaml \
    translations/*.ts \
    qml/pages/components/VisualContainer.qml \
    qml/pages/components/MiniStatus.qml \
    qml/pages/components/MiniHeader.qml \
    harbour-tooter.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += \
    translations/harbour-tooter-de.ts \
    translations/harbour-tooter-el.ts \
    translations/harbour-tooter-en.ts \
    translations/harbour-tooter-es.ts \
    translations/harbour-tooter-fr.ts \
    translations/harbour-tooter-nl.ts \
    translations/harbour-tooter-oc.ts \
    translations/harbour-tooter-sr.ts

DISTFILES += \
    qml/lib/API.js \
    qml/images/notification.svg \
    qml/images/home.svg \
    qml/images/mesagess.svg \
    qml/images/search.svg \
    qml/images/verified.svg \
    qml/images/tooter.svg \
    qml/lib/Mastodon.js \
    qml/lib/Worker.js \
    qml/images/boosted.svg \
    qml/pages/Settings.qml \
    qml/pages/components/MediaBlock.qml \
    qml/pages/components/MyImage.qml \
    qml/pages/components/ImageFullScreen.qml

HEADERS += \
    src/imageuploader.h
