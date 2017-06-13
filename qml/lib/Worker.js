Qt.include("Mastodon.js")
WorkerScript.onMessage = function(msg) {
    console.log("Action > " + msg.action)
    console.log("Model > " + msg.model)
    console.log("Mode > " + msg.mode)
    console.log("Conf > " + JSON.stringify(msg.conf))
    console.log("Params > " + JSON.stringify(msg.params))
    if (!msg.conf.login){
        console.log("Not loggedin")
        return;
    }
    var API = MastodonAPI({ instance: msg.conf.instance, api_user_token: msg.conf.api_user_token});
    if (msg.method === "POST"){
        API.post(msg.action, msg.params, function(data) {
            for (var i in data) {
                if (data.hasOwnProperty(i)) {
                    console.log(JSON.stringify(data[i]))
                    WorkerScript.sendMessage({ 'action': msg.action, 'success': true,  key: i, "data": data[i]})
                }
            }
        });
        return;
    }

    API.get(msg.action, msg.params, function(data) {
        var items = [];
        for (var i in data) {
            if (data.hasOwnProperty(i)) {
                if(msg.action === "accounts/search") {
                    var item = parseAccounts(data[i]);
                    items.push(item)
                } else if(msg.action === "notifications") {
                    console.log("Is notification... parsing...")
                    var item = parseNotification(data[i]);
                    items.push(item)
                } else  if (data[i].hasOwnProperty("content")){
                    console.log("Is toot... parsing...")
                    var item = parseToot(data[i]);
                    item['id'] = item['status_id']
                    items.push(item)
                } else {
                    WorkerScript.sendMessage({ 'action': msg.action, 'success': true,  key: i, "data": data[i]})
                }
            }
        }
        if(msg.model)
            addDataToModel(msg.model, msg.mode, items)
    });

}
//WorkerScript.sendMessage({ 'notifyNewItems': length - i })
function addDataToModel (model, mode, items){
    var length = items.length;
    console.log("Fetched > " +length)

    if (mode === "append") {
        model.append(items)
    } else if (mode === "prepend") {
        for(var i = length-1; i >= 0 ; i--){
            model.insert(0,items[i])
        }
    }

    model.sync()
}
function parseAccounts(collection, prefix, data){
    var res = collection;

    res[prefix + 'account_id'] = data["id"]
    res[prefix + 'account_username'] = data["username"]
    res[prefix + 'account_acct'] = data["acct"]
    res[prefix + 'account_display_name'] = data["display_name"]
    res[prefix + 'account_locked'] = data["locked"]
    res[prefix + 'account_created_at'] = data["created_at"]
    res[prefix + 'account_avatar'] = data["avatar"]

    //    /console.log(JSON.stringify(res))
    return (res);
}

function parseNotification(data){
    //console.log(JSON.stringify(data))
    var item = {
        id: data.id,
        type: data.type,
        created_at: new Date(data.created_at)
    };
    switch (item['type']){
    case "mention":
        item = parseToot(data.status)
        item['typeIcon'] = "image://theme/icon-s-retweet"
        item['typeIcon'] = "image://theme/icon-s-alarm"
        break;
    case "reblog":
        item = parseToot(data.status)
        item = parseAccounts(item, "reblog_", data["account"])
        item = parseAccounts(item, "", data["status"]["account"])
        item['status_reblog'] = true;
        item['type'] = "reblog";
        item['typeIcon'] = "image://theme/icon-s-retweet"
        break;
    case "favourite":
        item = parseToot(data.status)
        item = parseAccounts(item, "reblog_", data["account"])
        item = parseAccounts(item, "", data["status"]["account"])
        item['status_reblog'] = true;
        item['typeIcon'] = "image://theme/icon-s-favorite"
        item['type'] = "favourite";
        //item['retweetScreenName'] = item['reblog_account_username'];
        break;
    case "follow":
        item['type'] = "follow";
        item = parseAccounts(item, "", data["account"])
        item = parseAccounts(item, "reblog_", data["account"])
        item['content'] = data['account']['note']
        item['typeIcon'] = "image://theme/icon-s-installed"

        break;
    default:
        item['typeIcon'] = "image://theme/icon-s-sailfish"
    }

    item['id'] = data.id

    return item;
}

