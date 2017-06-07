// by @kirschn@pleasehug.me 2017
// no fucking copyright
// do whatever you want with it
// but please don't hurt it (and keep this header)

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
            console.log(queryStringAppend)
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
                        callback(JSON.parse(http.response),http.status)
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

String.prototype.replaceAll = function(search, replacement) {
    var target = this;
    return target.replace(new RegExp(search, 'g'), replacement);
};

(function(){var k=[].slice;String.prototype.autoLink=function(){var d,b,g,a,e,f,h;e=1<=arguments.length?k.call(arguments,0):[];f=/(^|[\s\n]|<[A-Za-z]*\/?>)((?:https?|ftp):\/\/[\-A-Z0-9+\u0026\u2019@#\/%?=()~_|!:,.;]*[\-A-Z0-9+\u0026@#\/%=~()_|])/gi;if(!(0<e.length))return this.replace(f,"$1<a href='$2'>$2</a>");a=e[0];d=a.callback;g=function(){var c;c=[];for(b in a)h=a[b],"callback"!==b&&c.push(" "+b+"='"+h+"'");return c}().join("");return this.replace(f,function(c,b,a){c=("function"===typeof d?d(a):
void 0)||"<a href='"+a+"'"+g+">"+a+"</a>";return""+b+c})}}).call(this);
