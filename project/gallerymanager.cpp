#include "gallerymanager.h"
#include <QDir>
#include <QFileInfo>
#include <QFileInfoList>
#include <QDebug>
#include <QStandardPaths>

GalleryManager::GalleryManager(QObject* parent):QObject(parent)
{
#ifdef Q_OS_ANDROID
    this->galleryRootPath = "/mnt/sdcard";
#endif
#ifdef Q_OS_WIN
    this->galleryRootPath = QStandardPaths::standardLocations(QStandardPaths::PicturesLocation)[0];
    this->galleryRootPath = "E:/Images";
#endif
}

QString GalleryManager::getGalleryRootPath()
{
    return galleryRootPath;
}

void GalleryManager::scanPathAndCover(QString path, int maxDepth)
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
                QString coverString = fileInfo.filePath();
                pathAndCoverMap.insert(pathString, coverString);
                emit getOneDir(pathString, coverString);
            }
        }
        if(fileInfo.isDir())
        {
            depth++;
            if(maxDepth == 0)
            {
                scanPathAndCover(fileInfo.filePath(), maxDepth);
            }
            else
            {
                if(depth > maxDepth)
                {
                    depth--;
                }
                else
                {
                    scanPathAndCover(fileInfo.filePath(), maxDepth);
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

void GalleryManager::scanImageByPath(QString path)
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

        emit getOneImage(pathString, fileName);
    }
}
