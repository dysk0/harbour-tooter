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
import Sailfish.Silica 1.0
import "pages"
import "./lib/API.js" as Logic

ApplicationWindow
{
    id: appWindow
    //initialPage: Component { FirstPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations
    Component.onCompleted: {
        var obj = {};
        Logic.mediator.installTo(obj);
        obj.subscribe('confLoaded', function(){
            console.log('confLoaded');
            //console.log(JSON.stringify(Logic.conf))
            if (!Logic.conf['notificationLastID'])
                Logic.conf['notificationLastID'] = 0;
            if (Logic.conf['instance']) {
                Logic.api = new Logic.MastodonAPI({ instance: Logic.conf['instance'], api_user_token: "" });
            }
            if (Logic.conf['login']) {
                //Logic.conf['notificationLastID'] = 0
                Logic.api.setConfig("api_user_token", Logic.conf['api_user_token'])
                //accounts/verify_credentials
                Logic.api.get('instance', [], function(data) {
                    console.log(JSON.stringify(data))
                    pageStack.push(Qt.resolvedUrl("./pages/MainPage.qml"), {})
                });

                //
                //
                //pageStack.push(Qt.resolvedUrl("./pages/Conversation.qml"), {})
            } else {
                pageStack.push(Qt.resolvedUrl("./pages/LoginPage.qml"), {})
            }


        });
        Logic.init()
    }

    Component.onDestruction: {
        //Logic.conf.notificationLastID = 0;
        Logic.saveData()
    }
    Connections
        {
            target: Dbus
            onViewtoot:
            {
                console.log(key, "dbus onViewtoot")
            }
            onActivateapp:
            {
                console.log ("dbus activate app")
                pageStack.pop(pageStack.find( function(page){ return (page._depth === 0) }))
                activate()
            }
        }
}

