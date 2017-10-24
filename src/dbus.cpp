#include "dbus.h"

static const char *PATH = "/";
static const char *SERVICE = SERVICE_NAME;

Dbus::Dbus(QObject *parent) :
    QObject(parent)
{
    m_dbusRegistered = false;
    new TooterAdaptor(this);
    registerDBus();
}

Dbus::~Dbus()
{
    if (m_dbusRegistered)
    {
        QDBusConnection connection = QDBusConnection::sessionBus();
        connection.unregisterObject(PATH);
        connection.unregisterService(SERVICE);
    }
}

void Dbus::registerDBus()
{
    if (!m_dbusRegistered)
    {
        QDBusConnection connection = QDBusConnection::sessionBus();
        if (!connection.registerService(SERVICE))
        {
            QCoreApplication::quit();
            return;
        }

        if (!connection.registerObject(PATH, this))
        {
            QCoreApplication::quit();
            return;
        }
        m_dbusRegistered = true;
    }
}

void Dbus::showtoot(const QStringList &key)
{
    emit viewtoot(key.at(0));
}

void Dbus::openapp()
{
    emit activateapp();
}
