import QtQuick 2.0
import Sailfish.Silica 1.0
import "../../qml/pages/func.js" as Func
import QtQuick.LocalStorage 2.0
import Module.Task 1.0

Page {
    id: page
    backgroundColor: "#141414"
    property string text_color: "#e30000"
    property string button_color: "#800000"
    objectName: "mainPage"
    allowedOrientations: Orientation.All
    property bool empty: false
    property var db
    property string _table: "Tasks"
    property double koaff: 0.66
    property int pageCount: pageStack.depth
    onPageCountChanged: {
        updateRows()
    }
    function updateRows() {
        taskModel.clear()
        selectRows(current_day.day.toString(), current_day.month.toString(), current_day.year.toString())
        if (empty) {empty_layout.visible = true; progress_layout.visible = false}
    }
    Task {
        id: task
    }
    QtObject {
        id: modell

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
                complete = json["complete"]
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


    property var taskModel: ListModel {
//        ListElement {
//            date: "01.01.2023"
//            name: "Example1"
//            desc: "example1"
//            ststus: true
//        }
//        ListElement {
//            date: "02.02.2023"
//            name: "Example2"
//            desc: "example2"
//        }
//        ListElement {...}
    }

    function deleteRow(id) {
        db.transaction(function (tx) {
                tx.executeSql("DELETE FROM " + _table + " WHERE rowid=" + parseInt(id));
            }
        );
        updateRows()
    }
    function deleteTask(bid, bindex, bname) {
        taskModel.remove(bindex)
        console.log("DELETED:", bid, "name", bname)
        deleteRow(bid)
    }
    function updateComplete(id, complete, name){
        db.transaction(function (tx) {
            tx.executeSql(
                "UPDATE " + _table + " SET complete=? WHERE rowid=?",
                [complete, id]
            );
            console.log("CHANGE STATUS:", name, complete)
        }

        );
    }
    function selectRows(d, m, y) {
        var date_form = Func.get_correct_date(d, m, y)

        db.transaction(function (tx) {
                var rs = tx.executeSql("SELECT rowid, * FROM " + _table);
                var data = [];
                var ind = 0;
                var complete_task = 0;
                for (var i = 0; i < rs.rows.length; i++) {
                    modell.id = rs.rows.item(i).rowid;
                    modell.date = rs.rows.item(i).date;
                    modell.name = rs.rows.item(i).name;
                    modell.desc = rs.rows.item(i).desc;
                    modell.complete = rs.rows.item(i).complete;
                    task.setID(modell.id);
                    task.setName(modell.name);
                    task.setDate(modell.date);
                    task.setDesc(modell.desc);
                    task.setComplete(modell.complete);

                    var dmy = task.getDate().split(".");
                    var insert_date = Func.get_correct_date(dmy[0], dmy[1], dmy[2]);
                    if (date_form === insert_date) {
                        taskModel.append({"id": task.getID(), "date": task.getDate(), "name": task.getName(), "desc": task.getDesc(), "complete": task.getComplete(), "index": ind})
                        ind++;
                        console.log("SELECT: " + task.getName())
                        data.push(modell.copy());
                        if (task.getComplete()) {complete_task++}
                    }

                }
                progress_bar.value = (complete_task/ind)*100;
                if (data.length == 0) {
                    console.log("data:", data)
                    empty = true
                } else {
                    console.log("data: hear")
                    page.empty = false;
                    empty_layout.visible = false;
                    progress_layout.visible = true;
                }
            });
    }
    function updateProgress(d, m, y) {
        var date_form = Func.get_correct_date(d, m, y)

        db.transaction(function (tx) {
                var rs = tx.executeSql("SELECT rowid, * FROM " + _table);
                var data = [];
                var ind = 0;
                var complete_task = 0;
                for (var i = 0; i < rs.rows.length; i++) {
                    modell.date = rs.rows.item(i).date;
                    modell.complete = rs.rows.item(i).complete;
                    task.setDate(modell.date);
                    task.setComplete(modell.complete);

                    var dmy = task.getDate().split(".");
                    var insert_date = Func.get_correct_date(dmy[0], dmy[1], dmy[2]);
                    if (date_form === insert_date) {
                        ind++;
                        if (task.getComplete()) {complete_task++}
                    }

                }
                progress_bar.value = (complete_task/ind)*100;

            });
    }

    property string coorect_date: "ERR"
    QtObject {
        id: current_day
        property string year: ""
        property string month: ""
        property string day: ""
        property string format: ""
        property string coorect_date: ""
        property string day_week: ""
    }

    function initializeDatabase() {
        var dbase = LocalStorage.openDatabaseSync("Tasks", "1.0", "Tasks
                Database", 1000000)
        dbase.transaction(function(tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS " + _table + "(date TEXT, name TEXT, desc TEXT, complete BOOL)");
            console.log("Table connected!")
        })
        db = dbase
    }

    function init(y, m, d, form){
//        console.log("current_day.coorect_date: " +  Func.get_correct_date(d, m, y))
//        current_day.coorect_date = Func.get_correct_date(d, m, y)
        page.coorect_date = Func.get_correct_date(d, m, y)
        current_day.year = y
        current_day.month = m
        current_day.day = d
        current_day.day_week = Func.get_day_week(form)
        current_day.format = current_day.day_week + " " + d +
                " " + Func.get_correct_month(m) + " " + y + qsTr("г.")

        initializeDatabase()
        selectRows(current_day.day.toString(), current_day.month.toString(), current_day.year.toString())
        if (empty) {empty_layout.visible = true; progress_layout.visible = false}
    }

    PageHeader {
        id: pageHeader
        objectName: "pageHeader"
//        title: qsTr("Template")
        titleColor: text_color
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
            Button {
                width: 250
                height: 50
                backgroundColor: "transparent"
                color: "white"
                text: qsTr("Новая задача")
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                onClicked: {
                    var page = pageStack.push(Qt.resolvedUrl("AddEventPage.qml"))
                    page.init(current_day.year, current_day.month, current_day.day)
                }
            }
        ]
    }
    Column {
        id: daylayout
        anchors.top: pageHeader.bottom
        Label {
            font.pixelSize: Theme.fontSizeMediumBase
            text: current_day.format
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Rectangle {
            border.width: 2
            border.color: "#303030"
            width: page.width
            height: 2
        }
    }
    Rectangle {
        id: rec_space
        anchors.top: daylayout.bottom
        height: Theme.paddingLarge
        width: parent.width
        color: "#0d0d0d"//"#141414"
    }
    Rectangle {
        id: menu
        color: '#0d0d0d'
        anchors.top: rec_space.bottom
        width: page.width
        height: page.height - pageHeader.height

        SilicaFlickable {
            id: flickable
            clip: true
            anchors.fill: parent
//            contentHeight: empty_layout.height + noteListView.height + Theme.paddingLarge

            ListView {
                id: noteListView
                width: parent.width
                height: page.height
                spacing: 30
                contentHeight: menu.height
                model: taskModel

                delegate: MouseArea {
                    id: mouseArea
                    property string mid: model.id
                    property string mdate: model.date
                    property string mname: model.name
                    property string mdesc: model.desc
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: 250
                    width: page.width - 100

                    onClicked: {
                        var page = pageStack.push(Qt.resolvedUrl("ShowTaskPage.qml"))
                        page.init(mid, mname, mdate, mdesc)
                    }
                    Rectangle {
                        anchors.fill: parent
                        anchors.horizontalCenter: parent.horizontalCenter
                        radius: 20
                        color: mouseArea.pressed ? "#262626": "#141414"
                        Rectangle {
                            id: recc
                            height: parent.height - 50
                            width: parent.width - 100
                            anchors.centerIn: parent
                            color: "transparent"
                            Row {
                                spacing: 0

                                Column {
                                    spacing: Theme.paddingLarge
                                    Text {
                                        text: model.name
                                        color: "white"
                                        elide: Text.ElideRight
                                        maximumLineCount: 1
                                        width: page.koaff*page.width
                                        font.pixelSize: Theme.fontSizeExtraLarge
                                    }
                                    Text {
                                        text: model.desc
                                        color: "grey"
                                        elide: Text.ElideRight
                                        maximumLineCount: 1
                                        width: page.koaff*page.width
                                        font.pixelSize: Theme.fontSizeLarge
                                    }
                                    Row {
                                        spacing: Theme.paddingLarge*5
                                        Text {
                                            text: Func.get_format_date(model.date)
                                            color: "grey"
                                            font.pixelSize: Theme.fontSizeLarge
                                        }
                                    }


                                }
                                Column {
                                    spacing: Theme.paddingLarge*3.4

                                Button {
                                    id: btnDelete
                                    property int bindex: model.index
                                    property string bid: model.id
                                    property string bdate: model.date
                                    property string bname: model.name
                                    property string bdesc: model.desc
                                    property string bcomplete: model.complete
                                    height: 50
                                    width: 80
                                    icon {
//                                            source: Qt.resolvedUrl("../icons/TaskTracker.svg")
                                        source: Qt.resolvedUrl("../icons/delete_icon.png")
                                        sourceSize { width: icon.width; height: icon.height }
//                                        color: "transparent"
                                        height: 50
                                        width: 50
                                    }
//                                        text: qsTr("Удалить")
                                    color: "white"
                                    backgroundColor: button_color
                                    onClicked: {
                                        deleteTask(bid, bindex, bname);
//                                        var dial = pageStack.push(del_dialog)
//                                        dial.accepted.connect(function() {
//                                            deleteTask(bid, bindex, bname);
//                                            console.log("dialog.accepted:")
//                                        })
                                    }
//                                    onClicked: {
//                                        var dialog = pageStack.push(Qt.resolvedUrl("DeleteDialog.qml"));
//                                        dialog.accepted.connect(function() {
//                                            deleteTask(bid, bindex, bname)
//                                            console.log("dialog.accepted.connect: Delete")
//                                        });
//                                    }

//                                    Component {
//                                        id: del_dialog
//                                        Dialog {
//                                            DialogHeader {
//                                                id: header
//                                                title: "Подтверждение удаления"
//                                            }
////                                            canAccept: true
//                                            Label {
//                                                text: canAccept//"Удалить задачу?"
//                                                anchors.top: header.bottom
//                                                x: Theme.horizontalPageMargin
//                                                color: Theme.highlightColor
//                                            }
//                                            onAccepted: {
//                                                console.log('DialogResult.Accepted')
//                                            }
//                                        }
//                                    }
                                }
//                                TextArea{
//                                    width: 120
//                                    height: 100

//                                    id: complete_switch_text
//                                    text: "не выполн."
//                                    color: "grey"
//                                    font.pixelSize: Theme.fontSizeExtraSmall
//                                }
                                TextSwitch {
                                    id: complete_switch
                                    checked: model.complete
                                    leftMargin: 25
                                    onCheckedChanged: {
                                        updateComplete(btnDelete.bid, checked, btnDelete.bname);
                                        updateProgress(current_day.day.toString(), current_day.month.toString(), current_day.year.toString())
                                    }
                                }


//                                Text{
//                                    width: 80

//                                    id: complete_switch_text
//                                    text: "не выполненно"
//                                    color: "grey"
//                                    font.pixelSize: Theme.fontSizeExtraSmall
//                                }
                                }

                            }
                        }
                    }
                }
            }

            Column {
                id: empty_layout
                visible: false
                width: page.width
                spacing: Theme.paddingLarge
//                Rectangle {
//                    height: 1
//                    width: 1
//                    color: "transparent"
//                    Text {
//                        text: ""
//                    }
//                }

                Rectangle {
                    height: 250
                    width: page.width - 100
                    anchors.margins: 50
                    anchors.horizontalCenter: parent.horizontalCenter
                    radius: 20
                    color: "#141414"
                    Rectangle {
                        height: parent.height - 50
                        width: parent.width - 100
                        anchors.centerIn: parent
                        color: "transparent"
                        Text {
                            text: "Нет задач"
                            color: "white"
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: Theme.fontSizeLarge
                        }
                    }
                }
            }
            VerticalScrollDecorator { }
        }
        Rectangle {
            id: progress_layout

            width: page.width
            color: "#820101"
            height: Theme.paddingLarge*10
            anchors.bottom: flickable.bottom
            ProgressBar {
                id: progress_bar
                anchors.centerIn: parent
                anchors.top: parent.top
                width: parent.width
                height: Theme.paddingLarge*9
                minimumValue: 0
                maximumValue: 100
                value: 50
                label: qsTr("Выполнено на")
                valueText: value + "%"
            }
        }



//        ProgressBar {
//            anchors.bottom: flickable.bottom
//            width: parent.width
//            minimumValue: 0
//            maximumValue: 100
//            value: 50
//            label: qsTr("Выполнено на")
//            valueText: value + "%"
//        }

    }
}
