import QtQuick 2.0
import Sailfish.Silica 1.0
import "../../qml/pages/func.js" as Func
import QtQuick.LocalStorage 2.0
//import "../pages/DBTaskPage.qml"

Page {
    id: page
    backgroundColor: "#141414"
    objectName: "mainPage"
    allowedOrientations: Orientation.All
    property var db
    property var tasks
    property string _table: "Tasks"

    QtObject {
        id: model
        objectName: "TaskModel"

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

    function initializeDatabase() {
        var dbase = LocalStorage.openDatabaseSync("Tasks", "1.0", "Tasks
                Database", 1000000)
        dbase.transaction(function(tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS " + _table + "(date TEXT, name TEXT, desc TEXT)");
            console.log("Table created!")
        })
        db = dbase
    }
    Component.onCompleted: {
        initializeDatabase()
        selectRows()
    }

    property var noteModel: ListModel {
//        ListElement {  }
//        ListElement {  }
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
                if (data) {
                    tasks = data
                }

            });
    }
    function checkDate(d, m, y) {
        var ddate = Func.get_correct_date(d, m, y);
//        console.log("function checkDate: " + ddate)
        var f = false;
        db.transaction(function (tx) {
                var rs = tx.executeSql("SELECT rowid, * FROM " + _table);
                var data = [];
                for (var i = 0; i < rs.rows.length; i++) {
                    model.id = rs.rows.item(i).rowid;
                    model.date = rs.rows.item(i).date;
                    model.name = rs.rows.item(i).name;
                    model.desc = rs.rows.item(i).desc;
                    data.push(model.copy());
                    var dmy = model.date.split(".");
                    var insert_date = Func.get_correct_date(dmy[0], dmy[1], dmy[2]);
                    if (insert_date === ddate) {
                        console.log("CHECK: " + model.name)
                        f = true
                    }
                }
            });
        return f
    }

//    function init(){
//        console.log("main init")
//        initializeDatabase()
//    }

    PageHeader {
        id: pageHeader
        objectName: "pageHeader"
        title: qsTr("Template")
        titleColor: "#e30000"
        extraContent.children: [
            IconButton {
                id: aboutButton
                objectName: "aboutButton"
                icon.source: "image://theme/icon-m-about"
                anchors.verticalCenter: parent.verticalCenter

                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            },
            Button {
                objectName: "add_event_button"
                backgroundColor: "transparent"
                color: "#e30000"
                anchors.left: aboutButton.right
                width: 50

                Text {
                    text: "+"
                    color: "#e30000"
                    font.pixelSize: Theme.fontSizeExtraLarge
                    anchors.centerIn: parent
                }
                anchors.verticalCenter: parent.verticalCenter
                onClicked: pageStack.push(Qt.resolvedUrl("AddEventPage.qml"))
            }
        ]
    }
    Row {
        id: dayweeks
        anchors.top: pageHeader.bottom
        height: 50
        Rectangle {
            color: "transparent"
            height: 40
            width: datePicker.cellWidth
            Text {
                text: qsTr("пн")
                anchors.horizontalCenter: parent.horizontalCenter
//                            anchors.verticalCenter: parent.verticalCenter
                anchors.bottom: parent.bottom
                color: "#525252"
            }
        }
        Rectangle {
            color: "transparent"
            height: 40
            width: datePicker.cellWidth
            Text {
                text: qsTr("вт")
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                color: "#525252"
            }
        }
        Rectangle {
            color: "transparent"
            height: 40
            width: datePicker.cellWidth
            Text {
                text: qsTr("ср")
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                color: "#525252"
            }
        }
        Rectangle {
            color: 'transparent'
            height: 40
            width: datePicker.cellWidth
            Text {
                text: qsTr("чт")
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                color: "#525252"
            }
        }
        Rectangle {
            color: "transparent"
            height: 40
            width: datePicker.cellWidth
            Text {
                text: qsTr("пт")
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                color: "#525252"
            }
        }
        Rectangle {
            color: "transparent"
            height: 40
            width: datePicker.cellWidth
            Text {
                text: qsTr("сб")
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                color: "#525252"
            }
        }
        Rectangle {
            color: "transparent"
            height: 40
            width: datePicker.cellWidth
            Text {
                text: qsTr("вс")
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                color: "#525252"
            }
        }
    }
    Rectangle {
        color: '#0d0d0d'
        anchors.top: dayweeks.bottom
        width: page.width
        height: page.height - pageHeader.height

        SilicaFlickable {
            id: flickable
            clip: true
            anchors.fill: parent
            contentHeight: layout.height + panels.height + pageHeader.height + Theme.paddingLarge

            PullDownMenu {
                id: pulldownmenu
                backgroundColor: "red"
                highlightColor: backgroundColor
                MenuItem {
                    text: qsTr("Поиск")
                    color: "white"
                    onClicked: {
                        var page = pageStack.push(Qt.resolvedUrl("ShowAllTasks.qml"));
                        page.init(1)
                    }
                }
                MenuItem {
                    text: qsTr("Новая задача")
                    color: "white"
                    onClicked: pageStack.push(Qt.resolvedUrl("AddEventPage.qml"))
                }
                MenuItem {
                    text: qsTr("Все задачи")
                    color: "white"
                    onClicked: {
                        var page = pageStack.push(Qt.resolvedUrl("ShowAllTasks.qml"));
                        page.init()
                    }
                }
                MenuLabel {
                    color: "#bfbfbf"
                    text: qsTr("Меню")
                }
            }

            Column {
                id: layout
                objectName: "layout"
                width: page.width
                spacing: Theme.paddingLarge
                anchors.top: pulldownmenu.bottom

//                Button {
//                    objectName: "graphiceditorButton"
//                    anchors.horizontalCenter: parent.horizontalCenter
//                    text: "Открыть редактор"
//                    onClicked: pageStack.push(Qt.resolvedUrl("GraphicEditorPage.qml"))
//                }

                ListView {
                    objectName: "flickable2"
                    contentWidth: page.width

                    contentHeight: panels.height + Theme.paddingLarge

                    Column {
                        id: panels
                        spacing: 50

                        Column {
//                            Component.onCompleted: {
//                                datePicker.date = new Date(202, primaryMonth, 12, 0, 0)
//                            }
                            Label {
                                text: Func.get_month(datePicker.month) + " " + datePicker.year
                                color: "white"
        //                        anchors.bottom: datePicker
                                font.pixelSize: Theme.fontSizeExtraLargeBase
                                leftPadding: 20
                            }
                            DatePicker {
                                id: datePicker
                //                ColorPickerPage: ""

                                monthYearVisible: false
                                daysVisible: false
                                weeksVisible: false
                                _weekColumnVisible: false
                                Component.onCompleted: {
                                    console.log("primaryMonth: ", datePicker.month)
                                }

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
                                    width: datePicker.cellWidth
                                    height: datePicker.cellHeight

                                    onClicked: {
                                        datePicker.date = new Date(year, month-1, day, 12, 0, 0)
                                        var page = pageStack.push(Qt.resolvedUrl("DayPage.qml"))
//                                        console.log()
                                        page.init(datePicker.year, datePicker.month, datePicker.day, datePicker.date.toString())
//                                        page.init(datePicker.year.toString(), datePicker.month.toString(), datePicker.day.toString(), datePicker.date.toString())
    //                                    Func.func()
                                    }
                                    Label {
                                        id: dd
                                        anchors.centerIn: parent
                                        text: day
                                        color: month === primaryMonth ? "#ff0000" : "#800000"
                //                        font.bold: holiday
                                        font.pixelSize: !holiday? Theme.fontSizeMedium : Theme.fontSizeExtraSmall
                                    }
                                    Label {
                                        id: mark
                                        anchors.top: dd.bottom
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "*"
                                        font.pixelSize: Theme.fontSizeExtraLarge
                                        visible: false
                                        property int cnt: pageStack.depth
                                        onCntChanged: {

                                            if (cnt == 1) {
                                                if (checkDate(String(day), String(month), String(year))) {
                                                    mark.visible = true
                                                } else {mark.visible = false}
                                            }
                                        }
                                        Component.onCompleted: {
//                                            initializeDatabase()
                                            if (checkDate(String(day), String(month), String(year))) {
                                                mark.visible = true
                                            } else {mark.visible = false}
                                        }
                                    }
                                }
                            }
                        }
                        Column {
                            Component.onCompleted: {
                                datePicker2.date = new Date(datePicker.year, datePicker.month-2, 1, 0, 0)
                            }

                            Label {
                                text: Func.get_month(datePicker2.month) + " " + datePicker2.year
                                color: "white"
        //                        anchors.bottom: datePicker
                                font.pixelSize: Theme.fontSizeExtraLargeBase
                                leftPadding: 20
                            }

                            DatePicker {
                                id: datePicker2

                                monthYearVisible: false
                                daysVisible: false
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
                                    width: datePicker2.cellWidth
                                    height: datePicker2.cellHeight

                                    onClicked: {
                                        datePicker2.date = new Date(year, month-1, day, 12, 0, 0)
                                        var page = pageStack.push(Qt.resolvedUrl("DayPage.qml"))
                                        page.init(datePicker2.year, datePicker2.month, datePicker2.day, datePicker2.date.toString())
    //                                    Func.func()
                                    }
                                    Label {
                                        id: dd2
                                        anchors.centerIn: parent
                                        text: day
                                        color: month === primaryMonth ? "#ff0000" : "#800000"
                //                        font.bold: holiday
                                        font.pixelSize: !holiday? Theme.fontSizeMedium : Theme.fontSizeExtraSmall
                                    }
                                    Label {
                                        id: mark2
                                        anchors.top: dd2.bottom
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "*"
                                        font.pixelSize: Theme.fontSizeExtraLarge
                                        visible: false
                                        property int cnt: pageStack.depth
                                        onCntChanged: {
                                            if (cnt == 1) {
                                                if (checkDate(String(day), String(month), String(year))) {
                                                    mark2.visible = true
                                                }  else {mark2.visible = false}
                                            }
                                        }
                                        Component.onCompleted: {
//                                            initializeDatabase()
                                            if (checkDate(String(day), String(month), String(year))) {
                                                mark2.visible = true
                                            } else {mark2.visible = false}
                                        }
                                    }
                                }
                            }
                        }
                        Column {
                            Component.onCompleted: {
                                datePicker3.date = new Date(datePicker.year, datePicker.month-3, 1, 12, 0, 0)
                            }

                            Label {
                                text: Func.get_month(datePicker3.month) + " " + datePicker3.year
                                color: "white"
        //                        anchors.bottom: datePicker
                                font.pixelSize: Theme.fontSizeExtraLargeBase
                                leftPadding: 20
                            }

                            DatePicker {
                                id: datePicker3
                //                ColorPickerPage: ""

                                monthYearVisible: false
                                daysVisible: false
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
                                    width: datePicker3.cellWidth
                                    height: datePicker3.cellHeight

                                    onClicked: {
                                        datePicker3.date = new Date(year, month-1, day, 12, 0, 0)
                                        var page = pageStack.push(Qt.resolvedUrl("DayPage.qml"))
                                        page.init(datePicker3.year, datePicker3.month, datePicker3.day, datePicker3.date.toString())
    //                                    Func.func()
                                    }
                                    Label {
                                        id: dd3
                                        anchors.centerIn: parent
                                        text: day
                                        color: month === primaryMonth ? "#ff0000" : "#800000"
                //                        font.bold: holiday
                                        font.pixelSize: !holiday? Theme.fontSizeMedium : Theme.fontSizeExtraSmall
                                    }
                                    Label {
                                        id: mark3
                                        anchors.top: dd3.bottom
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "*"
                                        font.pixelSize: Theme.fontSizeExtraLarge
                                        visible: false
                                        property int cnt: pageStack.depth
                                        onCntChanged: {
                                            if (cnt == 1) {
                                                if (checkDate(String(day), String(month), String(year))) {
                                                    mark3.visible = true
                                                } else {mark3.visible = false}
                                            }
                                        }
                                        Component.onCompleted: {
//                                            initializeDatabase()
                                            if (checkDate(String(day), String(month), String(year))) {
                                                mark3.visible = true
                                            } else {mark3.visible = false}
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            VerticalScrollDecorator { }
        }
    }
}
