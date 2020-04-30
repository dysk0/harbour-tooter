import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: header
    property int value: 0;
    property string title: "";
    property string description: "";
    property string image: "";
    property string bg: "";
    width: parent.width
    height: icon.height + Theme.paddingLarge*2
    /*Image {
        anchors.fill: parent
        asynchronous: true
        fillMode: Image.PreserveAspectCrop
        source: bg
        opacity: 0.3
    }*/
    Rectangle {
        anchors.fill: parent
        opacity: 0.2
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.highlightBackgroundColor }
            GradientStop { position: 1.0; color: Theme.highlightBackgroundColor  }
        }

    }
    Image {
        id: icon
        anchors {
            left: parent.left
            leftMargin: Theme.paddingLarge
            top: parent.top
            topMargin: Theme.paddingLarge
        }
        asynchronous: true
        width: description === "" ? Theme.iconSizeMedium : Theme.iconSizeLarge
        height: width
        source:
        if (icon.status === Image.Error)
            source = "../../images/icon-l-profile.svg?" + (pressed
             ? Theme.highlightColor
             : Theme.primaryColor)
        else image
    }
    Column {
        anchors {
            left: icon.right
            leftMargin: Theme.paddingLarge
            right: parent.right
            rightMargin: Theme.paddingLarge
            verticalCenter: parent.verticalCenter
        }
        Label {
            id: ttl
            text: title
            height: contentHeight
            color: Theme.primaryColor
            font.pixelSize: Theme.fontSizeLarge
            font.family: Theme.fontFamilyHeading
            horizontalAlignment: Text.AlignRight
            truncationMode: TruncationMode.Fade
            width: parent.width
        }
        Label {
            height: description === "" ? 0 : contentHeight
            text: description
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeSmall
            font.family: Theme.fontFamilyHeading
            horizontalAlignment: Text.AlignRight
            truncationMode: TruncationMode.Fade
            width: parent.width
        }
    }

}
