import QtQuick 2.2
import Sailfish.Silica 1.0
import "../../lib/API.js" as Logic
import "."

import org.nemomobile.notifications 1.0;

SilicaListView {
    id: myList
    property string type;
    property string title
    property string description
    property ListModel mdl: []
    property variant params: []
    property var locale: Qt.locale()
    property bool loadStarted : false;
    property int scrollOffset;
    property string action: ""
    property variant vars
    property variant conf
    property bool notifier : false;
    model:  mdl
    signal notify (string what, int num)
    onNotify: {
        console.log(what + " - " + num)
    }



    signal openDrawer (bool setDrawer)
    onOpenDrawer: {
        //console.log("Open drawer: " + setDrawer)
    }
    signal send (string notice)
    onSend: {
        console.log("LIST send signal emitted with notice: " + notice)
    }


    BusyIndicator {
        size: BusyIndicatorSize.Large
        running: myList.model.count === 0 && !viewPlaceHolder.visible
        anchors.centerIn: parent
    }

    header: PageHeader {
        title: myList.title
        description: myList.description
    }



    ViewPlaceholder {
        id: viewPlaceHolder
        enabled: model.count === 0
        text: ""
        hintText: ""
    }

    PullDownMenu {
        MenuItem {
            text: "NOTIFIKACIJA"
            onClicked: {
                Logic.notifier({
                                   type: "follow",
                                   urgency: "critical",
                                   created_at: new Date(),
                                   account_display_name: '@muo',
                                   reblog_account_display_name: "@akakakak",
                                   content: "blaaaaaa blaaaaaablaaaaaablaaaaaa"

                               })
            }
        }
        MenuItem {
            text: "NOTIFIKACIJA2"
            onClicked: {

                Logic.notifier({
                                   type: "reblog",
                                   urgency: "critical",
                                   created_at: new Date(),
                                   account_display_name: '@muowww',
                                   reblog_account_display_name: "@akakwwakak",
                                   content: "blaaaaaa blaaaaawwwablaaaaaablaaaaaa"

                               })
            }
        }
        MenuItem {
            text: qsTr("Settings")
            onClicked: {
                pageStack.push(Qt.resolvedUrl("../Settings.qml"), {})
            }
        }

        MenuItem {
            text: qsTr("Load more")
            onClicked: {
                loadData("prepend")
            }
        }
    }
    /*PushUpMenu {
        MenuItem {
            text: qsTr("Load more")
            onClicked: {
                loadData("append")
            }
        }
    }*/
    clip: true
    section {
        property: 'section'
        delegate: SectionHeader  {
            height: Theme.itemSizeExtraSmall
            text: Format.formatDate(section, Formatter.DateMedium)
        }
    }

    delegate: VisualContainer {
    } //Toot {}

    add: Transition {
        NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: 800 }
        NumberAnimation { property: "x"; duration: 800; easing.type: Easing.InOutBack }
    }

    remove: Transition {
        NumberAnimation { properties: "x,y"; duration: 800; easing.type: Easing.InOutBack }
    }

    onCountChanged: {
        loadStarted = false;
        /*contentY = scrollOffset
        console.log("CountChanged!")*/

    }
    Button {
        Notification {
            id: notification
            category: "x-harbour.tooter.activity"
            appName: "Tooter"
            appIcon: "/usr/share/harbour-tooter/config/icon-lock-harbour-tooter.png"
            summary: "Notification summary"
            body: "Notification body"
            previewSummary: "Notification preview summary"
            previewBody: "Notification preview body"
            itemCount: 5
            timestamp: "2013-02-20 18:21:00"
            remoteActions: [ {
                    "name": "default",
                    "displayName": "Do something",
                    "icon": "icon-s-certificates",
                    "service": "ba.dysko.harbour.tooter",
                    "path": "/",
                    "iface": "ba.dysko.harbour.tooter",
                    "method": "openapp",
                    "arguments": [  ]
                }]
            onClicked: console.log("Clicked")
            onClosed: console.log("Closed, reason: " + reason)
        }
        text: "Application notification" + (notification.replacesId ? " ID:" + notification.replacesId : "")
        onClicked: notification.publish()
    }
    footer: Item{
        width: parent.width
        height: Theme.itemSizeLarge
        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: Theme.paddingSmall
            anchors.bottomMargin: Theme.paddingLarge
            visible: false
            onClicked: {
                loadData("append")
            }
        }
        BusyIndicator {
            size: BusyIndicatorSize.Small
            running: loadStarted;
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
    onContentYChanged: {

        if (Math.abs(contentY - scrollOffset) > Theme.itemSizeMedium) {
            openDrawer(contentY - scrollOffset  > 0 ? false : true )
            scrollOffset = contentY
        }

        if(contentY+height > footerItem.y && !loadStarted){
            loadData("append")
            loadStarted = true;
        }
    }
    VerticalScrollDecorator {}

    WorkerScript {
        id: worker
        source: "../../lib/Worker.js"
        onMessage: {
            if (messageObject.error){
                console.log(JSON.stringify(messageObject))
            }
            if (messageObject.fireNotification && notifier){
                Logic.notifier(messageObject.data)
            }

        }
    }

    Component.onCompleted: {
        loadData("prepend")
    }

    Timer {
        triggeredOnStart: false; interval: 5*60*1000; running: true; repeat: true
        onTriggered: {
            console.log(title + ' ' +Date().toString())
            loadData("prepend")
        }
    }
    function loadData(mode){
        var p = [];
        if (mode === "append" && model.count){
            p.push({name: 'max_id', data: model.get(model.count-1).id});
        }
        if (mode === "prepend" && model.count){
            p.push({name:'since_id', data: model.get(0).id});
        }

        var msg = {
            'action'    : type,
            'params'    : p,
            'model'     : model,
            'mode'      : mode,
            'conf'      : Logic.conf
        };
        if (type !== "")
            worker.sendMessage(msg);
    }
}
