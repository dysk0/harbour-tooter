import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/API.js" as Logic
import "./components/"
import QtGraphicalEffects 1.0

Page {
    property ListModel tweets;
    property string display_name : "";
    property string username : "";
    property string profileImage : "";
    property int user_id;
    property int statuses_count;
    property int following_count;
    property int followers_count;
    property int favourites_count;
    property int reblogs_count;
    property int count_moments;
    property string profile_background: "";
    property string note: "";
    property string url: "";

    property bool locked : false;
    property date created_at;
    property bool following : false;
    property bool requested : false;
    property bool followed_by : false;
    property bool blocking : false;
    property bool muting : false;
    property bool domain_blocking : false;


    WorkerScript {
        id: worker
        source: "../lib/Worker.js"
        onMessage: {
            console.log(JSON.stringify(messageObject))
            if(messageObject.action.indexOf("accounts/search") > -1 ){
                user_id = messageObject.data.id
                followers_count = messageObject.data.followers_count
                following_count = messageObject.data.following_count
                username = messageObject.data.acct
                display_name = messageObject.data.display_name
                profileImage = messageObject.data.avatar_static

                var msg = {
                    'action'    : "accounts/relationships/",
                    'params'    : [ {name: "id", data: user_id}],
                    'conf'      : Logic.conf
                };
                worker.sendMessage(msg);
                list.loadData("prepend")
            }

            if(messageObject.action === "accounts/relationships/"){
                console.log(JSON.stringify(messageObject))
                following= messageObject.data.following
                requested= messageObject.data.requested
                followed_by= messageObject.data.followed_by
                blocking= messageObject.data.blocking
                muting= messageObject.data.muting
                domain_blocking= messageObject.data.domain_blocking
            }
            switch (messageObject.key) {
            case 'followers_count':
                followers_count = messageObject.data
                break;
            case 'following_count':
                following_count = messageObject.data
                break;
            case 'acct':
                // line below was commented out, reason unknown
                // username = messageObject.data
                break;
            case 'locked':
                locked = messageObject.data
                break;
            case 'created_at':
                created_at = messageObject.data
                break;
            case 'statuses_count':
                statuses_count = messageObject.data
                break;
            case 'note':
                note = messageObject.data
                break;
            case 'url':
                url = messageObject.data
                break;
            case 'following':
                following = messageObject.data
                followers_count = followers_count + (following ? 1 : - 1)
                break;
            case 'muting':
                muting = messageObject.data
                break;
            case 'muting':
                muting = messageObject.data
                break;
            case 'blocking':
                blocking = messageObject.data
                followers_count = followers_count + (blocking ? -1 : 0)
                break;
            case 'followed_by':
                followed_by = messageObject.data
                break;
            }
        }
    }
    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All
    Component.onCompleted: {
        var msg;

        if (user_id) {
            msg = {
                'action'    : "accounts/relationships/",
                'params'    : [ {name: "id", data: user_id}],
                'conf'      : Logic.conf
            };
            worker.sendMessage(msg);
            msg = {
                'action'    : "accounts/"+user_id,
                'conf'      : Logic.conf
            };
            worker.sendMessage(msg);
        } else {
            var instance = Logic.conf['instance'].split("//")
            msg = {
                'action'    : "accounts/search?limit=1&q="+username.replace("@"+instance[1], ""),
                'conf'      : Logic.conf
            };
            worker.sendMessage(msg);
        }
    }



    MyList {
        id: list
        header: ProfileHeader {
            id: header
            title: display_name
            description: '@'+username
            image: profileImage
        }

        anchors {
            top: parent.top
            bottom: expander.top
            left: parent.left
            right: parent.right
        }
        clip: true

        mdl: ListModel {}
        type: "accounts/"+user_id+"/statuses"
        vars: {}
        conf: Logic.conf
    }


    ExpandingSectionGroup {
        id: expander
        //currentIndex: 0
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        ExpandingSection {
            title: qsTr("Summary")
            content.sourceComponent: Column {
                spacing: Theme.paddingMedium
                anchors.bottomMargin: Theme.paddingLarge
                DetailItem {
                    visible: followers_count ? true : false
                    label: qsTr("Followers")
                    value: followers_count
                }
                DetailItem {
                    visible: following_count ? true : false
                    label: qsTr("Following")
                    value: (following_count)
                }
                DetailItem {
                    visible: statuses_count ? true : false
                    label: qsTr("Statuses")
                    value: (statuses_count)
                }
                DetailItem {
                    visible: favourites_count ? true : false
                    label: qsTr("Favourites")
                    value: (favourites_count)
                }

                Column {
                    spacing: Theme.paddingMedium
                    anchors.horizontalCenter:     parent.horizontalCenter
                    Button {
                        id: btnFollow
                        text: (following ? qsTr("Unfollow") : (requested ? qsTr("Follow request sent!") : qsTr("Follow")))
                        onClicked: {
                            var msg = {
                                'method'    : 'POST',
                                'params'    : [],
                                'action'    : "accounts/" + user_id + (following ? '/unfollow':'/follow'),
                                'conf'      : Logic.conf
                            };
                            worker.sendMessage(msg);
                        }
                    }
                    Button {
                        id: btnMute
                        text: (muting ?  qsTr("Unmute") : qsTr("Mute"))
                        onClicked: {
                            var msg = {
                                'method'    : 'POST',
                                'params'    : [],
                                'action'    : "accounts/" + user_id + (muting ? '/unmute':'/mute'),
                                'conf'      : Logic.conf
                            };
                            worker.sendMessage(msg);
                        }
                    }
                    Button {
                        id: btnBlock
                        text: (blocking ? qsTr("Unblock") : qsTr("Block") )
                        onClicked: {
                            var msg = {
                                'method'    : 'POST',
                                'params'    : [],
                                'action'    : "accounts/" + user_id + (blocking ? '/unblock':'/block'),
                                'conf'      : Logic.conf
                            };
                            worker.sendMessage(msg);
                        }
                    }
                }
                Label {
                    text: " "
                }
            }

        }
        ExpandingSection {
            title: qsTr("Bio")
            content.sourceComponent: Column {
                spacing: Theme.paddingMedium
                anchors.bottomMargin: Theme.paddingLarge
                Text {
                    x: Theme.horizontalPageMargin
                    width: parent.width  - ( 2 * Theme.horizontalPageMargin )
                    id: txtnote
                    text: note
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                    linkColor: Theme.secondaryHighlightColor
                    wrapMode: Text.Wrap
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                    }
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
                            tlSearch.search = decodeURIComponent("@"+test[3].substring(1)+"@"+test[2])
                            slideshow.positionViewAtIndex(4, ListView.SnapToItem)
                            navigation.navigateTo('search')

                        } else {
                            Qt.openUrlExternally(link);
                        }
                    }

                }
                Column {
                    spacing: Theme.paddingMedium
                    anchors.horizontalCenter:     parent.horizontalCenter
                    Button {
                        id: btnUrl
                        text: qsTr("Open Profile in Browser")
                        onClicked: {
                            Qt.openUrlExternally(url);
                            }
                        }
                    }
                Label {
                    text: " "
                }
               }
        }
    }



}
