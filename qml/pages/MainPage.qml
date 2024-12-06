import QtQuick 2.0
import Sailfish.Silica 1.0
import "../../qml/pages/func.js" as Func
import QtQuick.LocalStorage 2.0
import Nemo.Notifications 1.0
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

    Notification {
        id: notification
        appIcon: Qt.resolvedUrl("../icons/TaskTracker.svg")
//                    icon: Qt.resolvedUrl("../icons/TaskTracker.svg")
        appName: "Task Tracker"
        summary: qsTr("Не забудь про сегодняшнюю задачу!")
        body: qsTr("Notification body")
        previewSummary: qsTr("Не забудь про сегодняшнюю задачу!")
        previewBody: qsTr("Notification preview body")
        onClicked: console.log("Clicked")
        onClosed: console.log("Closed, reason: " + reason)
    }

    function initializeDatabase() {
        var dbase = LocalStorage.openDatabaseSync("Tasks", "1.0", "Tasks
                Database", 1000000)
        dbase.transaction(function(tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS " + _table + "(date TEXT, name TEXT, desc TEXT, complete BOOL)");
            console.log("Table created!")
        })
        db = dbase;
        insertTestData();
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
//                    console.log()
                }
                if (data) {
                    tasks = data
                }

            });
    }
    function checkDateforNotification(d, m, y) {
        var currentDate = new Date();
        var ddate = Func.get_correct_date(d, m, y);
        var f = false;
        db.transaction(function (tx) {
                var rs = tx.executeSql("SELECT rowid, * FROM " + _table);
                var data = [];
                for (var i = 0; i < rs.rows.length; i++) {
                    model.id = rs.rows.item(i).rowid;
                    model.date = rs.rows.item(i).date;
                    model.name = rs.rows.item(i).name;
                    model.desc = rs.rows.item(i).desc;
                    var check_split = model.date.split(".");
                    var check_date = Func.get_correct_date(check_split[0], check_split[1], check_split[2])
                    var curr_split = currentDate.toTimeString().split(":")
                    var curr_date = Func.get_correct_date(curr_split[0], curr_split[1], curr_split[2]);
//                    console.log("curYear:", )
                    if (check_date === curr_date &
                            (curr_split[0] === "21" & curr_split[1] === "20")) {
                        notification.body = model.name
                        notification.previewBody = model.name
                        console.log("notification.publish()")
                        notification.publish()
                    }
                }
            });
    }
    function checkDate(d, m, y) {
        var ddate = Func.get_correct_date(d, m, y);
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
                        f = true
                    }
                }
            });
        return f
    }

    function insertTestData() {
        var data_pass = (false)?[[ "07.01.2025", "Заглушка 1", "Описание заглушки 1", false],
                            [ "08.01.2025", "Заглушка 2", "Описание заглушки 2", false],
                            [ "11.01.2025", "Заглушка 3", "Описание заглушки 3", false],
                            [ "03.12.2024", "Заглушка 4", "Описание заглушки 4", false],
                            [ "04.01.2025", "Заглушка 5", "Описание заглушки 5", false],
                            [ "15.12.2024", "Заглушка 6", "Описание заглушки 6", false]]:[]

        var data = (true)?[[ "03.12.2024", "ДЗ Схемотехника", "Доделать ДЗ 1 с автоматом", false],
                            [ "19.12.2024", "ДЗ ОДК", "Отправить на почту ДЗ", false],
                            [ "17.01.2025", "Экзамен по сетям", "Подготовиться к экзамену по сетям", false],
                            [ "11.01.2025", "Экзамен по ССРПО", "Подготовиться к экзамену по ССРПО", false],
                            [ "09.12.2024", "Защита курсовой ТРПС", "Подготовиться к защите курсовой по ТРПС", false],
                            [ "14.12.2024", "Курсовая ТРПС", "Сдать на подпись титул РПЗ", false],
                            [ "18.12.2024", "Проект для РИП", "Закончить  разработку TaskAPI", false],
                            [ "05.12.2024", "Утреняя пробежка", "Пробежать без остановки 3 км за 15 минут", false],
                            ]:[]

        try {
                db.transaction(function (tx) {
                    var item, i;
                    for (i=0; i< data.length; i++) {
                        item = data[i];
                        saveData(tx, item[0],item[1],item[2],item[3]);
                    }
                    for (i=0; i< data_pass.length; i++) {
                        item = data_pass[i];
                        saveData(tx, item[0],item[1],item[2],item[3]);
                    }
                })
        } catch (err) {
                console.log("ERROR INSERT TEST DATA: " + err)
        };
    }
    function saveData(tx, col1, col2, col3, col4) {
        tx.executeSql("INSERT INTO " + _table + " VALUES(?, ?, ?, ?)", [col1, col2, col3, col4]);
    }

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
                id: addButton
                backgroundColor: "transparent"
                color: "#e30000"
                anchors.left: aboutButton.right
                width: 50

                Text {
                    text: "+"
                    color: "#e30000"
                    font.pixelSize: Theme.fontSizeHuge
                    anchors.centerIn: parent
                }
                anchors.verticalCenter: parent.verticalCenter
                onClicked: pageStack.push(Qt.resolvedUrl("AddEventPage.qml"))
            },
            Button {
                id: allButton
                backgroundColor: "transparent"
                color: "white"
                highlightColor: "red"
                anchors.left: addButton.right

                width: Theme.buttonWidthMedium

                Text {
                    text: qsTr("Задачи")
                    color: "white"
                    font.pixelSize: Theme.fontSizeLarge
                    font.styleName: "Times New Roman"
                    anchors.centerIn: parent
                }
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    var page = pageStack.push(Qt.resolvedUrl("ShowAllTasks.qml"));
                    page.init()
                }
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

                ListView {
                    objectName: "flickable2"
                    contentWidth: page.width

                    contentHeight: panels.height + Theme.paddingLarge

                    Column {
                        id: panels
                        spacing: 50

                        Column {
                            Component.onCompleted: {
                                console.log("DatePicker1", datePicker.month)
                            }

                            Label {
                                text: Func.get_month(datePicker.month) + " " + datePicker.year
//                                text: "The date is: " + Date().toLocaleString(Qt.locale())
                                color: "white"
                                font.pixelSize: Theme.fontSizeExtraLargeBase
                                leftPadding: 20
                            }
                            DatePicker {
                                id: datePicker

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
                                    id: delegat
                                    width: datePicker.cellWidth
                                    height: datePicker.cellHeight

                                    onClicked: {
                                        datePicker.date = new Date(year, month-1, day, 12, 0, 0)
                                        var page = pageStack.push(Qt.resolvedUrl("DayPage.qml"))
                                        page.init(datePicker.year, datePicker.month, datePicker.day, datePicker.date.toString())
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
                                    Icon {
                                        id: circle_mark
                                        anchors.top: dd.bottom
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        source: Qt.resolvedUrl("../icons/white_circle.png")

                                        height: 25
                                        width: 25
                                        visible: false
                                        property int cnt: pageStack.depth
                                        onCntChanged: {

                                            if (cnt == 1) {
                                                if (checkDate(String(day), String(month), String(year))) {
                                                    circle_mark.visible = true
                                                } else {circle_mark.visible = false}
                                            }
                                        }
                                        Component.onCompleted: {
//                                            initializeDatabase()
                                            if (checkDate(String(day), String(month), String(year))) {
                                                circle_mark.visible = true
                                            } else {circle_mark.visible = false}
                                        }
                                    }
//                                    Label {
//                                        id: mark
//                                        anchors.top: dd.bottom
//                                        anchors.horizontalCenter: parent.horizontalCenter
//                                        text: "*"
//                                        font.pixelSize: Theme.fontSizeExtraLarge
//                                        visible: false
//                                        property int cnt: pageStack.depth
//                                        onCntChanged: {

//                                            if (cnt == 1) {
//                                                if (checkDate(String(day), String(month), String(year))) {
//                                                    mark.visible = true
//                                                } else {mark.visible = false}
//                                            }
//                                        }
//                                        Component.onCompleted: {
////                                            initializeDatabase()
//                                            if (checkDate(String(day), String(month), String(year))) {
//                                                mark.visible = true
//                                            } else {mark.visible = false}
//                                        }
//                                    }
                                }
                            }
                        }
                        Column {
                            Component.onCompleted: {
                                console.log("DatePicker2", datePicker.month-1)
                                datePicker2.date = new Date(datePicker.year, datePicker.month, 1, 0, 0)
                                console.log("DatePicker2", datePicker2.month)

                            }

                            Label {
                                text: Func.get_month(datePicker2.month) + " " + datePicker2.year
                                color: "white"
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
                                    }
                                    Label {
                                        id: dd2
                                        anchors.centerIn: parent
                                        text: day
                                        color: month === primaryMonth ? "#ff0000" : "#800000"
//                                        font.bold: holiday
//                                        font.pixelSize: !holiday? Theme.fontSizeMedium : Theme.fontSizeExtraSmall
                                    }
                                    Icon {
                                        id: circle_mark2
                                        anchors.top: dd2.bottom
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        source: Qt.resolvedUrl("../icons/white_circle.png")

                                        height: 25
                                        width: 25
                                        visible: false
                                        property int cnt: pageStack.depth
                                        onCntChanged: {

                                            if (cnt == 1) {
                                                if (checkDate(String(day), String(month), String(year))) {
                                                    circle_mark2.visible = true
                                                } else {circle_mark2.visible = false}
                                            }
                                        }
                                        Component.onCompleted: {
//                                            initializeDatabase()
                                            if (checkDate(String(day), String(month), String(year))) {
                                                circle_mark2.visible = true
                                            } else {circle_mark2.visible = false}
                                        }
                                    }
                                }
                            }
                        }
                        Column {
                            Component.onCompleted: {
                                datePicker3.date = new Date(datePicker.year, datePicker.month+1, 1, 12, 0, 0)
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
                                        color: month === primaryMonth ? (isToday()? "white" : "#ff0000"): "#800000"
                                        function isToday(){
                                            var date_now = new Date()
                                            return (datePicker3.year === date_now.year &
                                                datePicker3.month - 1 === date_now.month &
                                                datePicker3.day === date_now.day)
                                        }
                                    }
                                    Icon {
                                        id: circle_mark3
                                        anchors.top: dd3.bottom
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        source: Qt.resolvedUrl("../icons/white_circle.png")

                                        height: 25
                                        width: 25
                                        visible: false
                                        property int cnt: pageStack.depth
                                        onCntChanged: {

                                            if (cnt == 1) {
                                                if (checkDate(String(day), String(month), String(year))) {
                                                    circle_mark3.visible = true
                                                } else {circle_mark3.visible = false}
                                            }
                                        }
                                        Component.onCompleted: {
                                            if (checkDate(String(day), String(month), String(year))) {
                                                circle_mark3.visible = true
                                            } else {circle_mark3.visible = false}
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
