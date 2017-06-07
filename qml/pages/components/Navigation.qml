import QtQuick 2.0
import Sailfish.Silica 1.0
import QtGraphicalEffects 1.0

SilicaGridView {
    signal slideshowShow(int vIndex);
    signal slideshowIndexChanged(int vIndex);
    onSlideshowIndexChanged: {
        navigateTo(vIndex)
    }

    id: gridView
    property bool isPortrait: false
    ListModel {
        id: listModel
        ListElement {
            icon: "../../images/home.svg"
            slug: "timeline"
            name: "Timeline"
            active: true
            unread: false
        }
        ListElement {
            icon: "../../images/home.svg"
            slug: "mentions"
            name: "Mentions"
            active: false
            unread: false
        }
        ListElement {
            icon: "../../images/notification.svg"
            slug: "msgs"
            name: "Messagess"
            active: false
        }
        ListElement {
            icon: "../../images/search.svg"
            slug: "search"
            name: "Search"
            active: false
            unread: false
        }
    }
    model: listModel
    anchors.fill: parent
    currentIndex: -1

    cellWidth: isPortrait ? gridView.width : gridView.width / listModel.count
    cellHeight: isPortrait ? gridView.height/listModel.count : gridView.height


    delegate: BackgroundItem {
        clip: true
        id: rectangle
        width: gridView.cellWidth
        height: gridView.cellHeight
        GridView.onAdd: AddAnimation {
            target: rectangle
        }
        GridView.onRemove: RemoveAnimation {
            target: rectangle
        }
        GlassItem {
            id: effect
            visible: !isPortrait && unread
            width: Theme.itemSizeMedium
            height: Theme.itemSizeMedium
            dimmed: true
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -height/2
            anchors.horizontalCenter: parent.horizontalCenter
            color: Theme.highlightColor
        }

        GlassItem {
            id: effect2
            visible: isPortrait && unread
            width: Theme.itemSizeMedium
            height: Theme.itemSizeMedium
            dimmed: false
            anchors.right: parent.right;
            anchors.rightMargin: -height/2;
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.highlightColor
        }

        OpacityRampEffect {
            sourceItem: label
            offset: 0.5
        }

        /*Image {
            source: model.icon + (highlighted
                                  ? Theme.highlightColor
                                  : (model.active ? Theme.primaryColor : Theme.secondaryHighlightColor))
            anchors.centerIn: parent
        }*/
        Image {
            id: image
            source: model.icon + (highlighted
                                  ? Theme.highlightColor
                                  : (model.active ? Theme.primaryColor : Theme.secondaryHighlightColor))
            anchors.centerIn: parent
            smooth: true
            visible: false
        }
        ColorOverlay {
            anchors.fill: image
            source: image
            color: (highlighted
                    ? Theme.highlightColor
                    : (model.active ? Theme.primaryColor : Theme.secondaryHighlightColor))
        }
        Text {
            anchors.centerIn: parent
            visible: false
            text: model.icon
            color: (highlighted
                    ? Theme.highlightColor
                    : (model.active ? Theme.primaryColor : Theme.secondaryHighlightColor))
        }

        Label {
            id: label
            visible: false
            anchors {
                bottom: parent.bottom
            }
            horizontalAlignment : Text.AlignHCente
            width: parent.width
            color: (highlighted ? Theme.highlightColor : Theme.secondaryHighlightColor)

            text: {
                return model.name.toUpperCase();
            }

            font {
                pixelSize: Theme.fontSizeExtraSmall
                family: Theme.fontFamilyHeading
            }
        }
        onClicked: {
            slideshowShow(index)
            console.log(index)
            navigateTo(model.slug)
            effect.state = "right"
        }

    }
    function navigateTo(slug){
        for(var i = 0; i < listModel.count; i++){
            if (listModel.get(i).slug === slug || i===slug)
                listModel.setProperty(i, 'active', true);
            else
                listModel.setProperty(i, 'active', false);
        }
        console.log(slug)

    }



    VerticalScrollDecorator {}
}
