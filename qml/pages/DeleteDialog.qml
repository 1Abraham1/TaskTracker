import QtQuick 2.0
import Sailfish.Silica 1.0


Dialog {
    DialogHeader {
        id: header
        title: "Подтвердить удаление"
    }
    Label {
        text: "Действительно удалить этот файл?"
        anchors.top: header.bottom
        x: Theme.horizontalPageMargin
        color: Theme.highlightColor
    }
    onAccepted: {
        console.log("onAccepted")
        if (result == DialogResult.Accepted) {
            console.log("onAccepted")
        }
    }
}
