#include <auroraapp.h>
#include <QtQuick>

#include "task.h"

int main(int argc, char *argv[])
{
    qmlRegisterType<Task>("Module.Task", 1, 0, "Task");
    QScopedPointer<QGuiApplication> application(Aurora::Application::application(argc, argv));
    application->setOrganizationName(QStringLiteral("ru.template"));
    application->setApplicationName(QStringLiteral("TaskTracker"));

    QScopedPointer<QQuickView> view(Aurora::Application::createView());
    view->setSource(Aurora::Application::pathTo(QStringLiteral("qml/TaskTracker.qml")));
    view->show();

    return application->exec();
}
