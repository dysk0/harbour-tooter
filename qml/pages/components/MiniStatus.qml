import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: ministatus
    visible: true
    height: icon.height+Theme.paddingMedium
    width: parent.width
    Image {
        id: icon
        anchors {
            top: parent.top
            topMargin: Theme.paddingMedium
            bottomMargin: Theme.paddingMedium
            left: parent.left
            leftMargin: Theme.horizontalPageMargin + Theme.iconSizeMedium - width
        }
        visible: type.length
        width: Theme.iconSizeExtraSmall
        height: width
        source: typeof typeIcon !== "undefined" ? typeIcon : ""

    }
    Label {
        id: lblRtByName
        visible: type.length
        anchors {
            left: icon.right
            leftMargin: Theme.paddingMedium
            verticalCenter: icon.verticalCenter
        }
        text: {
            var action = "";
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
                ministatus.visible = false
                action = type;
            }
            return typeof reblog_account_username !== "undefined" ? '@' + reblog_account_username + ' ' +  action : ''
        }

        font.pixelSize: Theme.fontSizeExtraSmall
        color: Theme.highlightColor
    }
}
