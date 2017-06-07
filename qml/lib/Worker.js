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
function parseAccounts(data){
    return (data);
}

function parseNotification(data){
    console.log(JSON.stringify(data))
    var item = {
        id: data.id,
        type: data.type,
        created_at: data.created_at,
        account_id: data.account.id,
        account_acct: data.account.acct,
        account_username: data.account.username,
        account_display_name: data.account.display_name,
        account_avatar: data.account.avatar,
        account_locked: data.account.locked
    };
    switch (item['type']){
    case "mention":
        item = parseToot(data.status)
        item['typeIcon'] = "image://theme/icon-s-retweet"
        item['typeIcon'] = "image://theme/icon-s-alarm"
        break;
    case "reblog":
        item = parseToot(data.status)
        item['isReblog'] = true;
        item['type'] = "reblog";
        item['retweetScreenName'] = data['account']['username'];
        item['typeIcon'] = "image://theme/icon-s-retweet"
        break;
    case "favourite":
        item = parseToot(data.status)
        item['typeIcon'] = "image://theme/icon-s-favorite"
        item['type'] = "favourite";
        item['retweetScreenName'] = data['account']['username'];
        break;
    case "follow":
        item['type'] = "follow";
        item['retweetScreenName'] = data['account']['username'];
        item['typeIcon'] = "image://theme/icon-s-installed"
        break;
    default:
        item['typeIcon'] = "image://theme/icon-s-sailfish"
    }



    return item;
}

function parseToot (data){
    //console.log(JSON.stringify(data))
    var item = {};
    item['account_username'] = "Mjau"
    item['type'] = "";
    item['retweetScreenName'] = '';
    item['isVerified'] = false;
    item['isReblog'] = false;
    item['favourited'] = data['favourited'];
    item['reblogged'] = data['reblogged'];
    item['muted'] = data['muted'];
    item['reblogs_count'] = data['reblogs_count'];
    item['favourites_count'] = data['favourites_count'];

    if(data['id']){
        item['id'] = data['id'];
    }
    if(data['created_at']){
        item['created_at'] = data['created_at'];
    }
    if(data['account']){
        item['account_id'] = data['account']['id'];
        item['account_username'] = data['account']['acct'];
        item['account_display_name'] = data['account']['display_name'];
        item['account_locked'] = data['account']['locked'];
        item['account_avatar'] = data['account']['avatar'];
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

        item['reblogs_count'] = data['reblog']['reblogs_count'];
        item['favourites_count'] = data['reblog']['favourites_count'];
        item['favourited'] = data['reblog']['favourited'];
        item['reblogged'] = data['reblog']['reblogged'];
        item['muted'] = data['reblog']['muted'];
    }

    item['content'] = data['content'].replace(/(<([^>]+)>)/ig,"");
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



    return item;
}
