#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif


#include <sailfishapp.h>
#include <QQuickView>
#include <QtQml>
#include <QScopedPointer>
#include <QQmlEngine>
#include <QGuiApplication>
#include <QQmlContext>
#include <QCoreApplication>
#include <QtNetwork>
//#include <QtSystemInfo/QDeviceInfo>
//#include "filedownloader.h"
#include "imageuploader.h"
//#include "notifications.h"
//#include "dbus.h"

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());
    //QQmlContext *context = view.data()->rootContext();
    QQmlEngine* engine = view->engine();

    //FileDownloader *fd = new FileDownloader(engine);
    //view->rootContext()->setContextProperty("FileDownloader", fd);
    qmlRegisterType<ImageUploader>("harbour.tooter.Uploader", 1, 0, "ImageUploader");

    //Notifications *no = new Notifications();
    //view->rootContext()->setContextProperty("Notifications", no);
    QObject::connect(engine, SIGNAL(quit()), app.data(), SLOT(quit()));

    //Dbus *dbus = new Dbus();
    //view->rootContext()->setContextProperty("Dbus", dbus);

    view->setSource(SailfishApp::pathTo("qml/harbour-tooter.qml"));
    view->show();
    return app->exec();
}
