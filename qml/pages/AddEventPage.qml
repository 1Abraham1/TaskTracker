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

     QtObject {
         id: model

         property int id: 0
         property string date: ""
         property string name: ""
         property string desc: ""
         property bool complete: false

         function fromJson(json) {
             try {
                 id = json['id'] === undefined ? 0 : parseInt(json['id']);
                 date = json['date'];
                 name = json['name'];
                 desc = json['desc'];
                 complete = json["complete"];
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
                 "desc": desc,
                 "complete": complete
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
                            verification(name.text, desc.text, date.text);
                        }

                        function verification(name_text, desc_text, date_text) {
                            if (desc_text === "" |
                                    date_text === "" |
                                    name_text === "" | !(Func.isValidDate(date_text))){
                                notification.previewBody = "!"
                                notification.previewSummary = qsTr("Введите данные корректно")
                            }
                            else {
                                addRow()
                                notification.previewBody = "!"
                                notification.previewSummary = qsTr("Успешно сохраненно")
                                desc.text = ""
                                date.text = ""
                                name.text = ""
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
                    text: current_day.date_form
                    backgroundStyle: TextEditor.FilledBackground//NoBackground
                    placeholderColor: "#5c5c5c"
                    cursorColor: "red"
                    placeholderText: qsTr("Дата выполнения")
                    EnterKey.iconSource: "image://theme/icon-m-enter-next"
                    EnterKey.onClicked: name.focus = true
                    onTextChanged: model.date = text
                    validator: RegExpValidator {regExp: /^(?:(?:31(\/|-|\.)(?:0?[13578]|1[02]))\1|(?:(?:29|30)(\/|-|\.)(?:0?[13-9]|1[0-2])\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})$|^(?:29(\/|-|\.)0?2\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:0?[1-9]|1\d|2[0-8])(\/|-|\.)(?:(?:0?[1-9])|(?:1[0-2]))\4(?:(?:1[6-9]|[2-9]\d)?\d{2})$/}
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
                    EnterKey.iconSource: "image://theme/icon-m-enter-next"
                    EnterKey.onClicked: desc.focus = true
                    onTextChanged: model.name = text
                    validator: RegExpValidator {regExp: /.*\\S.*/}
                }

                TextArea {
                    id: desc
                    focus: true
                    color: "white"
                    backgroundStyle: TextEditor.FilledBackground
                    placeholderColor: "#5c5c5c"
                    cursorColor: "red"
                    label: qsTr("Описание")
                    onTextChanged: {model.desc = text;desc.focus = true}
//                    EnterKey.onClicked: menu_save.verification(name.text, desc.text, date.text)

                    RegExpValidator {
                        id: rx
                        regExp: /^\\s*\\S[^]*/
                    }
                }
            }
         }
     }

     function addRow() {
         db.transaction(function (tx) {
             tx.executeSql(
                 "INSERT INTO " + _table + " VALUES(?, ?, ?, ?)",
                 [ model.date, model.name, model.desc, model.complete]
             )
             console.log("INSERT: " + model.name)
         })
     }

     function initializeDatabase() {
         var dbase = LocalStorage.openDatabaseSync("Tasks", "1.0", "Tasks
                 Database", 1000000)
         dbase.transaction(function(tx) {
             tx.executeSql("CREATE TABLE IF NOT EXISTS " + _table + "(date TEXT, name TEXT, desc TEXT, complete BOOL)");
             console.log("Table created!")
         })
         db = dbase;
     }
     Component.onCompleted: initializeDatabase()
}
