/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import QtWebKit 3.0
import Sailfish.Silica 1.0
import "../lib/API.js" as Logic



Page {
    id: loginPage

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All



    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        VerticalScrollDecorator {}

        Column {
            id: column
            width: parent.width

            PageHeader { title: qsTr("Login") }

            SectionHeader {
                text: qsTr("Instance")
            }

            TextField {
                id: instance
                focus: true
                label: qsTr("Enter an Mastodon instance URL")
                placeholderText: "https://mastodon.social"
                width: parent.width
                validator: RegExpValidator { regExp: /^(ftp|http|https):\/\/[^ "]+$/ }
                EnterKey.enabled: instance.acceptableInput;
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: {
                    Logic.api = new Logic.MastodonAPI({ instance: instance.text, api_user_token: "" });
                    Logic.api.registerApplication("Tooter",
                                    'http://localhost/harbour-tooter', // redirect uri, we will need this later on
                                    ["read", "write", "follow"], //scopes
                                    "http://grave-design.com/harbour-tooter", //website on the login screen
                                    function(data) {

                                        console.log(data)
                                        var conf = JSON.parse(data)
                                        conf.instance = instance.text;
                                        conf.login = false;


                                        /*conf['login'] = false;
                                        conf['mastodon_client_id'] = data['mastodon_client_id'];
                                        conf['mastodon_client_secret'] = data['mastodon_client_secret'];
                                        conf['mastodon_client_redirect_uri'] = data['mastodon_client_redirect_uri'];
                                        delete Logic.conf;*/
                                        Logic.conf = conf;
                                        console.log(JSON.stringify(conf))
                                        console.log(JSON.stringify(Logic.conf))
                                        // we got our application

                                        // our user to it!
                                        var url = Logic.api.generateAuthLink(Logic.conf["client_id"],
                                            Logic.conf["redirect_uri"],
                                            "code", // oauth method
                                            ["read", "write", "follow"] //scopes
                                        );
                                        console.log(url)
                                        webView.url = url
                                        webView.visible = true
                                    }
                                );
                }
            }
            Label {
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.paddingLarge
                    rightMargin: Theme.paddingLarge
                }

                width: parent.width
                wrapMode: Text.WordWrap
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeExtraSmall
                text: qsTr("Mastodon is a free, open-source social network. A decentralized alternative to commercial platforms, it avoids the risks of a single company monopolizing your communication. Pick a server that you trust — whichever you choose, you can interact with everyone else. Anyone can run their own Mastodon instance and participate in the social network seamlessly.")
            }


        }

    }

    SilicaWebView {
        id: webView
        visible: false
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        opacity: 0
        onLoadingChanged: {
            console.log(url)
            if (
                    (url+"").substr(0, 37) === 'http://localhost/harbour-tooter?code=' ||
                    (url+"").substr(0, 38) === 'https://localhost/harbour-tooter?code='
             ) {
                visible = false;
                var authCode = (url+"").substr(-64)
                console.log(authCode)

                Logic.api.getAccessTokenFromAuthCode(
                                    Logic.conf["client_id"],
                                    Logic.conf["client_secret"],
                                    Logic.conf["redirect_uri"],
                                    authCode,
                                    function(data) {
                                        // AAAND DATA CONTAINS OUR TOKEN!
                                        console.log(data)
                                        data = JSON.parse(data)
                                        console.log(JSON.stringify(data))
                                        console.log(JSON.stringify(data.access_token))
                                        Logic.conf["api_user_token"] = data.access_token
                                        Logic.conf["login"] = true;
                                        Logic.api.setConfig("api_user_token", Logic.conf["api_user_token"])
                                        pageStack.replace(Qt.resolvedUrl("MainPage.qml"), {})
                                    }
                                )
            }


            switch (loadRequest.status)
            {
            case WebView.LoadSucceededStatus:
                opacity = 1
                break
            case WebView.LoadFailedStatus:
                //opacity = 0
                break
            default:
                //opacity = 0
                break
            }
        }

        FadeAnimation on opacity {}
        PullDownMenu {
            MenuItem {
                text: qsTr("Reload")
                onClicked: webView.reload()
            }
        }
    }
}

