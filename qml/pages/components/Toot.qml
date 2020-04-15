import QtQuick 2.0
import Sailfish.Silica 1.0
import QtGraphicalEffects 1.0

BackgroundItem {
    signal send (string notice)

    id: delegate
    //property string text: "0"
    width: parent.width
    signal navigateTo(string link)
    height: lblText.paintedHeight + (lblText.text.length > 0 ? Theme.paddingLarge : 0 )+ lblName.paintedHeight + (type.length ? Theme.paddingLarge + iconRT.height : 0) + Theme.paddingLarge
    Image {
        id: iconRT
        y: Theme.paddingLarge
        anchors {
            right: avatar.right
        }
        visible: type.length
        width: Theme.iconSizeExtraSmall
        height: width
        source: "../../images/boosted.svg"
    }
    Label {
        id: lblRtByName
        visible: type.length
        anchors {
            left: lblName.left
            bottom: iconRT.bottom
        }
        text: {
            var action;
            switch(type){
            case "reblog":
                action =  qsTr('boosted');
                break;
            case "favourite":
                action =  qsTr('favourited');
                break;
            case "follow":
                action =  qsTr('followed you');
                break;
            default:
                action = type;
            }
            return '@' + retweetScreenName + ' ' +  action
        }

        font.pixelSize: Theme.fontSizeExtraSmall
        color: Theme.secondaryColor
    }
    Image {
        id: avatar
        x: Theme.horizontalPageMargin
        y: Theme.paddingLarge + (type.length ? iconRT.height+Theme.paddingMedium : 0)
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
                                   "display_name": account_display_name,
                                   "username": account_username,
                                   "profileImage": account_avatar
                               })
            }

        }

    }
    Label {
        id: lblName
        anchors {
            top: avatar.top
            topMargin: 0
            left: avatar.right
            leftMargin: Theme.paddingMedium
        }
        text: account_display_name
        font.weight: Font.Bold
        font.pixelSize: Theme.fontSizeSmall
        color: (pressed ? Theme.highlightColor : Theme.primaryColor)
    }

    Image {
        id: iconVerified
        y: Theme.paddingLarge
        anchors {
            left: lblName.right
            leftMargin: Theme.paddingSmall
            verticalCenter: lblName.verticalCenter
        }
        visible: account_locked
        width: account_locked ? Theme.iconSizeExtraSmall*0.8 : 0
        opacity: 0.8
        height: width
        source: "image://theme/icon-s-secure?" + (pressed
                                                  ? Theme.highlightColor
                                                  : Theme.primaryColor)
    }


    Label {
        id: lblScreenName
        anchors {
            left: iconVerified.right
            right: lblDate.left
            leftMargin: Theme.paddingMedium
            baseline: lblName.baseline
        }
        truncationMode: TruncationMode.Fade
        text: '@'+account_username
        font.pixelSize: Theme.fontSizeExtraSmall
        color: (pressed ? Theme.secondaryHighlightColor : Theme.secondaryColor)
    }
    Label {
        function timestamp() {
            var txt = Format.formatDate(created_at, Formatter.Timepoint)
            var elapsed = Format.formatDate(created_at, Formatter.DurationElapsedShort)
            return (elapsed ? elapsed  : txt )
        }
        id: lblDate
        color: (pressed ? Theme.highlightColor : Theme.primaryColor)
        text: Format.formatDate(created_at, new Date() - created_at < 60*60*1000 ? Formatter.DurationElapsedShort : Formatter.TimeValueTwentyFourHours)
        font.pixelSize: Theme.fontSizeExtraSmall
        horizontalAlignment: Text.AlignRight
        anchors {
            right: parent.right
            baseline: lblName.baseline
            rightMargin: Theme.paddingLarge
        }
    }

    Label {
        id: lblText
        anchors {
            left: lblName.left
            right: parent.right
            top: lblScreenName.bottom
            topMargin: Theme.paddingSmall
            rightMargin: Theme.paddingLarge          
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
                Qt.openUrlExternally(link);
            }


        }
        text: content
        textFormat: Text.StyledText
        linkColor : Theme.highlightColor
        wrapMode: Text.Wrap
        maximumLineCount: 6
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
