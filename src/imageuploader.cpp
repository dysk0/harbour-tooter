#include "imageuploader.h"

#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>
#include <QHttpMultiPart>
#include <QtCore/QFile>
#include <QtCore/QFileInfo>

//static const QUrl IMGUR_UPLOAD_URL("https://httpbin.org/post");
static const QUrl IMGUR_UPLOAD_URL("https://mastodon.social/api/v1/media");

ImageUploader::ImageUploader(QObject *parent) : QObject(parent), m_networkAccessManager(0), m_reply(0) {
    m_networkAccessManager = new QNetworkAccessManager(this);
}

ImageUploader::~ImageUploader() {
    if (m_reply != 0) {
        m_reply->disconnect();
        m_reply->deleteLater();
        m_reply = 0;
    }
}

void ImageUploader::setFile(const QString &fileName) {
    m_fileName = fileName;
}

void ImageUploader::setParameters(const QString &album, const QString &title, const QString &description) {
    //if (!album.isEmpty()) {
    postdata.append(QString("album=").toUtf8());
    postdata.append(QUrl::toPercentEncoding(album));
    //}
    if (!title.isEmpty()) {
        postdata.append(QString("&title=").toUtf8());
        postdata.append(QUrl::toPercentEncoding(title));
    }
    if (!description.isEmpty()) {
        postdata.append(QString("&description=").toUtf8());
        postdata.append(QUrl::toPercentEncoding(description));
    }
}

void ImageUploader::setAuthorizationHeader(const QString &authorizationHeader) {
    m_authorizationHeader = "Bearer "+authorizationHeader.toUtf8();
}

void ImageUploader::setUserAgent(const QString &userAgent) {
    m_userAgent = userAgent.toUtf8();
}

void ImageUploader::upload() {

    if (!m_networkAccessManager) {
        qWarning("ImageUploader::send(): networkAccessManager not set");
        return;
    }

    if (m_reply != 0) {
        m_reply->disconnect();
        m_reply->deleteLater();
        m_reply = 0;
    }

    qDebug() << "TwitterApi::uploadImage";
    QUrl url = IMGUR_UPLOAD_URL;
    QNetworkRequest request(url);
    QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);
    QHttpPart imagePart;
    //imagePart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant("image/jpeg"));
    imagePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"file\""));
    QFile *file = new QFile(m_fileName);
    file->open(QIODevice::ReadOnly);
    QByteArray rawImage = file->readAll();
    imagePart.setBody(rawImage);
    file->setParent(multiPart);

    multiPart->append(imagePart);





    //request.setUrl(IMGUR_UPLOAD_URL);
    request.setRawHeader("Authorization", m_authorizationHeader);
    request.setRawHeader("Content-Type", "application/x-www-form-urlencoded");

    //    request.setRawHeader("User-Agent", m_userAgent);



    m_reply = m_networkAccessManager->post(request, multiPart);
    multiPart->setParent(m_reply);
    m_reply->setObjectName("file");



    connect(m_reply, SIGNAL(uploadProgress(qint64,qint64)), this, SLOT(uploadProgress(qint64,qint64)));
    connect(m_reply, SIGNAL(finished()), this, SLOT(replyFinished()));
}

qreal ImageUploader::progress() const {
    return m_progress;
}

void ImageUploader::uploadProgress(qint64 bytesSent, qint64 bytesTotal) {
    qreal progress = qreal(bytesSent) / qreal(bytesTotal);
    //qDebug("uploadProgress: %f , %f, %f", qreal(bytesSent), qreal(bytesTotal), qreal(progress));

    if (m_progress != progress) {
        m_progress = progress;
        emit progressChanged();
    }
}

void ImageUploader::replyFinished() {
    if (!m_reply->error()) {
        QByteArray replyData = m_reply->readAll();
        emit success(replyData);
    }
    else {
        int status = m_reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        QString statusText = m_reply->errorString();
        emit failure(status, statusText);
    }

    m_reply->deleteLater();
    m_reply = 0;
    postdata.clear();
}
