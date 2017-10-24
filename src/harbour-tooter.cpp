#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif


#include <sailfishapp.h>
#include <QQuickView>
#include <QtQml>
#include <QtGui/QGuiApplication>
#include "imageuploader.h"
#include "dbus.h"

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());
    //QQmlContext *context = view.data()->rootContext();

    qmlRegisterType<ImageUploader>("harbour.tooter.Uploader", 1, 0, "ImageUploader");

    QQmlEngine* engine = view->engine();
    QObject::connect(engine, SIGNAL(quit()), app.data(), SLOT(quit()));

    Dbus *dbus = new Dbus();
        view->rootContext()->setContextProperty("Dbus", dbus);

    view->setSource(SailfishApp::pathTo("qml/harbour-tooter.qml"));
    view->show();
    return app->exec();
}
