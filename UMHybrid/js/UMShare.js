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



function auth(platform, callback) {

    exec("getUserInfo", [platform, callback]);
};

function share(platform, text, iconUrl, link, title, callback) {

    exec("share", [platform, text, iconUrl, link, title, callback]);
};

function shareBoard(platforms, text, iconUrl, link, title, callback) {

    exec("shareBoard", [platforms, text, iconUrl, link, title, callback]);
};



var UMShareAgent = {
    doAuth : function(platform,callback) {
        auth(platform, callback);
    },

   doShare : function(platform,text,img,url,title,callback) {

           share(platform, text,img,url,title, callback);
       },

    openShare : function(platforms,text,img,url,title,callback) {

        shareBoard(platforms, text,img,url,title, callback);
    },
};

