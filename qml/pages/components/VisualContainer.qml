import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {
    id: delegate
    signal send (string notice)
    signal navigateTo(string link)
    width: parent.width
    height: miniHeader.height + lblContent.height + Theme.paddingLarge + (ministatus.visible ? ministatus.height : 0) +Theme.paddingLarge
    MiniStatus {
        id: ministatus
        anchors {
            leftMargin: Theme.horizontalPageMargin
            rightMargin: Theme.horizontalPageMargin
            top: parent.top
            topMargin: Theme.paddingMedium
        }
    }
    Image {
        id: avatar
        anchors {
            top: ministatus.visible ? ministatus.bottom : parent.top
            topMargin: ministatus.visible ? Theme.paddingMedium : Theme.paddingLarge
            left: parent.left
            leftMargin: Theme.horizontalPageMargin
        }
        asynchronous: true
        width: Theme.iconSizeMedium
        height: width
        smooth: true
        source: account_avatar
        visible: true
        MouseArea {
            anchors.fill: parent
            onClicked: {
                pageStack.push(Qt.resolvedUrl("../Profile.qml"), {
                                   "displayname": model.status_account_display_name,
                                   "username": model.status_account_acct,
                                   "profileImage": model.status_account_avatar
                               })
            }

        }
        Rectangle {
            color: Theme.highlightDimmerColor
            width: Theme.iconSizeSmall
            height: width
            visible: typeof status_reblog !== "undefined" && status_reblog
            anchors {
                bottom: parent.bottom
                bottomMargin: -width/3
                left: parent.left
                leftMargin: -width/3
            }
            Image {
                asynchronous: true
                width: Theme.iconSizeSmall
                height: width
                smooth: true
                source: reblog_account_avatar
                visible: typeof status_reblog !== "undefined" && status_reblog
            }
        }
    }
    MiniHeader {
        id: miniHeader
        anchors {
            top: avatar.top
            left: avatar.right
            right: parent.right
        }
    }
    Label {
        id: lblContent
        anchors {
            left: miniHeader.left
            leftMargin: Theme.paddingMedium
            right: miniHeader.right
            rightMargin: Theme.horizontalPageMargin
            top: miniHeader.bottom
            topMargin: Theme.paddingSmall
            bottomMargin: Theme.paddingLarge
        }
        height: content.length ? paintedHeight : 0
        onLinkActivated: {
            console.log(link)
            if (link[0] === "@") {
                pageStack.push(Qt.resolvedUrl("../Profile.qml"), {
                                   "name": "",
                                   "username": link.substring(1),
                                   "profileImage": ""
                               })
            } else if (link[0] === "#") {

                pageStack.pop(pageStack.find(function(page) {
                    var check = page.isFirstPage === true;
                    if (check)
                        page.onLinkActivated(link)
                    return check;
                }));

                send(link)
            } else {
                pageStack.push(Qt.resolvedUrl("../Browser.qml"), {"href" : link})
            }


        }
        text: content
        textFormat: Text.StyledText
        linkColor : Theme.highlightColor
        wrapMode: Text.Wrap
        font.pixelSize: Theme.fontSizeSmall
        color: (pressed ? Theme.highlightColor : Theme.primaryColor)
    }




    onClicked: {
        pageStack.push(Qt.resolvedUrl("../Conversation.qml"), {
                           toot_id: id,
                           title: account_display_name,
                           description: '@'+account_username,
                           avatar: account_avatar,
                           type: "reply"
                       })
    }
}
