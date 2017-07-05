import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.tooter.Uploader 1.0
import "../lib/API.js" as Logic
import "./components/"

Page {
    id: conversationPage
    property string type;
    property alias title: header.title
    property alias description: header.description
    property alias avatar: header.image
    property int toot_id
    property ListModel mdl;

    WorkerScript {
        id: worker
        source: "../lib/Worker.js"
        onMessage: {
            console.log(JSON.stringify(messageObject))
        }
    }

    ProfileHeader {
        id: header
        visible: false
    }
    SilicaListView {
        id: conversationList
        header: PageHeader {
            title: qsTr("Conversation")
        }
        clip: true;
        anchors {
            top: parent.top
            bottom: panel.top
            left: parent.left
            right: parent.right
        }
        model: mdl
        section {
            property: 'section'
            delegate: SectionHeader  {
                height: Theme.itemSizeExtraSmall
                text: Format.formatDate(section, Formatter.DateMedium)
            }
        }
        delegate: VisualContainer {}
        onCountChanged: {
            for (var i = 0; i < mdl.count; i++){
                if (mdl.get(i).status_id === toot_id) {
                    console.log(mdl.get(i).status_id)
                    positionViewAtIndex(i, ListView.Center )
                }
            }

            //last_id_MN

        }

    }

    DockedPanel {
        id: panel
        open: true
        onExpandedChanged: {
            if (!expanded) {
                show()
            }
        }

        width: parent.width
        height: toot.height + btnContentWarning.height + Theme.paddingMedium + (warningContent.visible ? warningContent.height : 0)
        dock: Dock.Bottom
        TextField {
            id: warningContent
            visible: false
            height: visible ? implicitHeight : 0;
            anchors {
                top: parent.top
                topMargin: Theme.paddingMedium
                left: parent.left
                right: parent.right
            }
            autoScrollEnabled: true
            labelVisible: false
            placeholderText: qsTr("Content warning!")
            horizontalAlignment: Text.AlignLeft
            EnterKey.onClicked: {
                //tweet()
            }
        }
        TextArea {
            id: toot
            anchors {
                top: warningContent.bottom
                topMargin: Theme.paddingMedium
                left: parent.left
                right: parent.right
            }
            autoScrollEnabled: true
            labelVisible: false
            //            focus: true
            text: description !== "" && (description.charAt(0) == '@' || description.charAt(0) == '#') ? description+' '  : ''
            height: implicitHeight
            horizontalAlignment: Text.AlignLeft
            EnterKey.onClicked: {
                //tweet()
            }
        }
        IconButton {
            id: btnContentWarning
            anchors {
                verticalCenter: privacy.verticalCenter
                left: parent.left
                leftMargin: Theme.paddingMedium
            }
            icon.source: "image://theme/icon-s-high-importance?" + (pressed
                                                                    ? Theme.highlightColor
                                                                    : (warningContent.visible ? Theme.secondaryHighlightColor : Theme.primaryColor))
            onClicked: warningContent.visible = !warningContent.visible
        }
        IconButton {
            id: btnAddImage
            anchors {
                verticalCenter: privacy.verticalCenter
                left: btnContentWarning.right
                leftMargin: Theme.paddingSmall
            }
            icon.source: "image://theme/icon-s-attach?" + (pressed
                                                           ? Theme.highlightColor
                                                           : (warningContent.visible ? Theme.secondaryHighlightColor : Theme.primaryColor))
            onClicked: {
                //receiver.receiveFromQml(42);
                //imageUploader.run()
                var once = true;
                var imagePicker = pageStack.push("Sailfish.Pickers.MultiImagePickerDialog", { "allowedOrientations" : Orientation.All });
                imagePicker.selectedContentChanged.connect(function () {
                    if (once) {
                        for(var i = 0; i < imagePicker.selectedContent.count; i++){
                            var file = imagePicker.selectedContent.get(i);
                            console.log(JSON.stringify(file))
                            imageUploader.setFile(file.url);
                            imageUploader.setAuthorizationHeader(Logic.conf.api_user_token);
                            imageUploader.upload();
                        }
                        once = false;
                    }


                    /*var file = imagePicker.selectedContent + "";
                    //file = file.replace("file://", "");
                    console.log(file)
                    imageUploader.setFile(file);
                    imageUploader.setAuthorizationHeader(Logic.conf.api_user_token);
                    imageUploader.upload();*/
                });
            }
        }
        ImageUploader {
                id: imageUploader

                onProgressChanged: {
                    console.log("progress "+progress)
                }

                onSuccess: {
                    console.log(replyData);
                }

                onFailure: {
                    console.log(status)
                    console.log(statusText)

                }

                function run() {
                    imageUploader.setFile('file:///media/sdcard/686E-E026/Pictures/Camera/20170701_143819.jpg');
                    imageUploader.setParameters("imageUploadData.imageAlbum", "imageUploadData.imageTitle", "imageUploadData.imageDesc");

                    imageUploader.setAuthorizationHeader(Logic.conf.api_user_token);
                    imageUploader.setUserAgent("constant.userAgent");

                    imageUploader.upload();
                }
            }
        ComboBox {
            id: privacy
            anchors {
                top: toot.bottom
                topMargin: -Theme.paddingSmall*2
                left: btnAddImage.right
                right: btnSend.left
            }
            menu: ContextMenu {
                MenuItem { text: qsTr("public") }
                MenuItem { text: qsTr("unlisted") }
                MenuItem { text: qsTr("followers only") }
                MenuItem { text: qsTr("direct") }
            }
        }
        IconButton {
            id: btnSend
            icon.source: "image://theme/icon-m-enter?" + (pressed
                                                          ? Theme.highlightColor
                                                          : Theme.primaryColor)
            anchors {
                top: toot.bottom
                right: parent.right
                rightMargin: Theme.paddingLarge
            }
            enabled: toot.text !== ""
            onClicked: {
                var visibility = [ "public", "unlisted", "private", "direct"];
                var msg = {
                    'action'    : 'statuses',
                    'method'    : 'POST',
                    'model'     : mdl,
                    'mode'     : "append",
                    'params'    : {
                        "status": toot.text,
                        "visibility": visibility[privacy.currentIndex]
                    },
                    'conf'      : Logic.conf
                };
                if (toot_id > 0)
                    msg.params['in_reply_to_id'] = toot_id

                if (warningContent.visible && warningContent.text.length > 0){
                    msg.params['sensitive'] = 1
                    msg.params['spoiler_text'] = warningContent.text
                }

                worker.sendMessage(msg);
                warningContent.text = ""
                toot.text = ""
            }
        }
    }
    Component.onCompleted: {
        toot.cursorPosition = toot.text.length
        worker.sendMessage({
                               'action'    : 'statuses/'+mdl.get(0).status_id+'/context',
                               'method'    : 'GET',
                               'model'     : mdl,
                               'params'    : { },
                               'conf'      : Logic.conf
                           });
    }
}
