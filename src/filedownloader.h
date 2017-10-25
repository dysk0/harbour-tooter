/*
 * Copyright (C) 2015-2017 kimmoli <kimmo.lindholm@eke.fi>
 * All rights reserved.
 *
 * This file is part of Maira
 *
 * You may use this file under the terms of BSD license
 */

#ifndef FILEDOWNLOADER_H
#define FILEDOWNLOADER_H

#include <QObject>
#include <QByteArray>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QFile>
#include <QStandardPaths>
#include <QQmlEngine>
#include <QProcess>

class FileDownloader : public QObject
{
    Q_OBJECT
public:
    explicit FileDownloader(QQmlEngine *engine, QObject *parent = 0);
    Q_INVOKABLE void downloadFile(QUrl url, QString filename);
    Q_INVOKABLE void open(QString filename);

signals:
    void downloadStarted();
    void downloadSuccess();
    void downloadFailed(QString errorMsg);

private slots:
    void fileDownloaded();

private:
    QQmlEngine *m_engine;
    QByteArray m_DownloadedData;
    QString m_filename;
};

#endif // FILEDOWNLOADER_H
