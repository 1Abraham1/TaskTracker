import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    objectName: "defaultCover"

    CoverTemplate {
        objectName: "applicationCover"
        primaryText: "App"
        secondaryText: qsTr("Template")
        icon {
            source: Qt.resolvedUrl("../icons/TaskTracker.svg")
            sourceSize { width: icon.width; height: icon.height }
        }
    }
//    Label {
//        width: parent.width
//        text: "TT"
//        truncationMode: TruncationMode.Elide
//        font.pixelSize: Theme.fontSizeLarge
//        wrapMode: Label.WordWrap
//    }
//    CoverActionList {
//        CoverAction {
//            iconSource: "image::theme/icon-cover-previous"
//            onTriggered: navigateBack()
//        }
//        CoverAction {
//            iconSource: "image::theme/icon-cover-next"
//            onTriggered: navigateForward()
//        }
//    }
}
