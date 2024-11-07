#ifndef TASK_H
#define TASK_H

#include <QObject>

class Task: public QObject
{
    Q_OBJECT
public:
    explicit Task(QObject *parent = nullptr);
//    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
//    Q_PROPERTY(QDate date READ date WRITE setDate NOTIFY dateChanged)
//    Q_PROPERTY(QString desc READ desc WRITE setDesc NOTIFY descChanged)
//    Q_PROPERTY(QString id READ id)
public slots:
    Q_INVOKABLE void setName(QString _name) {name = _name;}
    Q_INVOKABLE QString getName() {return name;}
    Q_INVOKABLE void setDate(QString _date) {date = _date;}
    Q_INVOKABLE QString getDate() {return date;}
    Q_INVOKABLE void setDesc(QString _desc) {desc = _desc;}
    Q_INVOKABLE QString getDesc() {return desc;}
    Q_INVOKABLE void setID(QString _id) {id = _id;}
    Q_INVOKABLE QString getID() {return id;}

//    QString name() {return name;};
//    QDate date();
//    QString desc();
//    void setName(QString _name);
//    void setDate(QString _date);
//    void setDesc(QString _desc);
private:
    QString id;
    QString name;
    QString date;
    QString desc;
};

#endif // TASK_H
