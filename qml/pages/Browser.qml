/****************************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Raine Makelainen <raine.makelainen@jollamobile.com>
** All rights reserved.
**
** This file is part of Sailfish Silica UI component package.
**
** You may use this file under the terms of BSD license as follows:
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are met:
**     * Redistributions of source code must retain the above copyright
**       notice, this list of conditions and the following disclaimer.
**     * Redistributions in binary form must reproduce the above copyright
**       notice, this list of conditions and the following disclaimer in the
**       documentation and/or other materials provided with the distribution.
**     * Neither the name of the Jolla Ltd nor the
**       names of its contributors may be used to endorse or promote products
**       derived from this software without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
** ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
** WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
** DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
** ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
** LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
** ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
** SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
****************************************************************************************/

import QtQuick 2.0
import QtWebKit 3.0
import Sailfish.Silica 1.0

Page {
    id: browser
    property string href;
    property bool screenReaderMode: true
    property bool loaded: false
    property string articleContent: ""
    property string articleTitle: ""
    property string articleDate: ""
    property string articleImage: ""
    onLoadedChanged: {
        pullDownMenu.busy = pullDownMenu2.busy = !loaded
    }
    onStatusChanged: {
        if (status === PageStatus.Active) {
            fetchData();
        }

    }
    onScreenReaderModeChanged: {
        loaded = false;
        fetchData();
    }

    allowedOrientations: Orientation.All
    function fetchData(){
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "https://mercury.postlight.com/parser?url="+href, true);
        xhr.onreadystatechange = function() {
            if ( xhr.readyState === xhr.DONE ) {
                if ( xhr.status === 200 ) {
                    console.log(xhr.responseText)
                    var response = JSON.parse(xhr.responseText);
                    if (response.date_published)
                        //articleDate = new Date(response.date_published.replace(/^(\w+) (\w+) (\d+) ([\d:]+) \+0000 (\d+)$/,"$1, $2 $3 $5 $4 GMT"));
                        if (response.title)
                            articleTitle = response.title;
                    if (response.lead_image_url)
                        articleImage = response.lead_image_url
                    if (response.content)
                        articleContent = response.content;
                    if (response.content && response.lead_image_url)
                        articleContent = articleContent.replace(articleImage, "")
                }  else {

                }
                loaded = true;
            }
        }
        xhr.setRequestHeader("Content-Type", 'application/json');
        xhr.setRequestHeader("x-api-key", 'uakC11NlSubREs1r5NjkOCS1NJEkwti6DnDutcYC');

        if (screenReaderMode)
            xhr.send();
        else
            webView.url = 'https://mercury.postlight.com/amp?url='+href
    }



    BusyIndicator {
        id: loading
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        running: !loaded
    }

    SilicaWebView {
        enabled: !screenReaderMode
        visible: !screenReaderMode
        id: webView
        anchors {
            fill: parent
        }

        PullDownMenu {
            id: pullDownMenu
            MenuItem {
                text: qsTr("Open in Browser")
                onClicked: {
                    Qt.openUrlExternally(href);
                }
            }
            MenuItem {
                text: screenReaderMode ? qsTr("Web mode") : qsTr("Reading mode")
                onClicked: {
                    screenReaderMode = !screenReaderMode
                }
            }
        }

        opacity: 0
        onLoadingChanged: {
            switch (loadRequest.status)
            {
            case WebView.LoadSucceededStatus:
                opacity = 1
                loaded = true;
                break
            case WebView.LoadFailedStatus:
                opacity = 0
                loaded = true;
                viewPlaceHolder.errorString = loadRequest.errorString
                break
            default:
                opacity = 0
                loaded = false;
                break
            }
        }
        FadeAnimation on opacity {}
    }
    ViewPlaceholder {
        id: viewPlaceHolder
        property string errorString
        enabled: webView.opacity === 0 && loaded && !screenReaderMode
        text: errorString
        hintText: "Check network connectivity and pull down to reload"
    }



    SilicaFlickable {
        visible: screenReaderMode
        enabled: screenReaderMode
        anchors {
            fill: parent
        }
        contentHeight: article.height
        VerticalScrollDecorator {}
        PullDownMenu {
            id: pullDownMenu2
            MenuItem {
                text: qsTr("Open in Browser")
                onClicked: {
                    Qt.openUrlExternally(href);
                }
            }
            MenuItem {
                text: screenReaderMode ? qsTr("Web mode") : qsTr("Reading mode")
                onClicked: {
                    screenReaderMode = !screenReaderMode
                }
            }
        }
        Column {

            id: article
            width: parent.width

            Rectangle {
                height: Theme.itemSizeExtraSmall/3
                width: parent.width
                opacity: 0
            }

            Label {
                id: title
                text: articleTitle
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.highlightColor
                textFormat: Text.StyledText
                wrapMode: Text.WordWrap
                font.bold: true
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.paddingLarge
                    rightMargin: Theme.paddingLarge
                }
            }
            Label {
                id: date
                visible: articleDate !== ""
                text: articleDate
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                anchors {
                    left: parent.left
                    right: parent.right
                    topMargin: Theme.paddingSmall
                    bottomMargin: Theme.paddingSmall
                    leftMargin: Theme.paddingLarge
                    rightMargin: Theme.paddingLarge
                }
            }
            Rectangle {
                height: image.visible ? Theme.itemSizeExtraSmall/3 : 0
                width: parent.width
                opacity: 0
            }
            Image {
                id: image
                visible: articleImage !== "" ? true : false
                source: articleImage
                width: parent.width
                height: Theme.itemSizeExtraLarge
                fillMode: Image.PreserveAspectCrop
                anchors {
                    left: parent.left
                    right: parent.right
                }
                BusyIndicator {
                    size: BusyIndicatorSize.Small
                    anchors.centerIn: parent
                    running: parent.status != Image.Ready
                }

                onStatusChanged: if (image.status === Image.Ready) {
                                     var ratio = image.sourceSize.width/image.sourceSize.height
                                     height = width / ratio
                                 }
            }
            Rectangle {
                height: image.visible ? Theme.itemSizeExtraSmall/3 : 0
                width: parent.width
                opacity: 0
            }
            Label {
                id: content
                readonly property string _linkStyle: "<style>a:link { color: " + Theme.primaryColor + "; } h1, h2, h3, h4 { color: " + Theme.highlightColor + "; } img { margin: "+Theme.paddingLarge+" 0; width: 100\%}</style>"
                textFormat: Text.RichText
                text: _linkStyle + articleContent;
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
                anchors {
                    left: parent.left
                    right: parent.right
                    topMargin: image.visible ? Theme.paddingSmall : Theme.paddingLarge
                    leftMargin: Theme.paddingLarge
                    rightMargin: Theme.paddingLarge
                    bottomMargin: Theme.paddingLarge
                }

            }
            Rectangle {
                height: Theme.itemSizeExtraSmall/3
                width: parent.width
                opacity: 0
            }

        }
    }
}
