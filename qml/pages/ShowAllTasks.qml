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
        selectRows()
        if (empty) {empty_layout.visible = true}
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


    property var taskModel: ListModel {
//        ListElement {
//            date: "01.01.2023"
//            name: "Example1"
//            desc: "example1"
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
    function updateRow(id) {
        db.transaction(function (tx) {
                tx.executeSql("UPDATE FROM " + _table + " WHERE rowid=" + parseInt(id));
            }
        );
        updateRows()
    }
    function deleteTask(bid, bindex, bname) {
        taskModel.remove(bindex)
        console.log("DELETED:", bid, "name", bname)
        deleteRow(bid)
    }
    function updateTask(bid, bindex, bname) {
        console.log("UPDATED:", bid, "name", bname)
        deleteRow(bid)
    }

    function selectRows(search, mode) {
        db.transaction(function (tx) {
                console.log("search:", search, "mode", mode)
                var rs = tx.executeSql("SELECT rowid, * FROM " + _table);
                var data = [];
                var ind = 0;
                for (var i = 0; i < rs.rows.length; i++) {
                    modell.id = rs.rows.item(i).rowid;
                    modell.date = rs.rows.item(i).date;
                    modell.name = rs.rows.item(i).name;
                    modell.desc = rs.rows.item(i).desc;
                    task.setID(modell.id);
                    task.setName(modell.name);
                    task.setDate(modell.date);
                    task.setDesc(modell.desc);
                    if (true) {

                        taskModel.append({"id": task.getID(),
                                          "date": task.getDate(),
                                          "name": task.getName(),
                                          "desc": task.getDesc(),
                                          "index": ind})


                        ind++;
                        console.log("SELECT: " + task.getName())
                        data.push({"id": task.getID(),
                                      "date": task.getDate(),
                                      "name": task.getName(),
                                      "desc": task.getDesc(),
                                      "index": ind});
                    }
                }
                if (data.length == 0) {
                    console.log("data:", data)
                    empty = true
                } else {
                    console.log("data: hear")
                    page.empty = false;
                    empty_layout.visible = false;
                }
            });
    }

    function initializeDatabase() {
        var dbase = LocalStorage.openDatabaseSync("Tasks", "1.0", "Tasks
                Database", 1000000)
        dbase.transaction(function(tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS " + _table + "(date TEXT, name TEXT, desc TEXT)");
            console.log("Table connected!")
        })
        db = dbase
    }

    function init(search_flag){
        console.log("init")
        initializeDatabase()
        selectRows()
        if (empty) {empty_layout.visible = true}
        if (search_flag === 1) {search.visible = true; search.focus = true}
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
                onClicked: pageStack.push(Qt.resolvedUrl("AddEventPage.qml"))
            }
        ]
    }
    Column {
        id: searchlayout
        anchors.top: pageHeader.bottom
//        spacing: Theme.paddingMedium
        TextField {
            id: search
            visible: false
//            background: Rectangle {
//                width: search.width
//                height: search.height
//                radius: 20
//                color: "grey"

//            }

            color: "white"
            backgroundStyle: TextEditor.FilledBackground//NoBackground
            placeholderColor: "#5c5c5c"
            cursorColor: "red"
            placeholderText: qsTr("Поиск")
            onTextChanged: {
                if (search.text != "") {
                    taskModel.clear()
                    selectRows(search.text)
                } else {console.log("no search")}
            }
        }
        ComboBox {
            width: page.width
            anchors.centerIn: rec_space
            highlightedColor: "red"
            _backgroundRadius: 10

            descriptionColor: "white"
            description: "Сортировать"
            valueColor: "white"
            menu: ContextMenu {
                MenuItem {
                    text: qsTr("По дате")
                    color: "white"
                    onClicked: {}
                }
                MenuItem {
                    text: qsTr("По названию")
                    color: "white"
                    onClicked: {}
                }
            }
        }
//        Rectangle {
//            border.width: 2
//            border.color: "#303030"
//            width: page.width
//            height: 2
//        }
    }
    Rectangle {
        id: rec_space
        anchors.top: searchlayout.bottom
        height: Theme.paddingLarge
        width: parent.width
        color: "#0d0d0d"//"#141414"
    }
    Rectangle {
        id: mmenu
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
                contentHeight: mmenu.height
                model: taskModel
//                headerItem: Item{
//                    Rectangle {
//                        height: 1
//                        width: 1
//                        color: "transparent"
//                        Text {
//                            text: ""
//                        }
//                    }
//                }

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
                                    Text {
                                        text: Func.get_format_date(model.date)
                                        color: "grey"
                                        font.pixelSize: Theme.fontSizeLarge
                                    }
                                }

                                Button {
                                    id: btnDelete
                                    property int bindex: model.index
                                    property string bid: model.id
                                    property string bdate: model.date
                                    property string bname: model.name
                                    property string bdesc: model.desc
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

    }
//    Component.onCompleted: {
//        initializeDatabase()
//        console.log("-----------")
//        console.log("current_day.coorect_date: " + current_day.coorect_date)
//        selectRows(current_day.day.toString(), current_day.month.toString(), current_day.year.toString())
//        if (empty) {empty_layout.visible = true}
//    }
}
