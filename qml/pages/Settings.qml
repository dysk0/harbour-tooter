import QtQuick 2.0
import Sailfish.Silica 1.0

import "../lib/API.js" as Logic

Page {
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge
        contentWidth: parent.width
        RemorsePopup { id: remorsePopup }


        VerticalScrollDecorator {}
        Column {
            id: column
            spacing: Theme.paddingSmall
            width: parent.width
            PageHeader {
                title: qsTr("Settings")
            }
            Column {
                // No spacing in this column
                width: parent.width
                IconTextSwitch {
                    id: removeAccount
                    text: Logic.conf['login'] ? qsTr("Remove Account") : qsTr("Add Account")
                    description: Logic.conf['login'] ? qsTr("Deauthorize this app and remove your account") : qsTr("Authorize this app to access your Mastodon account")
                    icon.source: Logic.conf['login'] ? "image://theme/icon-m-contact" : "image://theme/icon-m-add"


                    onCheckedChanged: {
                        remorsePopup.execute(removeAccount.text, function() {
                            busy = true;
                            checked = false;
                            timer1.start();
                            if (Logic.conf['login']) {
                                Logic.conf['login'] = false
                                Logic.conf['instance'] = null;
                                Logic.conf['api_user_token'] = null;
                            }
                            pageStack.push(Qt.resolvedUrl("LoginPage.qml"))
                        })
                    }

                    /*    busy = true;
                        checked = false;
                        timer1.start()

                    }*/
                    Timer {
                        id: timer1
                        interval: 4700
                        onTriggered: parent.busy = false
                    }
                }
                IconTextSwitch {
                    //enabled: false
                    checked: typeof Logic.conf['loadImages'] !== "undefined" && Logic.conf['loadImages']
                    text: qsTr("Load images in toots")
                    description: qsTr("Disable this option if you want to preserve your data connection")
                    icon.source: "image://theme/icon-m-image"
                    onClicked: {
                        Logic.conf['loadImages'] = checked
                    }
                }
                IconTextSwitch {
                    text: qsTr("Translate")
                    description: qsTr("Use Transifex to help with app translation to your language")
                    icon.source: "image://theme/icon-m-font-size"
                    onCheckedChanged: {
                        busy = true;
                        checked = false;
                        Qt.openUrlExternally("https://www.transifex.com/dysko/tooter/");
                        timer2.start()
                    }
                    Timer {
                        id: timer2
                        interval: 4700
                        onTriggered: parent.busy = false
                    }
                }
            }
            SectionHeader {
                text:  qsTr("Credits")
            }

            Column {
                width: parent.width
                anchors {
                    left: parent.left
                    right: parent.right
                    rightMargin: Theme.horizontalPageMargin
                }
                Repeater {
                    model: ListModel {
                        ListElement {
                            name: "Duško Angirević"
                            desc: qsTr("UI/UX design and development")
                            mastodon: "dysko@mastodon.social"
                            mail: ""
                        }
                        ListElement {
                            name: "Miodrag Nikolić"
                            desc: qsTr("Visual identity")
                            mastodon: ""
                            mail: "micotakis@gmail.com"
                        }
                        ListElement {
                            name: "Molan"
                            desc: qsTr("Development and translations")
                            mastodon: ""
                            mail: "mol_an@sunrise.ch"
                        }
                        ListElement {
                            name: "Quentin PAGÈS / Quenti ♏"
                            desc: qsTr("Occitan & French translation")
                            mastodon: "Quenti@framapiaf.org"
                            mail: ""
                        }
                        ListElement {
                            name: "Luchy Kon / dashinfantry"
                            desc: qsTr("Chinese translation")
                            mastodon: ""
                            mail: "dashinfantry@gmail.com"
                        }
                        ListElement {
                            name: "André Koot"
                            desc: qsTr("Dutch translation")
                            mastodon: "meneer@mastodon.social"
                            mail: "https://twitter.com/meneer"
                        }
                        ListElement {
                            name: "CarmenFdez"
                            desc: qsTr("Spanish translation")
                            mastodon: ""
                            mail: ""
                        }
                        ListElement {
                            name: "Mohamed-Touhami MAHDI"
                            desc: qsTr("Added README file")
                            mastodon: "dragnucs@touha.me"
                            mail: "touhami@touha.me"
                        }
                    }

                    Item {
                        width: parent.width
                        height: Theme.itemSizeMedium
                        IconButton {
                            id: btn
                            anchors {
                                verticalCenter: parent.verticalCenter
                                right: parent.right
                            }
                            icon.source: "image://theme/" + (model.mastodon !== "" ? "icon-m-contact" : "icon-m-mail") + "?" + (pressed
                                                                                                                               ? Theme.highlightColor
                                                                                                                               : Theme.primaryColor)
                            onClicked: {
                                if (model.mastodon !== ""){
                                    var m = Qt.createQmlObject('import QtQuick 2.0; ListModel {   }', Qt.application, 'InternalQmlObject');
                                    pageStack.push(Qt.resolvedUrl("Conversation.qml"), {
                                                       toot_id: 0,
                                                       title: model.name,
                                                       description: '@'+model.mastodon,
                                                       avatar: "",
                                                       mdl: m,
                                                       type: "reply"
                                                   })
                                } else {
                                    Qt.openUrlExternally("mailto:"+model.mail);
                                }
                            }
                        }
                        Column {
                            anchors {
                                verticalCenter: parent.verticalCenter
                                left: parent.left
                                leftMargin: Theme.horizontalPageMargin
                                right: btn.left
                                rightMargin: Theme.paddingMedium
                            }

                            Label {
                                id: lblName
                                text: model.name
                                color: Theme.secondaryColor
                                font.pixelSize: Theme.fontSizeSmall
                            }
                            Label {
                                text: model.desc
                                color: Theme.secondaryHighlightColor
                                font.pixelSize: Theme.fontSizeExtraSmall
                            }
                        }
                    }
                }
            }
        }
    }
}
