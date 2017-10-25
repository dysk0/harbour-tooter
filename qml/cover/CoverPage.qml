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
import org.nemomobile.notifications 1.0;

import "../lib/API.js" as Logic

CoverBackground {
    onStatusChanged: {
        switch (status ){
        case PageStatus.Activating:
            console.log("PageStatus.Activating")
            timer.triggered()
            break;
        case PageStatus.Inactive:
            timer.triggered()
            console.log("PageStatus.Inactive")
            break;
        }
    }
    Image {
        id: bg
        anchors {
            bottom : parent.bottom
            left: parent.left
            right: parent.right
            top: parent.top
        }
        horizontalAlignment: Image.AlignLeft
        verticalAlignment: Image.AlignBottom
        fillMode: Image.PreserveAspectFit

        source: "../images/tooter.svg"
    }
    Timer {
        id: timer
        interval: 60*1000
        triggeredOnStart: true
        repeat: true
        onTriggered: checkNotifications();
    }

    Image {
        id: iconNot
        anchors {
            left: parent.left
            top: parent.top
            leftMargin: Theme.paddingLarge
            topMargin: Theme.paddingLarge
        }
        source: "image://theme/icon-s-alarm?" + Theme.highlightColor
    }
    Label {
        id: notificationsLbl
        anchors {
            left: iconNot.right
            leftMargin: Theme.paddingMedium
            verticalCenter: iconNot.verticalCenter
        }
        text: " "
        color: Theme.highlightColor
    }

    Label {
        anchors {
            right: parent.right
            rightMargin: Theme.paddingLarge
            verticalCenter: iconNot.verticalCenter
        }
        text: "Tooter"
        color: Theme.primaryColor
    }

    /*CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-next"
             onTriggered: {
                 label.text = Logic.modelTLhome.count
             }
        }

        CoverAction {
            iconSource: "image://theme/icon-cover-pause"
        }
    }*/
    function checkNotifications(){
        console.log("checkNotifications")
        var notificationsNum = 0
        var notificationLastID = Logic.conf.notificationLastID;
        //Logic.conf.notificationLastID = 0;
        for(var i = 0; i < Logic.modelTLnotifications.count; i++) {
            if (notificationLastID < Logic.modelTLnotifications.get(i).id) {
                notificationLastID = Logic.modelTLnotifications.get(i).id
            }

            if (Logic.conf.notificationLastID < Logic.modelTLnotifications.get(i).id) {
                notificationsNum++
                var item = Logic.modelTLnotifications.get(i);
                item.content = item.content.replace(/(<([^>]+)>)/ig,"").replaceAll("&quot;", "\"").replaceAll("&amp;", "&")
                //Logic.notifier())
                switch (item.type){
                    case "favourite":
                        //Notifications.notify("Tooter", "serverinfo.serverTitle", (item.reblog_account_display_name !== "" ? item.reblog_account_display_name : '@'+item.reblog_account_username) + ' ' + qsTrId("favourited"), false, item.created_at.getTime()/1000|0, "")
                        ntf.urgency = Notification.Normal
                        ntf.timestamp = item.created_at
                        ntf.summary = (item.reblog_account_display_name !== "" ? item.reblog_account_display_name : '@'+item.reblog_account_username) + ' ' + qsTr("favourited")
                        ntf.body = item.content
                        break;
                    case "follow":
                        ntf.urgency = Notification.Critical
                        ntf.timestamp = item.created_at
                        ntf.summary = (item.account_display_name !== "" ? item.account_display_name : '@'+item.account_username)
                        ntf.body = qsTr("followed you")
                        ntf.remoteActions[0].method = "showtoot"
                        ntf.remoteActions[0].arguments = ["user", ntf.summary]
                        break;
                    case "reblog":
                        ntf.urgency = Notification.Low
                        ntf.timestamp = item.created_at
                        ntf.summary = (item.reblog_account_display_name !== "" ? item.reblog_account_display_name : '@'+item.reblog_account_username) + ' ' + qsTr("boosted")
                        ntf.body = item.content
                        ntf.remoteActions[0].method = "showtoot"
                        ntf.remoteActions[0].arguments = ["toot", item.id]
                        break;
                }
                ntf.replacesId = 0;
                ntf.publish();
            }
        }
        notificationsLbl.text = notificationsNum;
        Logic.conf.notificationLastID = notificationLastID;
    }
    Notification {
        id: ntf
        category: "x-harbour.tooter.activity"
        appName: "Tooter"
        appIcon: "/usr/share/harbour-tooter/config/icon-lock-harbour-tooter.png"
        summary: "Notification summary"
        body: "Notification body"
        previewSummary: summary
        previewBody: body
        itemCount: 1
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
}