function collect() {
    var ret = {};
    var len = arguments.length;
    for (var i=0; i<len; i++) {
        for (p in arguments[i]) {
            if (arguments[i].hasOwnProperty(p)) {
                ret[p] = arguments[i][p];
            }
        }
    }
    return ret;
}
function parseToot (data){
    //console.log(JSON.stringify(data))
    var item = {};
    item['status_id'] = data["id"]
    item['status_uri'] = data["uri"]
    item['status_in_reply_to_id'] = data["in_reply_to_id"]
    item['status_in_reply_to_account_id'] = data["in_reply_to_account_id"]
    item['status_reblog'] = data["reblog"] ? true : false
    item['status_content'] = data["content"]
    item['status_created_at'] = item['created_at'] = new Date(data["created_at"]);
    item['status_reblogs_count'] = data["reblogs_count"]
    item['status_favourites_count'] = data["favourites_count"]
    item['status_reblogged'] = data["reblogged"]
    item['status_favourited'] = data["favourited"]
    item['status_sensitive'] = data["sensitive"]
    item['status_spoiler_text'] = data["spoiler_text"]
    item['status_visibility'] = data["visibility"]


    //item.concat(parseAccounts("", data["account"]));
    //item = collect(item, );

    if(item['status_reblog']){
        item['type'] = "reblog";
        item['typeIcon'] = "image://theme/icon-s-retweet"
        item = parseAccounts(item, "", data['reblog']["account"])
        item = parseAccounts(item, "reblog_", data["account"])
    } else {
        item = parseAccounts(item, "", data["account"])
    }


    //item['application_name'] = data["application"]["name"]
    //item['application_website'] = data["application"]["website"]
    // account
    /*



    */





    /*item['type'] = "";
    item['retweetScreenName'] = '';
    item['isVerified'] = false;
    item['isReblog'] = false;
    item['favourited'] = data['favourited'];
    item['reblogged'] = data['reblogged'];
    item['muted'] = data['muted'];
    item['status_reblogs_count'] = data['reblogs_count'];
    item['status_favourites_count'] = data['favourites_count'];

    if(data['id']){
        item['status_id'] = data['id'];
    }
    if(data['created_at']){
        item['status_created_at'] = data['created_at'];
    }
    if(data['account']){
        item['status_account_id'] = data['account']['id'];
        item['status_account_username'] = data['account']['acct'];
        item['status_account_display_name'] = data['account']['display_name'];
        item['status_account_locked'] = data['account']['locked'];
        item['status_account_avatar'] = data['account']['avatar'];
    }
    if(data['reblog']){
        item['retweetScreenName'] = data['account']['username'];
        item['type'] = "reblog";
        item['reblog_id'] = data['reblog']['id'];
        item['account_id'] = data['reblog']['account']['id'];
        item['account_username'] = data['reblog']['account']['username'];
        item['account_display_name'] = data['reblog']['account']['display_name'];
        item['account_locked'] = data['reblog']['account']['locked'];
        item['account_avatar'] = data['reblog']['account']['avatar'];

        item['status_reblogs_count'] = data['reblog']['reblogs_count'];
        item['status_favourites_count'] = data['reblog']['favourites_count'];
        item['status_favourited'] = data['reblog']['favourited'];
        item['status_reblogged'] = data['reblog']['reblogged'];
        item['status_muted'] = data['reblog']['muted'];
    }
    */
    item['content'] = data['content'].replace(/(<([^>]+)>)/ig,"");
    /*for(var i = 0; i < data['tags'].length ; i++){
        var tag = data['tags'][i]['name'];
        console.log(tag)
        item['content'] = item['content'].replaceAll('#'+tag, '<a href="#'+tag+'">'+tag+'</a>')
    }*/

    item['content'] = item['content'].split(" ")
    for(var i = 0; i < item['content'].length ; i++){
        if(item['content'][i][0] === "#"){
            item['content'][i] = '<a href="'+item['content'][i]+'">'+item['content'][i]+'</a>';
        }
        if(item['content'][i][0] === "@"){
            item['content'][i] = '<a href="'+item['content'][i]+'">'+item['content'][i]+'</a>';
        }
    }
    item['content'] = item['content'].join(" ").autoLink()

    console.log(JSON.stringify(item))

    return item;
}
