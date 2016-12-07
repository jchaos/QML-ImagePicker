#ifndef GALLERYMANAGER_H
#define GALLERYMANAGER_H
#include <QObject>
#include <QString>
#include <QStringList>
#include <QMap>
#include <QThread>

class GalleryWorker: public QObject
{
    Q_OBJECT
public:
    QMap<QString, QString>pathAndCoverMap;
public slots:
    void scanPathAndCoverThread(QString, int);
    void scanImageByPathThread(QString);
signals:
    void getOneDirThread(QString path, QString cover);
    void getOneImageThread(QString path, QString fileName);
};

class GalleryManager: public QObject
{
    Q_OBJECT
public:
    QString galleryRootPath;
    QThread galleryWorkerThread;
    GalleryManager(QObject* parent = 0);
    Q_INVOKABLE QString getGalleryRootPath();
signals:
    void getOneDir(QString path, QString cover);
    void getOneImage(QString path, QString fileName);
    void scanPathAndCover(QString, int);
    void scanImageByPath(QString);
public slots:
    void prepareOneDir(QString path, QString cover);
    void prepareOneImage(QString path, QString fileName);
};

#endif // GALLERYMANAGER_H
