#ifndef GALLERYMANAGER_H
#define GALLERYMANAGER_H
#include <QObject>
#include <QString>
#include <QStringList>
#include <QMap>

class GalleryManager: public QObject
{
    Q_OBJECT
private:
    QString galleryRootPath;
    QMap<QString, QString>pathAndCoverMap;
public:
    GalleryManager(QObject* parent = 0);
    Q_INVOKABLE QString getGalleryRootPath();
    Q_INVOKABLE void scanPathAndCover(QString, int);
    Q_INVOKABLE void scanImageByPath(QString);
signals:
    void getOneDir(QString path, QString cover);
    void getOneImage(QString path, QString fileName);
};

#endif // GALLERYMANAGER_H
