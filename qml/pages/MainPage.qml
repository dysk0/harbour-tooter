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
import "./components/"


Page {
    id: mainPage

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    DockedPanel {
        id: infoPanel
        open: true
        width: mainPage.isPortrait ? parent.width : Theme.itemSizeLarge
        height: mainPage.isPortrait ? Theme.itemSizeLarge : parent.height
        dock: mainPage.isPortrait ? Dock.Bottom : Dock.Right
        Navigation {
            id: navigation
            isPortrait: !mainPage.isPortrait
            onSlideshowShow: {
                console.log(vIndex)
                slideshow.positionViewAtIndex(vIndex, ListView.SnapToItem)
            }
        }
    }

    SlideshowView {
        id: slideshow
        width: parent.width
        height: parent.height
        itemWidth: parent.width
        clip: true
        onCurrentIndexChanged: {
            navigation.slideshowIndexChanged(currentIndex)
        }

        anchors {
            fill: parent
            leftMargin: 0
            top: parent.top
            topMargin: 0
            rightMargin: mainPage.isPortrait ? 0 : infoPanel.visibleSize
            bottomMargin: mainPage.isPortrait ? infoPanel.visibleSize : 0
        }
        model: VisualItemModel {
            MyList{
                id: tlHome;
                title: qsTr("Home")
                type: "timelines/home"
                mdl: Logic.modelTLhome
                width: parent.width
                height: parent.height
                onOpenDrawer:  infoPanel.open = setDrawer
            }
            MyList{
                id: tlPublic;
                title: qsTr("Timeline")
                type: "timelines/public"
                mdl: Logic.modelTLpublic
                width: parent.width
                height: parent.height
                onOpenDrawer:  infoPanel.open = setDrawer
            }
            MyList{
                id: tlNotifications;
                title: qsTr("Notifications")
                type: "notifications"
                mdl: Logic.modelTLnotifications
                width: parent.width
                height: parent.height
                onOpenDrawer:  infoPanel.open = setDrawer
                delegate: Notification {}
            }
            /*
            MyList{
                id: timeline2;
                width: parent.width
                height: parent.height
                model: 0
                onOpenDrawer:  infoPanel.open = setDrawer
            }
            MyList{
                id: timeline3;
                width: parent.width
                height: parent.height
                model: 30
                onOpenDrawer:  infoPanel.open = setDrawer
            }
            MyList{
                id: timeline4;
                width: parent.width
                height: parent.height
                model: 4
                onOpenDrawer:  infoPanel.open = setDrawer
            }*/

        }

    }


    Component.onCompleted: {
        /*Mastodon.api.post("statuses", {status:"First toot by Tooter - Mastodon client for #SailfishOS"}, function (data) {
            console.log(JSON.stringify(data))
            // will be called if the toot was successful
            // data is the http response object
            //sidenote: please do not actually execute this request, you could be bullied by your friends
        });*/

        /*Logic.api.get("timelines/home", [
                          //["since_id", 420],
                          //["max_id", 1337]
                      ], function(data) {
                          // returns all users account id 1 is following in the id range from 420 to 1337
                          // you don't have to supply the parameters, you can also just go with .get(endpoint, callback)
                          //model.append(data)
                          for (var i in data) {
                                              if (data.hasOwnProperty(i)) {
                                                  console.log(JSON.stringify(data[i]))
                                              }
                                          }

                      });*/
        console.log(Logic.test)
    }
}

