#include "imageuploader.h"

#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>
#include <QtNetwork/QHttpMultiPart>

#include <QtCore/QFile>
#include <QtCore/QFileInfo>

//static const QUrl IMGUR_UPLOAD_URL("https://httpbin.org/post");
//static const QUrl IMGUR_UPLOAD_URL();

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

void ImageUploader::setUploadUrl(const QString &UrlString) {
    qDebug() << "Set Upload URL " + UrlString;
    m_uploadUrl = UrlString.toUtf8();
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

    /*QFileInfo fileInfo(QUrl(m_fileName).toLocalFile());
    qDebug("fileName: %s", qPrintable(m_fileName));
    if (!fileInfo.exists()) {
        emit failure(-1, tr("The file %1 does not exists").arg(m_fileName));
        postdata.clear();
        return;
    }*/

    QHttpMultiPart* multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);
    QHttpPart imagePart;


    //QFile file(fileInfo.absoluteFilePath());
    QFileInfo fileInfo(QUrl(m_fileName).toLocalFile());
    QFile* file = new QFile(QUrl(m_fileName).toLocalFile());
    if (!file->open(QIODevice::ReadWrite)) {
        emit failure(-1, tr("The file %1 does not exists").arg(m_fileName));
        return;
    }
    /*bool opened = file.open(QIODevice::ReadOnly);

    if (!opened) {
        qDebug("can't read file: %s", qPrintable(m_fileName));
        emit failure(-1, tr("Unable to open the file %1").arg(file.fileName()));
        postdata.clear();
        return;
    }*/

    //QByteArray fileData = file.readAll().toBase64();
    imagePart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant("image/jpeg"));
    imagePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant(QString("form-data; name=\"file\"; filename=\"%1\"").arg(fileInfo.fileName()).toLatin1()));
    imagePart.setBodyDevice(file);
    file->setParent(multiPart);
    multiPart->append(imagePart);

    //imagePart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant(fileInfo));



    //POST data



    QNetworkRequest request(m_uploadUrl);
    request.setRawHeader("Authorization", m_authorizationHeader);
    m_reply = m_networkAccessManager->post(request, multiPart);
    multiPart->setParent(m_reply);
    connect(m_reply, SIGNAL(uploadProgress(qint64,qint64)), this, SLOT(uploadProgress(qint64,qint64)));
    connect(m_reply, SIGNAL(finished()), this, SLOT(replyFinished()));



    //connect(m_reply, SIGNAL(uploadProgress(qint64,qint64)), this, SLOT(uploadProgress(qint64,qint64)));
    //connect(m_reply, SIGNAL(finished()), this, SLOT(replyFinished()));*/
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
