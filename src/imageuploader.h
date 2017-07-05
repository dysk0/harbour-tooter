#ifndef IMAGEUPLOADER_H
#define IMAGEUPLOADER_H

#include <QtCore/QObject>

class QNetworkAccessManager;
class QNetworkReply;

class ImageUploader : public QObject
{
    Q_OBJECT
    Q_PROPERTY(qreal progress READ progress NOTIFY progressChanged)

public:
    explicit ImageUploader(QObject *parent = 0);
    ~ImageUploader();

    Q_INVOKABLE void setFile(const QString &fileName);
    Q_INVOKABLE void setAuthorizationHeader(const QString &authorizationHeader);
    Q_INVOKABLE void setUserAgent(const QString &userAgent);
    Q_INVOKABLE void setParameters(const QString &album,  const QString &title, const QString &description);
    Q_INVOKABLE void upload();

    qreal progress() const;

signals:
    void success(const QString &replyData);
    void failure(const int status, const QString &statusText);
    void progressChanged();

private slots:
    void uploadProgress(qint64 bytesSent, qint64 bytesTotal);
    void replyFinished();

private:
    qreal m_progress;
    QNetworkAccessManager *m_networkAccessManager;

    QString m_fileName;
    QByteArray m_authorizationHeader;
    QByteArray m_userAgent;
    QByteArray postdata;
    QNetworkReply *m_reply;
};

#endif // IMAGEUPLOADER_H
