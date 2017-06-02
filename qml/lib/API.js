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

// by @kirschn@pleasehug.me 2017
// no fucking copyright
// do whatever you want with it
// but please don't hurt it (and keep this header)
var test = 1;
var MastodonAPI = function(config) {
    var apiBase = config.instance + "/api/v1/";
    return {
        setConfig: function (key, value) {
            // modify initial config afterwards
            config[key] = value;
        },
        getConfig: function(key) {
            //get config key
            return config[key];
        },
        get: function (endpoint) {
            // for GET API calls
            // can be called with two or three parameters
            // endpoint, callback
            // or
            // endpoint, queryData, callback
            // where querydata is an object {["paramname1", "paramvalue1], ["paramname2","paramvalue2"]}

            // variables
            var queryData, callback,
                    queryStringAppend = "?";

            // check with which arguments we're supplied
            if (typeof arguments[1] === "function") {
                queryData = {};
                callback = arguments[1];
            } else {
                queryData = arguments[1];
                callback = arguments[2];
            }
            // build queryData Object into a URL Query String
            for (var i in queryData) {
                if (queryData.hasOwnProperty(i)) {
                    if (typeof queryData[i] === "string") {
                        queryStringAppend += queryData[i] + "&";
                    } else if (typeof queryData[i] === "object") {
                        queryStringAppend += queryData[i].name + "="+ queryData[i].data + "&";
                    }
                }
            }
            // ajax function
            var http = new XMLHttpRequest()
            var url = apiBase + endpoint;
            http.open("GET", apiBase + endpoint + queryStringAppend, true);

            // Send the proper header information along with the request
            http.setRequestHeader("Authorization", "Bearer " + config.api_user_token);
            http.setRequestHeader("Content-Type", "application/json");
            http.setRequestHeader("Connection", "close");

            http.onreadystatechange = function() { // Call a function when the state changes.
                if (http.readyState == 4) {
                    if (http.status == 200) {
                        console.log("Successful GET API request to " +apiBase+endpoint);
                        callback(JSON.parse(http.response),http.status)
                    } else {
                        console.log("error: " + http.status)
                    }
                }
            }
            http.send();
        },
        post: function (endpoint) {
            // for POST API calls
            var postData, callback;
            // check with which arguments we're supplied
            if (typeof arguments[1] === "function") {
                postData = {};
                callback = arguments[1];
            } else {
                postData = arguments[1];
                callback = arguments[2];
            }

            var http = new XMLHttpRequest()
            var url = apiBase + endpoint;
            var params = JSON.stringify(postData);
            http.open("POST", url, true);

            // Send the proper header information along with the request
            http.setRequestHeader("Authorization", "Bearer " + config.api_user_token);
            http.setRequestHeader("Content-Type", "application/json");
            http.setRequestHeader("Content-length", params.length);
            http.setRequestHeader("Connection", "close");

            http.onreadystatechange = function() { // Call a function when the state changes.
                if (http.readyState == 4) {
                    if (http.status == 200) {
                        console.log("Successful POST API request to " +apiBase+endpoint);
                        callback(http.response,http.status)
                    } else {
                        console.log("error: " + http.status)
                    }
                }
            }
            http.send(params);

            /*$.ajax({
                       url: apiBase + endpoint,
                       type: "POST",
                       data: postData,
                       headers: {"Authorization": "Bearer " + config.api_user_token},
                       success: function(data, textStatus) {
                           console.log("Successful POST API request to " +apiBase+endpoint);
                           callback(data,textStatus)
                       }
                   });*/
        },
        delete: function (endpoint, callback) {
            // for DELETE API calls.
            $.ajax({
                       url: apiBase + endpoint,
                       type: "DELETE",
                       headers: {"Authorization": "Bearer " + config.api_user_token},
                       success: function(data, textStatus) {
                           console.log("Successful DELETE API request to " +apiBase+endpoint);
                           callback(data,textStatus)
                       }
                   });
        },
        stream: function (streamType, onData) {
            // Event Stream Support
            // websocket streaming is undocumented. i had to reverse engineer the fucking web client.
            // streamType is either
            // user for your local home TL and notifications
            // public for your federated TL
            // public:local for your home TL
            // hashtag&tag=fuckdonaldtrump for the stream of #fuckdonaldtrump
            // callback gets called whenever new data ist recieved
            // callback { event: (eventtype), payload: {mastodon object as described in the api docs} }
            // eventtype could be notification (=notification) or update (= new toot in TL)
            //return "wss://" + apiBase.substr(8) +"streaming?access_token=" + config.api_user_token + "&stream=" + streamType

            var es = new WebSocket("wss://" + apiBase.substr(8)
                                   +"streaming?access_token=" + config.api_user_token + "&stream=" + streamType);
            var listener = function (event) {
                console.log("Got Data from Stream " + streamType);
                event = JSON.parse(event.data);
                event.payload = JSON.parse(event.payload);
                onData(event);
            };
            es.onmessage = listener;


        },
        registerApplication: function (client_name, redirect_uri, scopes, website, callback) {
            //register a new application

            // OAuth Auth flow:
            // First register the application
            // 2) get a access code from a user (using the link, generation function below!)
            // 3) insert the data you got from the application and the code from the user into
            // getAccessTokenFromAuthCode. Note: scopes has to be an array, every time!
            // For example ["read", "write"]

            //determine which parameters we got
            if (website === null) {
                website = "";
            }
            // build scope array to string for the api request
            var scopeBuild = "";
            if (typeof scopes !== "string") {
                scopes = scopes.join(" ");
            }

            var http = new XMLHttpRequest()
            var url = apiBase + "apps";
            var params = 'client_name=' + client_name + '&redirect_uris=' + redirect_uri + '&scopes=' + scopes + '&website=' + website;
            console.log(params)
            http.open("POST", url, true);

            // Send the proper header information along with the request
            http.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

            http.onreadystatechange = function() { // Call a function when the state changes.
                if (http.readyState == 4) {
                    if (http.status == 200) {
                        console.log("Registered Application: " + http.response);
                        callback(http.response)
                    } else {
                        console.log("error: " + http.status)
                    }
                }
            }
            http.send(params);
        },
        generateAuthLink: function (client_id, redirect_uri, responseType, scopes) {
            return config.instance + "/oauth/authorize?client_id=" + client_id + "&redirect_uri=" + redirect_uri +
                    "&response_type=" + responseType + "&scope=" + scopes.join("+");
        },
        getAccessTokenFromAuthCode: function (client_id, client_secret, redirect_uri, code, callback) {
            /*$.ajax({
                       url: config.instance + "/oauth/token",
                       type: "POST",
                       data: {
                           client_id: client_id,
                           client_secret: client_secret,
                           redirect_uri: redirect_uri,
                           grant_type: "authorization_code",
                           code: code
                       },
                       success: function (data, textStatus) {
                           console.log("Got Token: " + data);
                           callback(data);
                       }
                   });*/
            var http = new XMLHttpRequest()
            var url = config.instance + "/oauth/token";
            var params = 'client_id=' + client_id + '&client_secret=' + client_secret + '&redirect_uri=' + redirect_uri + '&grant_type=authorization_code&code=' + code;
            console.log(params)
            http.open("POST", url, true);

            // Send the proper header information along with the request
            http.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

            http.onreadystatechange = function() { // Call a function when the state changes.
                if (http.readyState == 4) {
                    if (http.status == 200) {
                        console.log("Got Token: " + http.response);
                        callback(http.response)
                    } else {
                        console.log("error: " + http.status)
                    }
                }
            }
            http.send(params);
        }
    };
};

// node.js
if (typeof module !== 'undefined') { module.exports = MastodonAPI; };


var api;

function func() {
    console.log(api)
}
