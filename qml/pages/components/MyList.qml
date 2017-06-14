import QtQuick 2.0
import Sailfish.Silica 1.0
import "../../lib/API.js" as Logic
import "."
import org.nemomobile.notifications 1.0


SilicaListView {



    Notification {
        id: notification
        category: "x-nemo.example"
        urgency: Notification.Normal
        onClicked: console.log("Clicked")
    }

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
            text: Logic.conf['login'] ? qsTrId("Logout"): qsTrId("Login")
            onClicked: {
                if (Logic.conf['login']) {
                    Logic.conf['login'] = false
                    Logic.conf['instance'] = null;
                    Logic.conf['api_user_token'] = null;
                    Logic.conf['dysko'] = null;
                }
            }
        }

        MenuItem {
            text: qsTr("Load more")
            onClicked: {
                loadData("prepend")
            }
        }
    }
    PushUpMenu {
        MenuItem {
            text: qsTr("Load more")
            onClicked: {
                loadData("append")
            }
        }
    }
    clip: true
    section {
        property: 'section'
        delegate: SectionHeader  {
            text: section
        }
    }

    delegate: VisualContainer {} //Toot {}

    add: Transition {
        NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: 800 }
        NumberAnimation { property: "x"; duration: 800; easing.type: Easing.InOutBack }
    }

    displaced: Transition {
        NumberAnimation { properties: "x,y"; duration: 800; easing.type: Easing.InOutBack }
    }

    onCountChanged: {
        contentY = scrollOffset
        console.log("CountChanged!")

        //last_id_MN

    }
    onContentYChanged: {

        if (contentY > scrollOffset) {
            openDrawer(false)

        } else {
            if (contentY < 100 && !loadStarted){
            }
            openDrawer(true)
        }
        scrollOffset = contentY
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
        var msg = {
            'action'    : type,
            'params'    : [ ],
            'model'     : model,
            'mode'      : "append",
            'conf'      : Logic.conf
        };
        worker.sendMessage(msg);
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
        worker.sendMessage(msg);
    }
}
