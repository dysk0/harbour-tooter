import QtQuick 2.0
import Sailfish.Silica 1.0


BackgroundItem {
    id: delegate
    signal openUser (string notice)
    height: Theme.itemSizeMedium
    width: parent.width

    Rectangle {
        id: avatar
        width: Theme.itemSizeExtraSmall
        height: width
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Theme.horizontalPageMargin
        color: Theme.highlightDimmerColor
        Image {
            id: img
            opacity: status === Image.Ready ? 1.0 : 0.0
            Behavior on opacity { FadeAnimator {} }
            anchors.fill: parent
            source: model.account_avatar
        }
        BusyIndicator {
            size: BusyIndicatorSize.Small
            opacity: img.status === Image.Ready ? 0.0 : 1.0
            Behavior on opacity { FadeAnimator {} }
            running: avatar.status !== Image.Ready;
            anchors.centerIn: parent
        }
        MouseArea {
            anchors.fill: parent
            onClicked: pageStack.push(Qt.resolvedUrl("./../Profile.qml"), {
                                          "display_name": model.account_display_name,
                                          "username": model.account_acct,
                                          "user_id": model.account_id,
                                          "profileImage": model.account_avatar
                                      })
        }
    }
    Column {
        anchors.left: avatar.right
        anchors.leftMargin: Theme.paddingLarge
        anchors.verticalCenter: parent.verticalCenter
        height: account_acct.height + display_name.height
        Label {
            id: display_name
            text: model.account_display_name+" "
            color: !pressed ?  Theme.primaryColor : Theme.highlightColor
            font.pixelSize: Theme.fontSizeSmall
        }
        Label {
            id: account_acct
            text: "@"+model.account_acct
            color: !pressed ?  Theme.secondaryColor : Theme.secondaryHighlightColor
            anchors.leftMargin: Theme.paddingMedium
            font.pixelSize: Theme.fontSizeExtraSmall
        }
    }
    onClicked: openUser({
                            "display_name": model.account_display_name,
                            "username": model.account_acct,
                            "user_id": model.account_id,
                            "profileImage": model.account_avatar
                        })
}
