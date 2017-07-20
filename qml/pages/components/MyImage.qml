import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0

Item {
    property string type : ""
    property string previewURL: ""
    property string mediaURL: ""
    Rectangle {
        opacity: 0.2
        anchors.fill: parent
        color: Theme.highlightDimmerColor

    }
    Image {
        anchors.centerIn: parent
        source: "image://theme/icon-m-image"
    }
    Image {
        id: img
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
        Image {
            visible: type === "video" || type === "gifv"
            anchors.centerIn: parent
            source: "image://theme/icon-l-play"
        }
        BusyIndicator {
            size: BusyIndicatorSize.Large
            running: img.status !== Image.Ready
            opacity: img.status === Image.Ready ? 0.0 : 1.0
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Rectangle {
            anchors.fill: parent
            color: Theme.highlightDimmerColor
            visible: status_sensitive
            Image {
                source: "image://theme/icon-l-attention?"+Theme.highlightColor
                anchors.centerIn: parent
            }
            MouseArea {
                anchors.fill: parent
                onClicked: parent.visible = false;
            }
        }
    }

}
