import QtQuick 2.2
import Sailfish.Silica 1.0
import "../../lib/API.js" as Logic

BackgroundItem {

    id: delegate
    signal send (string notice)
    signal navigateTo(string link)
    width: parent.width
    height: mnu.height +  miniHeader.height + (typeof attachments !== "undefined" && attachments.count ? media.height + Theme.paddingLarge + Theme.paddingMedium: Theme.paddingLarge) + lblContent.height + Theme.paddingLarge + (ministatus.visible ? ministatus.height : 0)
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
        opacity: status === Image.Ready ? 1.0 : 0.0
        Behavior on opacity { FadeAnimator {} }
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
                                   "displayname": model.account_username,
                                   "username": model.account_acct,
                                   "user_id": model.account_id,
                                   "profileImage": model.account_avatar
                               })
            }

        }
        Image {
            id: iconTR
            anchors {
                top: avatar.bottom
                topMargin: Theme.paddingMedium
                left: avatar.left
            }
            visible: typeof status_reblogged !== "undefined" && status_reblogged
            width: Theme.iconSizeExtraSmall
            height: width
            source: "image://theme/icon-s-retweet"

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
                opacity: status === Image.Ready ? 1.0 : 0.0
                Behavior on opacity { FadeAnimator {} }
                source: typeof reblog_account_avatar !== "undefined" ? reblog_account_avatar : ''
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
            var test = link.split("/")
            console.log(link)
            console.log(JSON.stringify(test))
            console.log(JSON.stringify(test.length))

            if (test.length === 5 && (test[3] === "tags" || test[3] === "tag") ) {
                pageStack.pop(pageStack.find(function(page) {
                    var check = page.isFirstPage === true;
                    if (check)
                        page.onLinkActivated(link)
                    return check;
                }));
                send(link)
            } else if (test.length === 4 && test[3][0] === "@" ) {
                pageStack.push(Qt.resolvedUrl("../Profile.qml"), {
                                   "name": "",
                                   "username": test[3].substring(1),
                                   "profileImage": ""
                               })
            } else {
                pageStack.push(Qt.resolvedUrl("../Browser.qml"), {"href" : link})
            }




        }
        text: content.replace(new RegExp("<a ", 'g'), '<a style="text-decoration: none; color:'+(pressed ?  Theme.secondaryColor : Theme.highlightColor)+'" ')
        textFormat: Text.RichText
        linkColor : Theme.highlightColor
        wrapMode: Text.Wrap
        font.pixelSize: Theme.fontSizeSmall
        color: (pressed ? Theme.highlightColor : (!highlight ? Theme.primaryColor : Theme.secondaryColor))
    }
    MediaBlock {
        id: media
        anchors {
            left: lblContent.left
            right: lblContent.right
            top: lblContent.bottom
            topMargin: Theme.paddingSmall
            bottomMargin: Theme.paddingLarge
        }
        model: typeof attachments !== "undefined" ? attachments : []
        height: 100
    }
    ContextMenu {
        id: mnu
        MenuItem {
            visible: model.type === "retoot" || model.type === "toot"
            text: typeof status_reblogged !== "undefined" && status_reblogged ? qsTr("Unboost") : qsTr("Boost")
            onClicked: {
                var reblogged = typeof status_reblogged !== "undefined" && status_reblogged
                worker.sendMessage({
                                       "conf"   : Logic.conf,
                                       "params" : [],
                                       "method" : "POST",
                                       //"bgAction": true,
                                       "action" : "statuses/"+model.status_id+"/" + (reblogged ? "unreblog" : "reblog")
                                   })
                model['status_reblogged'] = !reblogged
            }
        }
        MenuItem {
            visible: model.type === "retoot" || model.type === "toot"
            text: typeof status_favourited !== "undefined" && status_favourited ? qsTr("Unfavorite") : qsTr("Favorite")
            onClicked: {
                var favourited = typeof status_favourited !== "undefined" && status_favourited
                worker.sendMessage({
                                       "conf"   : Logic.conf,
                                       "params" : [],
                                       "method" : "POST",
                                       //"bgAction": true,
                                       "action" : "statuses/"+model.status_id+"/" + (favourited ? "unfavourite" : "favourite")
                                   })
                model['status_favourited'] = !favourited
            }
        }
    }




    onClicked: {
        var m = Qt.createQmlObject('import QtQuick 2.0; ListModel {   }', Qt.application, 'InternalQmlObject');
        m.append(mdl.get(index))
        pageStack.push(Qt.resolvedUrl("../Conversation.qml"), {
                           toot_id: status_id,
                           title: account_display_name,
                           description: '@'+account_acct,
                           avatar: account_avatar,
                           mdl: m,
                           type: "reply"
                       })
    }
    onPressAndHold: {
        console.log(model['status_reblogged'])
        mnu.show(delegate)
    }
    onDoubleClicked: {
        console.log("double click")
    }
}
