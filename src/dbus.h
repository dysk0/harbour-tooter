#ifndef DBUS_H
#define DBUS_H

#include <QObject>
#include <QtDBus/QtDBus>
#include "dbusAdaptor.h"

#define SERVICE_NAME "ba.dysko.harbour.tooter"

class QDBusInterface;
class Dbus : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", SERVICE_NAME)

public:
    explicit Dbus(QObject *parent = 0);
    ~Dbus();
    void registerDBus();

public Q_SLOTS:
    Q_NOREPLY void showtoot(const QStringList &key);
    Q_NOREPLY void openapp();

signals:
    void viewtoot(QString key);
    void activateapp();

private:
    bool m_dbusRegistered;
};

#endif // DBUS_H
