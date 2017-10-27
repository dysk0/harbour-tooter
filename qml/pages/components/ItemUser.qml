import QtQuick 2.0
import Sailfish.Silica 1.0
import QtGraphicalEffects 1.0

BackgroundItem {
    id: delegate
    //property string text: "0"
    height: Theme.itemSizeMedium
    width: parent.width

    Image {
        id: avatar
        width: Theme.itemSizeExtraSmall
        height: width
        source: model.account_avatar
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Theme.horizontalPageMargin
        MouseArea {
            anchors.fill: parent
            onClicked: pageStack.push(Qt.resolvedUrl("./../Profile.qml"), {
                                          "displayname": model.account_username,
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
}
