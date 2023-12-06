#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QApplication>
#include <QQmlContext>
#include <QFontDatabase>
#include <QIcon>


int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv); //Here etc..
    app.setWindowIcon(QIcon(":/icons/win-icon.png"));

    //Update same font for all app
    int fontId = QFontDatabase::addApplicationFont(":/Fonts/GigaSans/GigaSans-Medium.ttf");

    if (fontId != -1) {
        QStringList fontFamilies = QFontDatabase::applicationFontFamilies(fontId);

        if (!fontFamilies.isEmpty()) {
            QString fontFamily = fontFamilies.at(0);

            // Установка шрифта для приложения
            QFont appFont(fontFamily);
            app.setFont(appFont);
        }
    }

    //qmlRegisterType<dispatcher>("WinHeater", 1, 0, "disp");

    QQmlApplicationEngine engine;

    QQmlContext *context = engine.rootContext();

    const QUrl url(u"qrc:/qml/main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
