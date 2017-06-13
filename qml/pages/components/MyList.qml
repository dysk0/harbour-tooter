import QtQuick 2.0
import Sailfish.Silica 1.0
import "../../lib/API.js" as Logic
import "."


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
                } else {
                    Logic.conf['login'] = true
                    Logic.conf['instance'] = "https://mastodon.social";
                    Logic.conf['api_user_token'] = '6d8cb23e3ebf3c7a97dd9adf204e47ad159f1a3d07dbbd0325e98981368d8c51';
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
        criteria: ViewSection.FullString
        delegate: SectionHeader  {
            text: {
                var dat = Date.fromLocaleDateString(locale, created_at);
                dat = Format.formatDate(dat, Formatter.TimepointRelativeCurrentDay)
                if (dat === "00:00:00" || dat === "00:00") {
                    visible = false;
                    height = 0;
                    return  " ";
                }else {
                    return dat;
                }

            }

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
            if (messageObject.notifyNewItems){
                console.log(JSON.stringify(messageObject.notifyNewItems))
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
