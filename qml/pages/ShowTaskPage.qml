import QtQuick 2.0
import Sailfish.Silica 1.0
//import "../pages/DBTaskPage.qml"
import QtQuick.LocalStorage 2.0
import Module.Task 1.0

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
         id: taskmodel

         property int id: 0
         property string date: ""
         property string name: ""
         property string desc: ""
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

         } catch (e) {
             console.log("ERROR")
         }
     }
//     property int pageCount: pageStack.depth
//     onPageCountChanged: {
//         model.date = task.getDate()
//         model.name = task.getName()
//         model.desc = task.getDesc()
//         model.id = task.getID()
//         console.log()
//     }

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

                TextField {
                    id: date
                    focus: true
//                    textMargin: 2*Theme.paddingLarge
                    color: "white"
                    text: model.date
                    backgroundStyle: TextEditor.FilledBackground//NoBackground
//                    background: back_textfield
                    placeholderColor: "#5c5c5c"
                    cursorColor: "red"
                    acceptableInput: text.length === 10
//                    label: qsTrId("Дата начала")
                    placeholderText: qsTrId("Дата начала")
                    EnterKey.iconSource: "image://theme/icon-m-enter-next"
                    EnterKey.onClicked: height.focus = true
                    Component.onCompleted: {

                    }
                    onTextChanged: model.date = text


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
                    label: qsTrId("Описание")
                    onTextChanged: model.desc = text
                }

                Button {
                    id: save
                    anchors.horizontalCenter: parent.horizontalCenter
//                    anchors.top: circle.bottom
                    backgroundColor: button_color
                    color: "white"
                    text: "Сохранить"
                    onClicked: {
                        var data = {
                            "id": model.id,
                            "name": model.name,
                            "date": model.date,
                            "desc": model.desc};
                        updateRow(data);
                        succes.visible = true;
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
//         selectRows();
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
