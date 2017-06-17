import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0

Item {
    property string type : ""
    property string previewURL: ""
    property string mediaURL: ""
    Image {
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        opacity: status === Image.Ready ? 1.0 : 0.0
        Behavior on opacity { FadeAnimator {} }
        source: previewURL
        MouseArea {
            anchors.fill: parent
            onClicked: {
                pageStack.push(Qt.resolvedUrl("./ImageFullScreen.qml"), {"previewURL": previewURL, "mediaURL": mediaURL, "type": type})
            }
        }
    }
}
