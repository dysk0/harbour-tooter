import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0

Page {
    id: page
    property string type: ""
    property string previewURL: ""
    property string mediaURL: ""
    allowedOrientations: Orientation.All

    Item {
        anchors.fill: parent
        clip: true
        Image {
            id: image
            anchors.centerIn: parent
            //fillMode: Image.PreserveAspectCrop
            asynchronous: true
            opacity: status === Image.Ready ? 1.0 : 0.0
            Behavior on opacity { FadeAnimator {} }
            source: mediaURL
            onStatusChanged: {
                if (status === Image.Ready) {
                    console.log('Loaded')
                    width = sourceSize.width
                    height = sourceSize.height
                    if (width > height)
                        pinch.scale = page.width / width
                    else
                        pinch.scale = page.height / height
                }
            }

        }

        Video {
            id: video
            anchors.fill: parent
            autoLoad: true
            source: videoURL
            onErrorStringChanged: {
                console.log(errorString)
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    video.playbackState == MediaPlayer.PlayingState ? video.pause() : video.play()
                }
            }

            focus: true
        }

        PinchArea {
            id: pinch
            visible: videoURL === ""
            anchors.fill: parent
            pinch.target: image
            pinch.minimumScale: 0.1
            pinch.maximumScale: 10
            pinch.dragAxis: Pinch.XAndYAxis
        }
    }
}
