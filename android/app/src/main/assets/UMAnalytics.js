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
    var url = "umanalytics:" + jsonStr;
    loadURL(url);
};

var UMAnalyticsAgent = {

    /**
    *    getDeviceId
    */
    getDeviceId : function(callBack) {
        exec("getDeviceId", [ callBack.name ]);
    },
    /**
     * 自定义事件数量统计
     *
     * @param eventId: 事件ID，注意需要先在友盟网站注册此ID
     */
    onEvent : function(eventId) {
        exec("onEvent", [ eventId ]);
        
    },
    /**
     * 自定义事件数量统计
     *
     * @param eventId
     *            String类型.事件ID， 注意需要先在友盟网站注册此ID
     * @param eventLabel
     *            String类型.事件标签，事件的一个属性说明
     */
    onEventWithLabel : function(eventId, eventLabel) {
        exec("onEventWithLabel", [ eventId, eventLabel ]);
        
    },
    /**
     * 自定义事件数量统计
     *
     * @param eventId
     *            String类型, 事件ID， 注意需要先在友盟网站注册此ID
     * @param eventData
     *            Map类型, 当前事件的属性集合，最多支持10个K-V值
     */
    onEventWithParameters : function(eventId, eventData) {
        exec("onEventWithParameters", [ eventId, eventData ]);
    },
    /**
     * 自定义事件数值型统计
     *
     * @param eventId
     *            String类型.事件ID，注意要先在友盟网站上注册此事件ID
     * @param eventData
     *            map类型.事件的属性集合，最多支持10个K-V值
     * @param eventNum
     *            int 类型.事件持续时长，单位毫秒，您需要手动计算并传入时长，作为事件的时长参数
     *
     */
    onEventWithCounter : function(eventId, eventData, eventNum) {
        exec("onEventWithCounter", [ eventId, eventData, eventNum ]);
    },

    /**
    * 支持多种属性值类型的自定义带属性事件接口。
    * 属性值可以是如下几种类型之一：String、Long、Integer、Float、Double、Short。
    */
    onEventObject : function(eventId, eventData) {
            exec("onEventObject", [ eventId, eventData ]);
    },

    /**
     * 页面统计开始时调用
     *
     * @param pageName
     *            String类型.页面名称
     */
    onPageBegin : function(pageName) {
        exec("onPageBegin", [ pageName ]);
    },
    /**
     * 页面统计结束时调用
     *
     * @param pageName
     *            String类型.页面名称
     */
    onPageEnd : function(pageName) {
        exec("onPageEnd", [ pageName ]);
    },

    
    /**
     * 统计帐号登录接口 *
     *
     * @param UID
     *            用户账号ID,长度小于64字节
     */
    profileSignInWithPUID : function(UID) {
        exec("profileSignInWithPUID", [ UID ]);
    },
    /**
     * 统计帐号登录接口 *
     *
     * @param provider
     *            帐号来源.用户通过第三方账号登陆,可以调用此接口进行统计.不能以下划线"_"开头,使用大写字母和数字标识,长度小于32字节;
     *            如果是上市公司,建议使用股票代码.
     * @param UID
     *            用户账号ID,长度小于64字节
     */
    profileSignInWithPUIDWithProvider : function(provider, UID) {
        exec("profileSignInWithPUIDWithProvider", [ provider, UID ]);
    },
    /**
     * 帐号统计退出接口
     */
    profileSignOff : function() {
        exec("profileSignOff", []);
    },


    /** * 设置属性 键值对 会覆盖同名的key
     * 将该函数指定的key-value写入文件；APP启动时会自动读取该文件的所有key-value。
     * @param property 预置事件属性
     SDK最多支持注册10个预置事件属性，超过10个预置事件属性则接口函数直接返回，预置事件属性名用户可自定义
     *
     *
     */
    registerPreProperties : function(property) {
        exec("registerPreProperties", [property]);
    },
    
    /** * 删除指定key-value
     * @param propertyName
     *              String类型.自定义属性
     *
     */
    unregisterPreProperty : function(propertyName) {
        exec("unregisterPreProperty", [propertyName]);
    },
    

    /** 返回所有key-value；如果不存在，则返回空。
     *
     */
    getPreProperties : function(callback) {
        exec("getPreProperties", [callback.name]);
    },
    
    /** * 清空所有key-value。
     *
     */
    clearPreProperties : function() {
        exec("clearPreProperties", []);
    },
    
    /** * 设置关注事件是否首次触发,只关注eventList前五个合法eventID.只要已经保存五个,此接口无效
     * @param eventList
     *              List<String>类型.自定义属性
     *
     */
    setFirstLaunchEvent : function(eventList) {
        exec("setFirstLaunchEvent", [eventList]);
    }
};

