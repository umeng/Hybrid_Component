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

var g_callback = null;

function auth(platform, callback) {
    g_callback = callback;
    exec("getUserInfo", [platform, "gotUserInfo"]);
};

function gotUserInfo(code, message, result) {
    if (g_callback != null) {
        g_callback (code, message, result);
    }
    // if (code == 0) {
    //     dataMap = JSON.parse(result);
    //     alert(dataMap['uid'])
    // } else {
    //     alert(message);
    // }
};

var UMShareAgent = {
    qqAuth : function() {
        auth(0, function(code, message, result){
            alert(code);
            if (code == 0) {
                dataMap = JSON.parse(result);
                alert(dataMap['uid'])
            } else {
                alert(message);
            }
        });
    },
    sinaAuth : function() {
        auth(1);
    },
    weixinAuth : function() {
        auth(2);
    },
};

