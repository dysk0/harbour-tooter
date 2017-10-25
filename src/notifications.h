/*
 * Copyright (C) 2015-2017 kimmoli <kimmo.lindholm@eke.fi>
 * All rights reserved.
 *
 * This file is part of Maira
 *
 * You may use this file under the terms of BSD license
 */

#ifndef NOTIFICATIONS_H
#define NOTIFICATIONS_H

#include <QObject>
#include <nemonotifications-qt5/notification.h>

class Notifications : public QObject
{
    Q_OBJECT
public:
    explicit Notifications(QObject *parent = 0);
    Q_INVOKABLE void notify(QString appName, QString summary, QString body, bool preview, QString ts, QString issuekey);
};

#endif // NOTIFICATIONS_H
