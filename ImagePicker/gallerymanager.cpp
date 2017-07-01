#include "gallerymanager.h"
#include <QDir>
#include <QFileInfo>
#include <QFileInfoList>
#include <QDebug>
#include <QStandardPaths>
#include <QFile>
#include <QByteArray>
#include <QImage>

GalleryManager::GalleryManager(QObject* parent):QObject(parent)
{
    GalleryWorker *galleryWorker = new GalleryWorker;
    galleryWorker->moveToThread(&galleryWorkerThread);
#ifdef Q_OS_ANDROID
    this->galleryRootPath = "/mnt/sdcard";
#endif
#ifdef Q_OS_WIN
    this->galleryRootPath = QStandardPaths::standardLocations(QStandardPaths::PicturesLocation)[0];
    this->galleryRootPath = "E:/";
#endif
    connect(this, SIGNAL(scanPathAndCover(QString, int)), galleryWorker, SLOT(scanPathAndCoverThread(QString, int)));
    connect(galleryWorker, SIGNAL(getOneDirThread(QString, QString)), this, SLOT(prepareOneDir(QString, QString)));
    connect(this, SIGNAL(scanImageByPath(QString)), galleryWorker, SLOT(scanImageByPathThread(QString)));
    connect(galleryWorker, SIGNAL(getOneImageThread(QString, QString)), this, SLOT(prepareOneImage(QString, QString)));
    connect(galleryWorker, SIGNAL(allDone()), this, SLOT(prepareAllDone()));
    galleryWorkerThread.start();
}

void GalleryManager::prepareAllDone()
{
    emit allDone();
}

void GalleryManager::restore(QString toName, QString fromName)
{
    QFile::rename(fromName, toName);
}

void GalleryManager::reformat(int index, QString path)
{
    QFileInfo fileInfo(path);
    QString baseName = fileInfo.completeBaseName();
    QString filePath = fileInfo.absolutePath();
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        return;
    }
    QString pngCode = "8950";
    QString jpgCode = "ffd8";
    QByteArray bt = file.read(2).toHex();
    file.close();
    if(bt == pngCode)
    {
        QString newName = filePath+"/"+baseName+".png";
        QFile::rename(path, newName);
        emit outPut(index, newName);
    }
    if(bt == jpgCode)
    {
        QString newName = filePath+"/"+baseName+".jpg";
        QFile::rename(path, newName);
        emit outPut(index, newName);
    }
}

void GalleryManager::prepareOneDir(QString path, QString cover)
{
    emit getOneDir(path, cover);
}

void GalleryManager::prepareOneImage(QString path, QString filePath)
{

    emit getOneImage(path, filePath);
}

QString GalleryManager::getGalleryRootPath()
{

    return galleryRootPath;
}

void GalleryWorker::scanPathAndCoverThread(QString path, int maxDepth)
{
    static int depth = 0;
    QDir rootDir(path);
    QFileInfoList list = rootDir.entryInfoList(QDir::Dirs | QDir::Files | QDir::NoDotAndDotDot);

    for(int i = 0; i<list.count(); i++)
    {
        QFileInfo fileInfo = list.at(i);
        QString suffix = fileInfo.suffix().toLower();
        if(fileInfo.isFile() && (suffix.compare("jpg") == 0 || suffix.compare("png") == 0 || suffix.compare("jpeg") == 0))
        {
            if(!pathAndCoverMap.contains(fileInfo.absolutePath()))
            {
                QString pathString = fileInfo.absolutePath();
                QString coverString = fileInfo.absoluteFilePath();
                pathAndCoverMap.insert(pathString, coverString);
                emit getOneDirThread(pathString, coverString);
            }
        }
        if(fileInfo.isDir())
        {
            depth++;
            if(maxDepth == 0)
            {
                scanPathAndCoverThread(fileInfo.filePath(), maxDepth);
            }
            else
            {
                if(depth > maxDepth)
                {
                    depth--;
                }
                else
                {
                    scanPathAndCoverThread(fileInfo.filePath(), maxDepth);
                }
            }
        }
    }
    depth--;
    if(depth == 0)
    {
        pathAndCoverMap.clear();
    }
}

void GalleryWorker::scanImageByPathThread(QString path)
{
    QDir rootDir(path);
    QStringList filters;
    filters << "*.jpg" << "*.png" << "*.jpeg";
    rootDir.setNameFilters(filters);
    QFileInfoList list = rootDir.entryInfoList();

    for(int i = 0; i<list.count(); i++)
    {
        QFileInfo fileInfo = list.at(i);
        QString pathString = fileInfo.absoluteFilePath();
        QString fileName = fileInfo.fileName();

        emit getOneImageThread(pathString, fileName);
    }
    emit allDone();
}

GalleryManager::~GalleryManager()
{
    galleryWorkerThread.quit();
    galleryWorkerThread.wait();
}
