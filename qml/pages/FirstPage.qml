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
import "../lib/API.js" as Logic


Page {
    id: page

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTrId("Set demo conf")
                onClicked: {
                    Logic.conf['login'] = true
                    Logic.conf['instance'] = "https://mastodon.social";
                    Logic.conf['api_user_token'] = '6d8cb23e3ebf3c7a97dd9adf204e47ad159f1a3d07dbbd0325e98981368d8c51';
                }
            }
            MenuItem {
                text: qsTr("Show Page 2")
                onClicked: pageStack.push(Qt.resolvedUrl("SecondPage.qml"))
            }
        }


        MyList {
            id: myList
            anchors.fill: parent
            model: ListModel {
                id: model
            }
        }
    }

    Component.onCompleted: {
        /*Mastodon.api.post("statuses", {status:"First toot by Tooter - Mastodon client for #SailfishOS"}, function (data) {
            console.log(JSON.stringify(data))
            // will be called if the toot was successful
            // data is the http response object
            //sidenote: please do not actually execute this request, you could be bullied by your friends
        });*/
        var tootParser = function(data){
            console.log(data)
            var ret = {};
            ret.id = data.id
            ret.content = data.content
            ret.created_at = data.created_at
            ret.in_reply_to_account_id = data.in_reply_to_account_id
            ret.in_reply_to_id = data.in_reply_to_id

            ret.user_id = data.account.id
            ret.user_locked = data.account.locked
            ret.username = data.account.username
            ret.display_name = data.account.display_name
            ret.avatar_static = data.account.avatar_static


            ret.favourited = data.favourited ? true : false
            ret.favourites_count = data.favourites_count ? data.favourites_count : 0

            ret.reblog = data.reblog ? true : false
            ret.reblogged = data.reblogged ? true : false
            ret.reblogs_count = data.reblogs_count ? data.reblogs_count : false

            ret.muted = data.muted ? true : false
            ret.sensitive = data.sensitive ? true : false
            ret.visibility = data.visibility ? data.visibility : false
            ret.section = (new Date(ret.created_at)).toLocaleDateString()
            console.log(ret)
            return ret;
        }
        Logic.api.get("timelines/home", [
                          //["since_id", 420],
                          //["max_id", 1337]
                      ], function(data) {
                          // returns all users account id 1 is following in the id range from 420 to 1337
                          // you don't have to supply the parameters, you can also just go with .get(endpoint, callback)
                          //model.append(data)
                          for (var i in data) {
                                              if (data.hasOwnProperty(i)) {
                                                  var toot = tootParser(data[i])
                                                  model.append(toot)
                                              }
                                          }
                          console.log(model.count)
                      });
        console.log(Logic.test)
    }
}

