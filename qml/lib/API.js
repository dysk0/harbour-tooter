.pragma library
.import QtQuick.LocalStorage 2.0 as LS

var db = LS.LocalStorage.openDatabaseSync("tooter", "", "harbour-tooter", 100000);
var conf = {};
var mediator = (function(){
    var subscribe = function(channel, fn){
        if(!mediator.channels[channel]) mediator.channels[channel] = [];
        mediator.channels[channel].push({ context : this, callback : fn });
        return this;
    };
    var publish = function(channel){
        if(!mediator.channels[channel]) return false;
        var args = Array.prototype.slice.call(arguments, 1);
        for(var i = 0, l = mediator.channels[channel].length; i < l; i++){
            var subscription = mediator.channels[channel][i];
            subscription.callback.apply(subscription.context.args);
        };
        return this;
    };
    return {
        channels : {},
        publish : publish,
        subscribe : subscribe,
        installTo : function(obj){
            obj.subscribe = subscribe;
            obj.publish = publish;
        }
    };
}());
var init = function(){
    console.log("db.version: "+db.version);
    if(db.version === '') {
        db.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS settings ('
                          + ' key TEXT UNIQUE, '
                          + ' value TEXT '
                          +');');
            //tx.executeSql('INSERT INTO settings (key, value) VALUES (?, ?)', ["conf", "{}"]);
        });
        db.changeVersion('', '0.1', function(tx) {

        });
    }
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT * FROM settings;');
        console.log("READING CONF FROM DB")
        for (var i = 0; i < rs.rows.length; i++) {
            //var json = JSON.parse(rs.rows.item(i).value);
            console.log(rs.rows.item(i).key+" \t > \t "+rs.rows.item(i).value)
            conf[rs.rows.item(i).key] = JSON.parse(rs.rows.item(i).value)
        }
        console.log("END OF READING")
        console.log(JSON.stringify(conf));
        mediator.publish('confLoaded', { loaded: true});
    });
};

function saveData() {
    console.log("SAVING CONF TO DB")
    db.transaction(function(tx) {
        for (var key in conf) {
            if (conf.hasOwnProperty(key)){
                console.log(key + "\t>\t"+conf[key]);
                if (typeof conf[key] === "object" && conf[key] === null) {
                    tx.executeSql('DELETE FROM settings WHERE key=? ', [key])
                } else {
                    tx.executeSql('INSERT OR REPLACE INTO settings (key, value) VALUES (?, ?) ', [key, JSON.stringify(conf[key])])
                }
            }
        }
        console.log("ENF OF SAVING")
    });
}

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


    console.log(ret)
}
var test = 1;

Qt.include("Mastodon.js")

var modelTLhome = Qt.createQmlObject('import QtQuick 2.0; ListModel {   }', Qt.application, 'InternalQmlObject');
var modelTLpublic = Qt.createQmlObject('import QtQuick 2.0; ListModel {   }', Qt.application, 'InternalQmlObject');
var modelTLnotifications = Qt.createQmlObject('import QtQuick 2.0; ListModel {   }', Qt.application, 'InternalQmlObject');
var modelTLsearch = Qt.createQmlObject('import QtQuick 2.0; ListModel {   }', Qt.application, 'InternalQmlObject');
var notificationsList = []
var notificationGenerator = function(item){
    var notification;
    switch (item.urgency){
    case "normal":
        notification = Qt.createQmlObject('import org.nemomobile.notifications 1.0; Notification { category: "x-harbour.tooter.activity"; appName: "Tooter"; appIcon: "/usr/share/harbour-tooter/config/icon-lock-harbour-tooter.png"; summary: "Notification summary"; body: "Notification body"; previewSummary: "Notification preview summary"; previewBody: "Notification preview body"; itemCount: 1; remoteActions: [ { "name": "default", "displayName": "Do something", "icon": "icon-s-certificates", "service": "ba.dysko.harbour.tooter", "path": "/", "iface": "ba.dysko.harbour.tooter", "method": "openapp", "arguments": [  ] }]; urgency: Notification.Normal;  }', Qt.application, 'InternalQmlObject');
        break;
    case "critical":
        notification = Qt.createQmlObject('import org.nemomobile.notifications 1.0; Notification { appName: "Tooter"; itemCount: 1; category: "x-harbour.tooter.activity"; urgency: Notification.Critical;  remoteActions: [ { "name": "default", "displayName": "Do something", "icon": "icon-s-do-it", "service": "org.nemomobile.example", "path": "/example", "iface": "org.nemomobile.example", "method": "doSomething", "arguments": [ "argument", 1 ] },{ "name": "ignore", "displayName": "Ignore the problem", "icon": "icon-s-ignore", "service": "org.nemomobile.example", "path": "/example", "iface": "org.nemomobile.example", "method": "ignore", "arguments": [ "argument", 1 ] } ]; onClicked: console.log("Clicked"); onClosed: console.log("Closed, reason: " + reason); }', Qt.application, 'InternalQmlObject');
        break;
    default:
        notification = Qt.createQmlObject('import org.nemomobile.notifications 1.0; Notification { appName: "Tooter"; itemCount: 1; category: "x-harbour.tooter.activity"; urgency: Notification.Low; }', Qt.application, 'InternalQmlObject');
    }
    //notification.remoteActions =  [ { "name": "app", "displayName": "Do something", "icon": "icon-s-do-it", "service": "ba.dysko.harbour.tooter", "path": "/", "iface": "ba.dysko.harbour.tooter", "method": "openapp", "arguments": [ ]}]
    //Notifications.notify("Tooter", "serverinfo.serverTitle", " new activity", false, "2015-10-15 00:00:00", "aaa")

    notification.timestamp = item.timestamp
    notification.summary = item.summary
    notification.body = item.body
    if(item.previewBody)
        notification.previewBody = item.previewBody;
    if(item.previewSummary)
        notification.previewSummary = item.previewSummary;
    if(notification.replacesId){ notification.replacesId = 0 }
    notification.publish()
}

var notifier = function(item){

    item.content = item.content.replace(/(<([^>]+)>)/ig,"").replaceAll("&quot;", "\"")

    var msg;
    switch (item.type){
    case "favourite":
        msg = {
            urgency: "normal",
            timestamp: item.created_at,
            summary: (item.reblog_account_display_name !== "" ? item.reblog_account_display_name : '@'+item.reblog_account_username) + ' ' + qsTr("favourited"),
            body: item.content
        }
        break;
    case "follow":
        msg = {
            urgency: "critical",
            timestamp: item.created_at,
            summary: (item.account_display_name !== "" ? item.account_display_name : '@'+item.account_username),
            body: qsTr("followed you")
        }
        break;

    case "reblog":
        msg = {
            urgency: "low",
            timestamp: item.created_at,
            summary: (item.reblog_account_display_name !== "" ? item.reblog_account_display_name : '@'+item.reblog_account_username) + ' ' + qsTr("boosted"),
            body: item.content
        }
        break;
    case "mention":
        msg = {
            urgency: "critical",
            timestamp: item.created_at,
            summary: (item.account_display_name !== "" ? item.account_display_name : '@'+item.account_username) + ' ' + qsTr("said"),
            body: item.content,
            previewBody: (item.account_display_name !== "" ? item.account_display_name : '@'+item.account_username) + ' ' + qsTr("said") + ': ' + item.content
        }
        break;
    default:
        //console.log(JSON.stringify(messageObject.data))
        return;
    }
    notificationGenerator(msg)
}

var api;

function func() {
    console.log(api)
}
