import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0

Page {
    id: imagePage
    property string type: ""
    property string previewURL: ""
    property string mediaURL: ""
    allowedOrientations: Orientation.All
    Component.onCompleted: function(){
        console.log(type)
        console.log(previewURL)
        console.log(mediaURL)
        if (type != 'gifv' && type != 'video') {
            imagePreview.source = mediaURL
            imageFlickable.visible = true;
        } else {
            video.source = mediaURL
            video.fillMode = VideoOutput.PreserveAspectFit
            video.play()
            videoFlickable.visible = true;
        }
    }
    Flickable {
        id: videoFlickable
        visible: false
        anchors.fill: parent
        contentWidth: imageContainer.width; contentHeight: imageContainer.height
        clip: true
        Image {
            id: videoPreview
            fillMode: Image.PreserveAspectFit
            anchors.fill: parent
            source: previewURL
        }
        Video {
            id: video
            anchors.fill: parent
            onErrorStringChanged: function(){
                videoError.visible = true;
            }
            onStatusChanged: {
                console.log(status)
                switch (status){
                case MediaPlayer.Loading:
                    console.log("loading")
                    return;
                case MediaPlayer.EndOfMedia:
                    console.log("EndOfMedia")
                    return;

                }
            }

            onPlaybackStateChanged: {
                console.log(playbackState)
                switch (playbackState){
                case MediaPlayer.PlayingState:
                    playerIcon.icon.source = "image://theme/icon-m-pause"
                    return;
                case MediaPlayer.PausedState:
                    playerIcon.icon.source = "image://theme/icon-m-play"
                    return;
                case MediaPlayer.StoppedState:
                    playerIcon.icon.source = "image://theme/icon-m-stop"
                    return;
                }
            }


            onPositionChanged: function(){
                //console.log(duration)
                //console.log(bufferProgress)
                //console.log(position)
                if (status !== MediaPlayer.Loading){
                    playerProgress.indeterminate = false
                    playerProgress.maximumValue = duration
                    playerProgress.minimumValue = 0
                    playerProgress.value = position
                }

            }
            onStopped: function(){
                play()
            }
            IconButton {
                id: playerIcon
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.leftMargin: Theme.paddingLarge
                anchors.bottomMargin: Theme.paddingMedium
                icon.source: "image://theme/icon-m-play"
                onClicked: function() {
                    if (video.playbackState === MediaPlayer.PlayingState)
                        video.pause()
                    else
                        video.play()
                }
            }

            ProgressBar {
                indeterminate: true
                id: playerProgress
                anchors.left: playerIcon.right
                anchors.right: videoDlBtn.left

                anchors.verticalCenter: playerIcon.verticalCenter
                anchors.leftMargin: 0
                anchors.bottomMargin: Theme.paddingMedium
            }
            IconButton {
                id: videoDlBtn
                visible: true
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.rightMargin: Theme.paddingLarge
                anchors.bottomMargin: Theme.paddingMedium
                //width: Theme.iconSizeMedium+Theme.paddingMedium*2
                icon.source: "image://theme/icon-m-cloud-download"
                onClicked: {
                    var filename = mediaURL.split("/");
                    FileDownloader.downloadFile(mediaURL, filename[filename.length-1]);
                }
            }
            Rectangle {
                visible: videoError.text != ""
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                color: Theme.highlightDimmerColor
                height: videoError.height + 2*Theme.paddingMedium
                width: parent.width
                Label {
                    anchors.centerIn: parent
                    id: videoError
                    width: parent.width - 2*Theme.paddingMedium
                    wrapMode: Text.WordWrap
                    height: contentHeight
                    visible: false;
                    font.pixelSize: Theme.fontSizeSmall;
                    text: video.errorString
                    color: Theme.highlightColor
                }
            }


            MouseArea {
                anchors.fill: parent
                onClicked: function() {
                    if (video.playbackState === MediaPlayer.PlayingState)
                        video.pause()
                    else
                        video.play()
                }
            }
        }
    }

    Flickable {
        id: imageFlickable
        visible: false
        anchors.fill: parent
        contentWidth: imageContainer.width; contentHeight: imageContainer.height
        clip: true
        onHeightChanged: if (imagePreview.status === Image.Ready) imagePreview.fitToScreen();


        Item {
            id: imageContainer
            width: Math.max(imagePreview.width * imagePreview.scale, imageFlickable.width)
            height: Math.max(imagePreview.height * imagePreview.scale, imageFlickable.height)

            Image {
                id: imagePreview

                property real prevScale

                function fitToScreen() {
                    scale = Math.min(imageFlickable.width / width, imageFlickable.height / height, 1)
                    pinchArea.minScale = scale
                    prevScale = scale
                }

                anchors.centerIn: parent
                fillMode: Image.PreserveAspectFit
                cache: true
                asynchronous: true
                sourceSize.height: 1000;
                smooth: false

                onStatusChanged: {
                    if (status == Image.Ready) {
                        fitToScreen()
                        loadedAnimation.start()
                    }
                }

                NumberAnimation {
                    id: loadedAnimation
                    target: imagePreview
                    property: "opacity"
                    duration: 250
                    from: 0; to: 1
                    easing.type: Easing.InOutQuad
                }

                onScaleChanged: {
                    if ((width * scale) > imageFlickable.width) {
                        var xoff = (imageFlickable.width / 2 + imageFlickable.contentX) * scale / prevScale;
                        imageFlickable.contentX = xoff - imageFlickable.width / 2
                    }
                    if ((height * scale) > imageFlickable.height) {
                        var yoff = (imageFlickable.height / 2 + imageFlickable.contentY) * scale / prevScale;
                        imageFlickable.contentY = yoff - imageFlickable.height / 2
                    }
                    prevScale = scale
                }
            }
        }

        PinchArea {
            id: pinchArea
            opacity: 0.3
            property real minScale: 1.0
            property real maxScale: 3.0

            anchors.fill: parent
            enabled: imagePreview.status === Image.Ready
            pinch.target: imagePreview
            pinch.minimumScale: minScale * 0.5 // This is to create "bounce back effect"
            pinch.maximumScale: maxScale * 1.5 // when over zoomed

            onPinchFinished: {
                imageFlickable.returnToBounds()
                if (imagePreview.scale < pinchArea.minScale) {
                    bounceBackAnimation.to = pinchArea.minScale
                    bounceBackAnimation.start()
                }
                else if (imagePreview.scale > pinchArea.maxScale) {
                    bounceBackAnimation.to = pinchArea.maxScale
                    bounceBackAnimation.start()
                }
            }
            NumberAnimation {
                id: bounceBackAnimation
                target: imagePreview
                duration: 250
                property: "scale"
                from: imagePreview.scale
            }
        }
    }

    Loader {
        anchors.centerIn: parent
        sourceComponent: {
            switch (imagePreview.status) {
            case Image.Loading:
                return loadingIndicator
            case Image.Error:
                return failedLoading
            default:
                return undefined
            }
        }

        Component {
            id: loadingIndicator

            Item {
                height: childrenRect.height
                width: imagePage.width

                ProgressCircle {
                    id: imageLoadingIndicator
                    anchors.horizontalCenter: parent.horizontalCenter
                    progressValue: imagePreview.progress
                }
            }
        }
    }
    Component {
        id: failedLoading
        Text {
            font.pixelSize: Theme.fontSizeSmall;
            text: qsTr("Error loading")
            color: Theme.highlightColor
        }
    }
    IconButton {
        visible: true
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: Theme.paddingLarge
        anchors.bottomMargin: Theme.paddingMedium
        //width: Theme.iconSizeMedium+Theme.paddingMedium*2
        icon.source: "image://theme/icon-m-cloud-download"
        onClicked: {
            var filename = mediaURL.split("/");
            FileDownloader.downloadFile(mediaURL, filename[filename.length-1]);
        }
    }
    VerticalScrollDecorator { flickable: imageFlickable }
}
