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
    void allDone();
};

class GalleryManager: public QObject
{
    Q_OBJECT
public:
    QString galleryRootPath;
    QThread galleryWorkerThread;
    GalleryManager(QObject* parent = 0);
    Q_INVOKABLE QString getGalleryRootPath();
    Q_INVOKABLE void reformat(int index, QString path);
    Q_INVOKABLE void restore(QString toName, QString fromName);
signals:
    void getOneDir(QString path, QString cover);
    void getOneImage(QString path, QString fileName);
    void scanPathAndCover(QString, int);
    void scanImageByPath(QString);
    void allDone();
    void outPut(int index, QString newName);
public slots:
    void prepareOneDir(QString path, QString cover);
    void prepareOneImage(QString path, QString fileName);
    void prepareAllDone();
};

#endif // GALLERYMANAGER_H
