function loadURL(url) {
    var iFrame;
    iFrame = document.createElement("iframe");
    iFrame.setAttribute("src", url);
    iFrame.setAttribute("style", "display:none;");
    iFrame.setAttribute("height", "0px");
    iFrame.setAttribute("width", "0px");
    iFrame.setAttribute("frameborder", "0");
    document.body.appendChild(iFrame);
    iFrame.parentNode.removeChild(iFrame);
    iFrame = null;
};


function exec(funName, args) {
    var commend = {
        functionName : funName,
        arguments : args
    };
    var jsonStr = JSON.stringify(commend);
    var url = "umshare:" + jsonStr;
    loadURL(url);
};

var g_authCallback = null;
var g_shareCallback = null;

function auth(platform, callback) {
    g_authCallback = callback;
    exec("getUserInfo", [platform, "gotUserInfo"]);
};

function share(platform, text, iconUrl, link, title, callback) {
    g_shareCallback = callback
    exec("share", [platform, text, iconUrl, link, title, "gotShareResult"]);
};

function shareBoard(platforms, text, iconUrl, link, title, callback) {
    g_shareCallback = callback
    exec("shareBoard", [platforms, text, iconUrl, link, title, "gotShareResult"]);
};

function gotUserInfo(code, message, result) {
    if (g_authCallback != null) {
        g_authCallback (code, message, result);
    }
};

function gotShareResult(code, message, result) {
    if (g_shareCallback != null) {
        g_shareCallback (code, message, result);
    }
};

var UMShareAgent = {
    qqAuth : function() {
        auth(0, function(code, message, result){
            if (code == 0) {
                dataMap = JSON.parse(result);
                alert(dataMap['uid'])
            } else {
                alert(message);
            }
        });
    },
    sinaAuth : function() {
        auth(1, function(code, message, result){
            if (code == 0) {
                dataMap = JSON.parse(result);
                alert(dataMap['uid'])
            } else {
                alert(message);
            }
        });
    },
    weixinAuth : function() {
        auth(2, function(code, message, result){
            if (code == 0) {
                dataMap = JSON.parse(result);
                alert(dataMap['uid'])
            } else {
                alert(message);
            }
        });
    },
    shareText : function() {
        share(2, 'sssss','','','', function (code, message, result) {
            if (code == 0) {
                alert('share success')
            } else {
                alert('share failed');
            }
        });
    },
    shareLink : function() {
        share(2, 'sssss','http://dev.umeng.com/images/tab2_1.png','http://www.umeng.com/','title', function (code, message, result) {
            if (code == 0) {
                alert('share success')
            } else {
                alert('share failed');
            }
        });
    },
    shareImage : function() {
        share(2, '','http://dev.umeng.com/images/tab2_1.png','','', function (code, message, result) {
            if (code == 0) {
                alert('share success')
            } else {
                alert('share failed');
            }
        });
    },
    shareBoard : function() {
        var list = [0,1,2];
        shareBoard(list, 'sssss','http://dev.umeng.com/images/tab2_1.png','http://www.umeng.com/','title', function (code, message, result) {
            if (code == 0) {
                alert('share success')
            } else {
                alert('share failed');
            }
        });
    },
};

