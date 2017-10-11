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
    var url = "umpush:" + jsonStr;
    loadURL(url);
};







var UMPushAgent = {
    addTag : function(tag,callback) {
        exec("addTag", [tag, callback]);
    },

  delTag : function(tag,callback) {
          exec("delTag", [tag, callback]);
      },
      listTag : function(callback) {
                exec("listTag", [callback]);
            },
addAlias : function(alias,type,callback) {
          exec("addAlias", [alias,type,callback]);
      },
setAlias : function(alias,type,callback) {
          exec("setAlias", [alias,type,callback]);
      },
delAlias : function(alias,type,callback) {
          exec("delAlias", [alias,type,callback]);
      },
};