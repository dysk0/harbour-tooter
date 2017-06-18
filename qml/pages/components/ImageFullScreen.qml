import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0

Page {
    id: page
    property string type: ""
    property string previewURL: ""
    property string mediaURL: ""
    allowedOrientations: Orientation.All
    Component.onCompleted: {
        console.log(type)
        console.log(previewURL)
        console.log(mediaURL)
    }
    onStateChanged: {
        if (status === PageStatus.Deactivating){
            video.stop()
        }
        if (status === PageStatus.Activating){
            if (type !== "image" )
                video.play()
        }
    }
    BusyIndicator {
        running: image.status !== Image.Ready
        size: BusyIndicatorSize.Large
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }
    Item {
        anchors.fill: parent
        clip: true
        Image {
            id: image
            anchors.centerIn: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            opacity: status === Image.Ready ? 1.0 : 0.0
            Behavior on opacity { FadeAnimator {} }
            source: type === "image" ? mediaURL : previewURL
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
            Video {
                id: video
                anchors.fill: parent
                autoLoad: true
                onStateChanged: {
                    switch(status){
                    case MediaPlayer.Loaded:
                        play();
                        break;
                    case MediaPlayer.Loading:
                        loader.running = true;
                        break;
                    case MediaPlayer.EndOfMedia:
                        if(seekable)
                            seek(0)
                        break;
                    default:
                        loader.running = false;
                    }
                }

                source: type !== "image" ? mediaURL : ""
                onErrorStringChanged: {
                    console.log(errorString)
                }
                BusyIndicator {
                    id: loader
                    size: BusyIndicatorSize.Small
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        video.playbackState == MediaPlayer.PlayingState ? video.pause() : video.play()
                    }
                }

                focus: true
            }

        }



        PinchArea {
            id: pinch
            visible: type === "image"
            anchors.fill: parent
            pinch.target: image
            pinch.minimumScale: 0.1
            pinch.maximumScale: 10
            pinch.dragAxis: Pinch.XAndYAxis
        }
        Label {
            visible: type !== "image"
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
            text: "Video playing is faulty... may break app... Just to know :)"
        }

    }
}
