#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "gallerymanager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    qmlRegisterType<GalleryManager>("DjangoX.Gallery", 1, 0, "GalleryManager");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
