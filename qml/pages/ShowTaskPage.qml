import QtQuick 2.0
import Sailfish.Silica 1.0
import "../../qml/pages/func.js" as Func
//import "../pages/DBTaskPage.qml"
import QtQuick.LocalStorage 2.0
import Module.Task 1.0
import Nemo.Notifications 1.0

Page {
     id: page
     backgroundColor: "#141414"
     property string text_color: "#e30000"
     property string button_color: "#800000"
     property var db

     property string _table: "Tasks"
//     DBTaskPage {
//         id: main_db
//     }

     QtObject {
         id: current_day
         property int year: 0
         property int month: 0
         property int day: 0
         property string form: ""
     }

     QtObject {
         id: model

         property int id: 0
         property string date: ""
         property string name: ""
         property string desc: ""

         function fromJson(json) {
             try {
                 id = json['id'] === undefined ? 0 : parseInt(json['id']);
                 date = json['date'];
                 name = json['name'];
                 desc = json['desc'];
             } catch (e) {
                 return false;
             }
             return true;
         }

         function copy() {
             return {
                 "id": id,
                 "date": date,
                 "name": name,
                 "desc": desc
             };
         }
     }

     Notification {
         id: notification
     }

     Task {
         id: task
     }

     function init(_id, _name, _date, _desc){
         try {
             task.setID(_id);
             task.setName(_name);
             task.setDate(_date);
             task.setDesc(_desc);
             model.date = task.getDate()
             model.name = task.getName()
             model.desc = task.getDesc()
             model.id = task.getID()

             var json_dmy = Func.get_d_m_y(task.getDate())
             current_day.year = json_dmy.year
             current_day.month = json_dmy.month
             current_day.day = json_dmy.day
             current_day.form = _date

             datePicker.date = new Date(json_dmy.year, json_dmy.month, json_dmy.day, 0, 0)

         } catch (e) {
             console.log("ERROR")
         }
     }

     SilicaListView {
        anchors.fill: parent

        header: Column {
            width: parent.width
            height: header.height + mainColumn.height + Theme.paddingLarge

            PageHeader {
                id: header
                titleColor: "white"
                extraContent.children: [
                    Button {
                        width: 120
                        height: 50
                        backgroundColor: "transparent"
                        color: text_color
                        text: qsTr("назад")
                        onClicked: pageStack.pop()
                        anchors.verticalCenter: parent.verticalCenter
                    },
                    Text {
                        text: qsTr("Задача")
                        color: "white"
                        font.pixelSize: Theme.fontSizeLargeBase
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    },
                    Button {
                        id: menu_save
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        backgroundColor: "#292929"
                        width: Theme.buttonWidthExtraSmall - Theme.paddingLarge

                        color: "white"
                        text: qsTr("Сохранить")
                        onClicked: {
                            var data = {
                                "id": model.id,
                                "name": model.name,
                                "date": model.date,
                                "desc": model.desc};
                            verification(name.text, desc.text, date.text, data);
                        }

                        function verification(name_text, desc_text, date_text, data) {
                            if (desc.text == "" |
                                    date.text == "" |
                                    name.text == "" | !(Func.isValidDate(date.text))){
                                notification.previewBody = "!"
                                notification.previewSummary = qsTr("Введите данные корректно")
                            }
                            else {
                                updateRow(data);
                                notification.previewBody = "!"
                                notification.previewSummary = qsTr("Успешно сохранено")
                                pageStack.pop()
                            }
                            notification.publish()
                        }
                    }

                ]
            }

            Component {
                id: back_textfield
                Rectangle {
                    height: 80
                    width: page.width - 40
                    color: "#212121"
                    radius: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                }
            }

            Column {
                id: mainColumn
                width: parent.width
                spacing: Theme.paddingLarge

                TextField {
                    id: date
                    focus: true
                    color: "white"
                    text: model.date
                    backgroundStyle: TextEditor.FilledBackground//NoBackground
                    placeholderColor: "#5c5c5c"
                    cursorColor: "red"
                    acceptableInput: text.length === 10
                    placeholderText: qsTr("Дата выполнения")
                    EnterKey.iconSource: "image://theme/icon-m-enter-next"
                    EnterKey.onClicked: height.focus = true
                    Component.onCompleted: {

                    }
                    onTextChanged: model.date = text
                }
                Column {
                    spacing: Theme.paddingLarge
                    Label {
                        text: Func.get_month(datePicker.month) + " " + datePicker.year
                        color: "white"
                        font.pixelSize: Theme.fontSizeExtraLargeBase
                        leftPadding: 20
                    }
                    DatePicker {
                        id: datePicker

                        monthYearVisible: false
                        daysVisible: true
                        weeksVisible: false
                        _weekColumnVisible: false

                        function getModelData(dateObject, primaryMonth) {
                            var y = dateObject.getFullYear()
                            var m = dateObject.getMonth() + 1
                            var d = dateObject.getDate()
                            var data = {'year': y, 'month': m, 'day': d,
                                        'primaryMonth': primaryMonth,
                                        'holiday': (m === 1 && d === 1) || (m === 12 && (d === 25 || d === 26))}
                            return data
                        }

                        modelComponent: Component {
                            ListModel { }
                        }

                        onUpdateModel: {
                            var i = 0
                            var dateObject = new Date(fromDate)
                            while (dateObject < toDate) {
                                if (i < modelObject.count) {
                                    modelObject.set(i, getModelData(dateObject, primaryMonth))
                                } else {
                                    modelObject.append(getModelData(dateObject, primaryMonth))
                                }
                                dateObject.setDate(dateObject.getDate() + 1)
                                i++
                            }
                        }
                        delegate: MouseArea {
                            id: delegat
                            width: datePicker.cellWidth
                            height: datePicker.cellHeight

                            onClicked: {
                                datePicker.date = new Date(year, month-1, day, 12, 0, 0)
                                date.text = Func.get_correct_date(day, month, year)
                            }
                            Label {
                                id: dd
                                anchors.centerIn: parent
                                text: day
                                color: month === primaryMonth ? (isToday()? "#e0e0e0" : "#ff0000"): "#800000"
                                function isToday(){
                                    var date_now = new Date();
                                    return (year === date_now.getFullYear() &
                                            month - 1 === date_now.getMonth() &
                                            day === date_now.getDate())
                                }
                                font.bold: isToday()
                                font.pixelSize: !isToday()? Theme.fontSizeMedium : Theme.fontSizeLarge
                            }
                        }
                    }
                }

                TextField {
                    id: name
                    focus: true
                    acceptableInput: text.length > 0
                    backgroundStyle: TextEditor.FilledBackground
                    placeholderColor: "#5c5c5c"
                    cursorColor: "red"
                    label: qsTr("Название")
                    color: "white"
                    text: model.name
                    EnterKey.iconSource: "image://theme/icon-m-enter-next"
                    EnterKey.onClicked: circle.focus = true
//                    leftItem: Icon {
//                        source: "image://theme/icon-m-mail"
//                    }
                    onTextChanged: model.name = text
                }

                TextArea {
                    id: desc
                    focus: true
                    color: "white"
                    text: model.desc
                    backgroundStyle: TextEditor.FilledBackground
                    placeholderColor: "#5c5c5c"
                    cursorColor: "red"
                    label: qsTr("Описание")
                    onTextChanged: model.desc = text
                }
            }
         }
     }

     function updateRow(data) {
         db.transaction(function (tx) {
                 if (model.fromJson(data)) {
                     if (model.id === 0) {
                         tx.executeSql(
                             "INSERT INTO " + _table + " VALUES(?, ?, ?)",
                             [ model.date, model.name, model.desc]
                         );
                     } else {
                         tx.executeSql(
                             "UPDATE " + _table + " SET date=?, name=?, desc=? WHERE rowid=?",
                             [ model.date, model.name, model.desc, model.id]
                         );
                     }
                     console.log("UPDATE: " + model.name)
                 }
             }
         );
     }

     function initializeDatabase() {
         var dbase = LocalStorage.openDatabaseSync("Tasks", "1.0", "Tasks
                 Database", 1000000)
         dbase.transaction(function(tx) {
             tx.executeSql("CREATE TABLE IF NOT EXISTS " + _table + "(date TEXT, name TEXT, desc TEXT, complete BOOL)");
             console.log("Table created!")
         })
         db = dbase
     }
     Component.onCompleted: initializeDatabase()
}
