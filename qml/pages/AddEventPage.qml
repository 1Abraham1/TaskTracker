import QtQuick 2.0
import Sailfish.Silica 1.0
import "../../qml/pages/func.js" as Func
//import "../pages/DBTaskPage.qml"
import QtQuick.LocalStorage 2.0
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


     QtObject {
         id: current_day
         property string year: ""
         property string month: ""
         property string day: ""
         property string date_form: ""
     }

     function init(y, m, d){
         try {
             current_day.year = y
             current_day.month = m
             current_day.day = d
             current_day.date_form = d + "." + m + "." + y
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
//                title: qsTr("Событие")
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
                    Label {
                        id: succes
                        text: qsTr("Сохранено")

                        color: "green"
                        visible: false
                        font.pixelSize: Theme.fontSizeLargeBase
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right

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

//                Button {
//                    id: button
//                    text: "Выберите дату"

//                    onClicked: {
//                        var dialog = pageStack.push(pickerComponent, {
//                            date: new Date('2012/11/23')
//                        })
//                        dialog.accepted.connect(function() {
//                            button.text = "You chose: " + dialog.dateText
//                        })
//                    }

//                    Component {
//                        id: pickerComponent
//                        DatePickerDialog {}
//                    }
//                }

                TextField {
                    id: date
                    focus: true
                    color: "white"
                    text: current_day.date_form
                    backgroundStyle: TextEditor.FilledBackground//NoBackground
                    placeholderColor: "#5c5c5c"
                    cursorColor: "red"
//                    acceptableInput: text.length === 10
                    placeholderText: qsTrId("Дата начала")
                    EnterKey.iconSource: "image://theme/icon-m-enter-next"
                    EnterKey.onClicked: name.focus = true
                    onTextChanged: model.date = text
                    validator: RegExpValidator {regExp: /^(?:(?:31(\/|-|\.)(?:0?[13578]|1[02]))\1|(?:(?:29|30)(\/|-|\.)(?:0?[13-9]|1[0-2])\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})$|^(?:29(\/|-|\.)0?2\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:0?[1-9]|1\d|2[0-8])(\/|-|\.)(?:(?:0?[1-9])|(?:1[0-2]))\4(?:(?:1[6-9]|[2-9]\d)?\d{2})$/}
                }

                TextField {
                    id: name
                    focus: true
                    acceptableInput: text.length > 0
                    backgroundStyle: TextEditor.FilledBackground
                    placeholderColor: "#5c5c5c"
                    cursorColor: "red"
                    label: qsTrId("Название")
                    color: "white"
                    EnterKey.iconSource: "image://theme/icon-m-enter-next"
                    EnterKey.onClicked: desc.focus = true
                    onTextChanged: model.name = text
//                    validator: RegExpValidator {regExp: /^\\s*\\S[^]*/}
                    validator: RegExpValidator {regExp: /.*\\S.*/}
                }

                TextArea {
                    id: desc
                    focus: true
                    color: "white"
                    backgroundStyle: TextEditor.FilledBackground
                    placeholderColor: "#5c5c5c"
                    cursorColor: "red"
                    label: qsTrId("Описание")
                    onTextChanged: model.desc = text
                    RegExpValidator {
                        id: rx
                        regExp: /^\\s*\\S[^]*/
                    }

                }

                Button {
                    id: save
                    anchors.horizontalCenter: parent.horizontalCenter
//                    anchors.top: circle.bottom
                    backgroundColor: button_color
                    color: "white"
                    text: "Сохранить"
                    onClicked: {
                        if (desc.text == "" |
                                date.text == "" |
                                name.text == "" | !(Func.isValidDate(date.text))){
                            notification.previewBody = "!"
                            notification.previewSummary = qsTr("Введите данные корректно")
                        }
                        else {
                            addRow()
                            notification.previewBody = "!"
                            notification.previewSummary = qsTr("Успешно сохраненно")
                        }
                        notification.publish()
//                        succes.visible = true
                        desc.text = ""
                        date.text = ""
                        name.text = ""
                    }
                }
//                Button {
//                    id: show
//                    anchors.horizontalCenter: parent.horizontalCenter
////                    anchors.top: circle.bottom
//                    backgroundColor: button_color
//                    color: "white"
//                    text: "Показать"
//                    onClicked: selectRows()

//                }

                Label {
                    id: result1
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Label {
                    id: result2
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Label {
                    id: result3
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

         }
     }
     function addRow() {
         db.transaction(function (tx) {
             tx.executeSql(
                 "INSERT INTO " + _table + " VALUES(?, ?, ?)",
                 [ model.date, model.name, model.desc]
             )
             console.log("INSERT: " + model.name)
         })
     }
     function selectRows() {
         db.transaction(function (tx) {
                 var rs = tx.executeSql("SELECT rowid, * FROM " + _table);
                 var data = [];
                 for (var i = 0; i < rs.rows.length; i++) {
                     model.id = rs.rows.item(i).rowid;
                     model.date = rs.rows.item(i).date;
                     model.name = rs.rows.item(i).name;
                     model.desc = rs.rows.item(i).desc;
                     data.push(model.copy());
                     console.log("SELECT: " + model.name)
                 }
             });
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
         selectRows();
     }
     function initializeDatabase() {
         var dbase = LocalStorage.openDatabaseSync("Tasks", "1.0", "Tasks
                 Database", 1000000)
         dbase.transaction(function(tx) {
             tx.executeSql("CREATE TABLE IF NOT EXISTS " + _table + "(date TEXT, name TEXT, desc TEXT)");
             console.log("Table created!")
         })
         db = dbase
     }
     Component.onCompleted: initializeDatabase()
}
