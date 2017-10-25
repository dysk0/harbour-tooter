/*
 * Copyright (C) 2015-2017 kimmoli <kimmo.lindholm@eke.fi>
 * All rights reserved.
 *
 * This file is part of Maira
 *
 * You may use this file under the terms of BSD license
 */

#include "notifications.h"

Notifications::Notifications(QObject *parent) :
    QObject(parent)
{
}

void Notifications::notify(QString appName, QString summary, QString body, bool preview, QString ts, QString issuekey)
{
    Notification notif;

    QVariantList remoteactions;

    if (preview)
    {
        notif.setPreviewSummary(summary);
        notif.setPreviewBody(body);
        notif.setCategory("x-harbour.tooter.activity");
        if (issuekey.isEmpty())
        {
            remoteactions << Notification::remoteAction("default",
                                                        QString(),
                                                        "ba.dysko.habour.tooter",
                                                        "/",
                                                        "ba.dysko.habour.tooter",
                                                        "openapp",
                                                         QVariantList());
        }
    }
    else
    {
        notif.setAppName(appName);
        notif.setSummary(summary);
        notif.setBody(body);
        notif.setItemCount(1);
        notif.setCategory("x-harbour.tooter.activity");
        remoteactions << Notification::remoteAction("app",
                                                    QString(),
                                                    "ba.dysko.habour.tooter",
                                                    "/",
                                                    "ba.dysko.habour.tooter",
                                                    "openapp",
                                                     QVariantList());
    }

    notif.setReplacesId(0);

    if (!ts.isEmpty())
        notif.setHintValue("x-nemo-timestamp", QVariant(ts));

    if (!issuekey.isEmpty())
    {
        QList<QVariant> args;
        args.append(QStringList() << issuekey);

        remoteactions << Notification::remoteAction("default",
                                                    QString(),
                                                    "ba.dysko.habour.tooter",
                                                    "/",
                                                    "ba.dysko.habour.tooter",
                                                    "showtoot",
                                                     args);
    }

    if (remoteactions.count() > 0)
        notif.setRemoteActions(remoteactions);

    notif.publish();
}
