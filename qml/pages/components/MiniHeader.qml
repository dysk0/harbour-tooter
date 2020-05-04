import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: miniheader
    height: lblName.height
    width: parent.width

    Label {
        id: lblName
        anchors {
            left: parent.left
            leftMargin: Theme.paddingMedium
        }
        text:
            if (account_display_name === "") {
            account_username.split('@')[0]
            }
            else account_display_name
        width: contentWidth > parent.width /2 ? parent.width /2 : contentWidth
        truncationMode: TruncationMode.Fade
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

        id: lblDate
        color: (pressed ? Theme.highlightColor : Theme.primaryColor)
        text: Format.formatDate(created_at, new Date() - created_at < 60*60*1000 ? Formatter.DurationElapsedShort : Formatter.TimeValueTwentyFourHours)
        font.pixelSize: Theme.fontSizeExtraSmall
        horizontalAlignment: Text.AlignRight
        anchors {
            right: parent.right
            baseline: lblName.baseline
            rightMargin: Theme.horizontalPageMargin
        }
    }
}
