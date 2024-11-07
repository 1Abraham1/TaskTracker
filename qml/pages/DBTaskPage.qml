import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0

Item {
    id: root
    objectName: "DBTasks"
    QtObject {
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

    property var db
    property string _table: "Tasks"

    function countToday(result) {
        db.transaction(function (tx) {
                var rs = tx.executeSql("SELECT count(*) as cnt FROM " + _table + " WHERE date(substr(date,0,11)) = date('now') ");
                result(rs.rows.item(0).cnt);
            });
    }

    function addRow(result) {
        db.transaction(function (tx) {
            tx.executeSql(
                "INSERT INTO " + _table + " VALUES(?, ?, ?)",
                [ model.date, model.name, model.desc]
            );
        });
    }

    function selectRows(result) {
        db.transaction(function (tx) {
                var rs = tx.executeSql("SELECT rowid, * FROM " + _table);
                var data = [];
                for (var i = 0; i < rs.rows.length; i++) {
                    model.id = rs.rows.item(i).rowid;
                    model.date = rs.rows.item(i).date;
                    model.name = rs.rows.item(i).name;
                    model.desc = rs.rows.item(i).desc;
                    data.push(model.copy());
                }
                result(data);
            });
    }

    function updateRow(data, result) {
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
                }
            }
        );
        selectRows(result);
    }

    function deleteRow(id, result) {
        db.transaction(function (tx) {
                tx.executeSql("DELETE FROM " + _table + " WHERE rowid=" + parseInt(id));
            }
        );
        selectRows(result);
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

