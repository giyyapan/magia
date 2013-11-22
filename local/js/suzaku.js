// Generated by CoffeeScript 1.6.3
(function() {
  var AjaxManager, Api, ApiManager, EventEmitter, KeybordManager, Suzaku, TemplateManager, Utils, Widget, debug, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  if (!$) {
    console.warn("cannot find JQuery!  -- Suzaku");
  }

  debug = false;

  Suzaku = (function() {
    function Suzaku() {
      if (debug) {
        console.log("init Suzaku");
      }
      this.Widget = Widget;
      this.TemplateManager = TemplateManager;
      this.EventEmitter = EventEmitter;
      this.AjaxManager = AjaxManager;
      this.ApiManager = ApiManager;
      this.KeybordManager = KeybordManager;
      this.AnimationManager = null;
      this.Utils = null;
      this.Key = null;
      this.Mouse = null;
      this.WsServer = null;
    }

    Suzaku.prototype.debug = function() {
      return debug = true;
    };

    return Suzaku;

  })();

  EventEmitter = (function() {
    function EventEmitter() {
      this._events = {};
    }

    EventEmitter.prototype.on = function(event, callback) {
      if (!this._events[event]) {
        this._events[event] = [];
      }
      this._events[event].push(callback);
      return callback;
    };

    EventEmitter.prototype.once = function(event, callback) {
      var f,
        _this = this;
      f = function() {
        _this.off(event, f);
        return callback.apply(_this, arguments);
      };
      this.on(event, f);
      return f;
    };

    EventEmitter.prototype.off = function(event, listener) {
      var func, _i, _j, _len, _len1, _ref, _ref1;
      if (typeof listener === "function") {
        _ref = this._events[event];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          func = _ref[_i];
          if (func === listener) {
            Utils.removeItem(this._events[event], func);
            return;
          }
        }
        return console.error("cannot find listener " + listener + " of " + event + "-- Suzaku.EventEmitter");
      } else {
        _ref1 = this._events[event];
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          func = _ref1[_j];
          func = null;
        }
        return delete this._events[event];
      }
    };

    EventEmitter.prototype.emit = function(event) {
      var func, _i, _len, _ref, _results;
      if (!this._events[event]) {
        return;
      }
      _ref = this._events[event];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        func = _ref[_i];
        if (typeof func !== "function") {
          continue;
        }
        _results.push(func.apply(this, Array.prototype.slice.call(arguments, 1)));
      }
      return _results;
    };

    return EventEmitter;

  })();

  Widget = (function(_super) {
    __extends(Widget, _super);

    function Widget(creator) {
      var tempDiv, template;
      Widget.__super__.constructor.call(this);
      if (!creator) {
        console.error("need a creator! -- Suzaku.Widget");
        return;
      }
      this.J = null;
      this.dom = null;
      this.template = null;
      this.creator = creator;
      this.UI = {};
      if (typeof creator === 'string') {
        if (creator.indexOf("<") > -1 && creator.indexOf(">") > -1) {
          template = creator;
          tempDiv = document.createElement("div");
          tempDiv.innerHTML = template;
          this.dom = tempDiv.children[0];
          if ($) {
            this.J = $(this.dom);
          }
        } else {
          if ($) {
            this.J = $(creator);
          }
          this.dom = document.querySelector(creator);
          if (!this.dom) {
            console.error("Wrong selector!: '" + creator + "' cannot find element by this -- Suzaku.Widget");
            return;
          }
        }
      }
      if ($ && creator instanceof $) {
        this.J = creator;
        this.dom = this.J[0];
      }
      if (creator instanceof window.HTMLElement || typeof creator.appendChild === "function") {
        this.dom = creator;
        if ($) {
          this.J = $(this.dom);
        }
      }
      this._initUI();
    }

    Widget.prototype._initUI = function(targetDom) {
      var did, dom, _i, _len, _ref, _results;
      if (targetDom == null) {
        targetDom = this.dom;
      }
      if (!targetDom.children) {
        return;
      }
      _ref = targetDom.children;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        dom = _ref[_i];
        if (dom.children && dom.children.length > 0) {
          this._initUI(dom);
        }
        did = dom.getAttribute("data-id");
        if (did) {
          if (!this.UI[did]) {
            this.UI[did] = dom;
            dom.dom = dom;
            dom.doms = [dom];
            dom.J = $ ? $(dom) : null;
            _results.push(dom.remove = this.remove);
          } else {
            if ($) {
              this.UI[did].J.push(dom);
            }
            _results.push(this.UI[did].doms.push(dom));
          }
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Widget.prototype.remove = function() {
      var parent;
      parent = this.dom.parentElement || this.dom.parentNode;
      return parent.removeChild(this.dom);
    };

    Widget.prototype.before = function(target) {
      if (target.dom instanceof HTMLElement) {
        target = target.dom;
      }
      if ($ && target instanceof $) {
        target = target[0];
      }
      console.log(target);
      if (target instanceof HTMLElement) {
        return target.parentElement.insertBefore(this.dom, target);
      } else {
        return console.error("invaild target!  --Suzaku.Widget");
      }
    };

    Widget.prototype.after = function(target) {
      var dom, index, next, parent, _i, _len, _ref;
      if (target instanceof Widget) {
        target = target.dom;
      }
      if ($ && target instanceof $) {
        target = target[0];
      }
      if (target instanceof HTMLElement) {
        parent = target.parentElement;
        next = null;
        _ref = parent.children;
        for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
          dom = _ref[index];
          if (dom === target && index < parent.children.length - 1) {
            next = parent.children[index + 1];
          }
        }
        if (next) {
          return parent.insertBefore(this.dom, next);
        } else {
          return parent.appendChild(this.dom);
        }
      } else {
        return console.error("invaild target!  --Suzaku.Widget");
      }
    };

    Widget.prototype.replace = function(target) {
      var parent;
      this.before(target);
      if (target instanceof Widget) {
        target.remove();
      }
      if ($ && target instanceof $) {
        target.remove();
      }
      parent = target.parentElement || target.parentNode;
      if (target instanceof HTMLElement) {
        return parent.removeChild(target);
      }
    };

    Widget.prototype.appendTo = function(target) {
      if (!target) {
        console.error("need a target --Suzaku.Widget", target);
      }
      if (target instanceof Widget || target.dom instanceof window.HTMLElement) {
        target.dom.appendChild(this.dom);
        return this;
      }
      if ($ && target instanceof $) {
        target.append(this.dom);
        return this;
      }
      if (typeof target.appendChild === "function") {
        target.appendChild(this.dom);
        return this;
      }
    };

    Widget.prototype.insertTo = function(target) {
      var fec;
      if (!target) {
        console.error("need a target --Suzaku.Widget", target);
      }
      fec = target.firstElementChild;
      if (target.dom instanceof window.HTMLElement) {
        fec = target.dom.firstElementChild;
      }
      if ($ && target instanceof $) {
        fec = target.get(0).firstElementChild;
      }
      if (!fec) {
        return this.appendTo(target);
      } else {
        this.before(fec);
      }
      return this;
    };

    return Widget;

  })(EventEmitter);

  TemplateManager = (function(_super) {
    __extends(TemplateManager, _super);

    function TemplateManager() {
      TemplateManager.__super__.constructor.call(this);
      this.tplPath = "./templates/";
      this.templates = {};
      this.tplNames = [];
    }

    TemplateManager.prototype.use = function() {
      var item, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = arguments.length; _i < _len; _i++) {
        item = arguments[_i];
        _results.push(this.tplNames.push(item));
      }
      return _results;
    };

    TemplateManager.prototype.setPath = function(path) {
      var arr;
      if (typeof path !== "string") {
        return console.error("Illegal Path: " + path + " --Suzaku.ApiManager");
      }
      arr = path.split('');
      if (arr[arr.length - 1] !== "/") {
        arr.push("/");
      }
      path = arr.join('');
      if (debug) {
        console.log('set template file path:', path);
      }
      return this.tplPath = path;
    };

    TemplateManager.prototype.start = function(callback) {
      var ajaxManager, localDir, name, req, url, _i, _len, _ref,
        _this = this;
      if (typeof callback === "function") {
        this.on("load", callback);
      }
      ajaxManager = new AjaxManager;
      localDir = this.tplPath;
      _ref = this.tplNames;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        name = _ref[_i];
        url = name.indexOf(".html") > -1 ? localDir + name : localDir + name + ".html";
        req = ajaxManager.addGetRequest(url, null, function(data, textStatus, req) {
          return _this.templates[req.Suzaku_tplName] = data;
        });
        req.Suzaku_tplName = name;
      }
      return ajaxManager.start(function() {
        if (debug) {
          console.log("template loaded");
        }
        return _this.emit("load", _this.templates);
      });
    };

    return TemplateManager;

  })(EventEmitter);

  AjaxManager = (function(_super) {
    __extends(AjaxManager, _super);

    function AjaxManager() {
      if (!$) {
        return console.error("ajax Manager needs Jquery!");
      }
      AjaxManager.__super__.constructor.call(this);
      this.reqs = [];
      this.ajaxMissions = {};
      this.tidCounter = 0;
    }

    AjaxManager.prototype.addRequest = function(option) {
      option.type = option.type || 'get';
      if (!option.url) {
        return console.error("ajax need url!");
      }
      if (debug) {
        console.log("Add request:", option.type, "to", option.url, "--Suzaku.AjaxManager");
      }
      option.externPort = {};
      this.reqs.push(option);
      return option.externPort;
    };

    AjaxManager.prototype.addGetRequest = function(url, data, success, dataType) {
      return this.addRequest({
        type: "get",
        url: url,
        data: data,
        dataType: dataType,
        retry: 5,
        success: success
      });
    };

    AjaxManager.prototype.addPostRequest = function(url, data, success, dataType) {
      return this.addRequest({
        type: "post",
        url: url,
        data: data,
        retry: 5,
        dataType: dataType,
        success: success
      });
    };

    AjaxManager.prototype.start = function(callback) {
      var JAjaxReqOpt, ajaxManager, ajaxReq, id, index, name, newAjaxTask, taskOpt, value, _i, _len, _ref, _ref1,
        _this = this;
      id = this.tidCounter += 1;
      newAjaxTask = {
        id: id,
        reqs: this.reqs,
        finishedNum: 0,
        callback: callback
      };
      this.ajaxMissions[id] = newAjaxTask;
      if (debug) {
        console.log("start request tasks", newAjaxTask);
      }
      this.reqs = [];
      ajaxManager = this;
      _ref = this.ajaxMissions[id].reqs;
      for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
        taskOpt = _ref[index];
        JAjaxReqOpt = Utils.clone(taskOpt);
        delete JAjaxReqOpt.retry;
        delete JAjaxReqOpt.externPort;
        JAjaxReqOpt.success = function(data, textStatus, req) {
          return _this._ajaxSuccess.apply(_this, arguments);
        };
        JAjaxReqOpt.error = function(req, textStatus, error) {
          return _this._ajaxError.apply(_this, arguments);
        };
        ajaxReq = $.ajax(JAjaxReqOpt);
        ajaxReq.Suzaku_JAjaxReqOpt = JAjaxReqOpt;
        ajaxReq.Suzaku_taskOpt = taskOpt;
        ajaxReq.Suzaku_ajaxMission = newAjaxTask;
        _ref1 = taskOpt.externPort;
        for (name in _ref1) {
          value = _ref1[name];
          ajaxReq[name] = value;
        }
      }
      return this.on("finish", function(taskId) {
        callback = _this.ajaxMissions[taskId].callback;
        delete _this.ajaxMissions[taskId];
        if (typeof callback === "function") {
          return callback();
        }
      });
    };

    AjaxManager.prototype._ajaxSuccess = function(data, textStatus, req) {
      var ajaxMission;
      ajaxMission = req.Suzaku_ajaxMission;
      ajaxMission.finishedNum += 1;
      if (req.Suzaku_taskOpt.success) {
        req.Suzaku_taskOpt.success(data, textStatus, req);
      }
      if (ajaxMission.finishedNum === ajaxMission.reqs.length) {
        if (debug) {
          console.log("finish", this);
        }
        return this.emit("finish", ajaxMission.id);
      }
    };

    AjaxManager.prototype._ajaxError = function(req, textStatus, error) {
      var ajaxMission, ajaxReq, name, retried, retry, taskOpt, value, _ref;
      if (debug) {
        console.log("ajax error", error);
      }
      taskOpt = req.Suzaku_taskOpt;
      retry = taskOpt.retry;
      if (!retry) {
        retry = 5;
      }
      retried = req.Suzaku_retried || 0;
      if (retried < retry) {
        ajaxReq = $.ajax(req.Suzaku_JAjaxReqOpt);
        ajaxReq.Suzaku_JAjaxReqOpt = req.Suzaku_JAjaxReqOpt;
        ajaxReq.Suzaku_taskOpt = req.Suzaku_taskOpt;
        ajaxReq.Suzaku_ajaxMission = req.Suzaku_ajaxMission;
        _ref = req.Suzaku_taskOpt.externPort;
        for (name in _ref) {
          value = _ref[name];
          ajaxReq[name] = value;
        }
        return ajaxReq.Suzaku_retried = retried + 1;
      } else {
        ajaxMission = req.Suzaku_ajaxMission;
        ajaxMission.finishedNum += 1;
        console.error("request failed!", req, textStatus, error);
        if (req.Suzaku_taskOpt.fail) {
          req.Suzaku_taskOpt.fail(req, textStatus, error);
        }
        if (ajaxMission.finishedNum === ajaxMission.reqs.length) {
          return this.emit("finish", ajaxMission.id);
        }
      }
    };

    return AjaxManager;

  })(EventEmitter);

  Api = (function(_super) {
    __extends(Api, _super);

    function Api(name, params, JAjaxOptions, url, method, errorHandlers) {
      Api.__super__.constructor.call(this);
      if (!params || !(params instanceof Array)) {
        return console.error("Illegel arguments " + name + " " + params + "! --Suzaku.ApiGenerator");
      }
      this.name = name;
      this.url = url;
      this.method = method;
      this.params = [];
      this.errorHandlers = errorHandlers;
      this.JAjaxOptions = JAjaxOptions;
      this._initParams(params);
    }

    Api.prototype._initParams = function(params) {
      var arr, name, param, type, value, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = params.length; _i < _len; _i++) {
        param = params[_i];
        if (param.indexOf('=') > -1) {
          arr = param.split('=');
          name = arr[0];
          value = arr[1];
          _results.push(this.params.push({
            name: name.replace('?', ''),
            value: value
          }));
        } else {
          arr = param.split(":");
          name = arr[0];
          type = arr[1] || "any";
          _results.push(this.params.push({
            force: param.indexOf('?') > -1 ? false : true,
            name: name.replace('?', ''),
            type: type.replace('?', '').split('/')
          }));
        }
      }
      return _results;
    };

    Api.prototype._checkParams = function() {
      return true;
    };

    Api.prototype.send = function() {
      var arg, argIndex, data, dataType, index, name, opt, param, req, value, _i, _len, _ref, _ref1,
        _this = this;
      if (!this._checkParams()) {
        return;
      }
      data = {};
      argIndex = 0;
      _ref = this.params;
      for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
        param = _ref[index];
        if (param.value) {
          data[param.name] = param.value;
        } else {
          arg = arguments[argIndex];
          if (typeof arg === "undefind" && param.force) {
            console.warn("api " + this.name + " has different args from declare:", arg);
          }
          data[param.name] = arg;
          argIndex += 1;
        }
      }
      if (debug) {
        console.log("api " + this.method + " " + this.name + " send data:", data);
      }
      if (this.method === "post" && typeof data === "object") {
        data = JSON.stringify(data);
        dataType = "text";
      }
      opt = {
        type: this.method,
        url: this.url,
        dataType: dataType || "json",
        data: data,
        success: function(data, textStatus, req) {
          var evtData;
          if (typeof data === "string") {
            try {
              data = JSON.parse(data);
            } catch (_error) {}
          }
          if (typeof _this.onsuccess === "function") {
            _this.onsuccess(data);
          }
          _this.onsuccess = null;
          evtData = {
            successed: true,
            data: data,
            textStatus: textStatus,
            JAjaxReq: req
          };
          _this.emit("success", evtData);
          return _this.emit("finish", evtData);
        },
        error: function(req, textStatus, error) {
          var evtData;
          console.error("Api ajax error:" + error + " --Suzaku.API");
          console.warn(arguments);
          if (typeof _this.onfail === "function") {
            _this.onfail(error, textStatus);
          }
          _this.onfail = null;
          if (_this.errorHandlers.requestFail) {
            _this.errorHandlers.requestFail();
          }
          if (_this.errorHandlers[req.status]) {
            _this.errorHandlers[req.status]();
          }
          evtData = {
            successed: false,
            JAjaxReq: req,
            textStatus: textStatus,
            errorCode: req.status,
            error: error
          };
          _this.emit("error", evtData);
          return _this.emit("finish", evtData);
        }
      };
      _ref1 = this.JAjaxOptions;
      for (name in _ref1) {
        value = _ref1[name];
        opt[name] = value;
      }
      return req = $.ajax(opt);
    };

    Api.prototype.respond = function(callback) {
      return this.success(callback);
    };

    Api.prototype.success = function(callback) {
      this.onsuccess = callback;
      return this;
    };

    Api.prototype.fail = function(callback) {
      this.onfail = callback;
      return this;
    };

    return Api;

  })(EventEmitter);

  ApiManager = (function(_super) {
    __extends(ApiManager, _super);

    function ApiManager() {
      ApiManager.__super__.constructor.call(this);
      this.apis = {};
      this.errorHandlers = {};
      this.method = "get";
      this.path = "";
    }

    ApiManager.prototype.setPath = function(path) {
      var arr;
      if (typeof path !== "string") {
        return console.error("Illegal Path: " + path + " --Suzaku.ApiManager");
      }
      arr = path.split('');
      if (arr[arr.length - 1] === "/") {
        arr[arr.length - 1] = "";
      }
      path = arr.join('');
      if (debug) {
        console.log(path);
      }
      return this.path = path;
    };

    ApiManager.prototype.setMethod = function(method) {
      if (method !== "get" && method !== "post") {
        return console.error("Illegal method " + method + " --Suzaku.ApiManager");
      }
      return this.method = method;
    };

    ApiManager.prototype.setErrorHandler = function(errorCode, handler) {
      return this.errorHandlers[errorCode] = handler;
    };

    ApiManager.prototype.setRequestFailHandler = function(handler) {
      return this.errorHandlers.requestFail = handler;
    };

    ApiManager.prototype.declare = function() {
      var JAjaxOptions, name, newApi, params, url;
      name = arguments[0];
      if (typeof arguments[1] === "string") {
        url = arguments[1];
        if (url.indexOf('/') === 0) {
          url = url.slice(1);
        }
        params = arguments[2] || [];
        JAjaxOptions = arguments[3] || {};
      } else {
        url = name;
        params = arguments[1] || [];
        JAjaxOptions = arguments[2] || {};
      }
      newApi = new Api(name, params, JAjaxOptions, "" + this.path + "/" + url, this.method, this.errorHandlers);
      return this.apis[name] = newApi;
    };

    ApiManager.prototype.generate = function() {
      var api, apiObj, name, _ref;
      apiObj = {};
      _ref = this.apis;
      for (name in _ref) {
        api = _ref[name];
        apiObj[name] = this._generate(api);
      }
      this.apis = {};
      return apiObj;
    };

    ApiManager.prototype._generate = function(api) {
      return function() {
        api.send.apply(api, arguments);
        return api;
      };
    };

    return ApiManager;

  })(EventEmitter);

  KeybordManager = (function(_super) {
    __extends(KeybordManager, _super);

    function KeybordManager() {
      _ref = KeybordManager.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    KeybordManager.prototype.init = function() {
      var pushedKey;
      pushedKey = {};
      window.onkeydown = function(evt) {
        var keyCode, name, _ref1, _results;
        _ref1 = window.Suzaku.Key;
        _results = [];
        for (name in _ref1) {
          keyCode = _ref1[name];
          if (evt.keyCode === keyCode) {
            pushedKey[name] = true;
            break;
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      };
      window.onkeyup = function(evt) {
        var keyCode, name, _ref1, _results;
        _ref1 = window.Suzaku.Key;
        _results = [];
        for (name in _ref1) {
          keyCode = _ref1[name];
          if (evt.keyCode === keyCode) {
            pushedKey[name] = false;
            break;
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      };
      return pushedKey;
    };

    return KeybordManager;

  })(EventEmitter);

  window.Suzaku = new Suzaku;

  window.Suzaku.Utils = Utils = {
    createQueue: function(number, callback) {
      var q, timer;
      q = new EventEmitter();
      timer = 0;
      q.next = function() {
        this.emit("next");
        timer += 1;
        if (timer >= number) {
          this.emit("complete");
          if (callback) {
            return callback();
          }
        }
      };
      return q;
    },
    localData: function(action, key, value) {
      var v;
      switch (action) {
        case "set":
        case "save":
          if (typeof value === "undefined") {
            return console.error("no value to save.");
          } else {
            window.localStorage.setItem(name, JSON.stringify(value));
            return true;
          }
          break;
        case "get":
        case "read":
          v = window.localStorage.getItem(name);
          if (!v) {
            return null;
          }
          try {
            return JSON.parse(v);
          } catch (_error) {
            return v;
          }
          break;
        case "clear":
        case "remove":
          window.localStorage.removeItem(name);
          return true;
        default:
          return console.error("invailid localData action:" + action);
      }
    },
    bindMobileClick: function(dom, callback) {
      var J;
      if (!dom) {
        return console.error("no dom exist --Suzaku.bindMobileClick");
      }
      if (typeof callback !== "function") {
        console.error("callback need to be function --Suzaku.bindMobileClick");
        return;
      }
      if (dom instanceof $) {
        J = dom;
        J.on("touchend", function(evt) {
          J.off("mouseup");
          return callback.call(this, evt);
        });
        return J.on("mouseup", function(evt) {
          J.off("touchend");
          return callback.call(this, evt);
        });
      } else {
        if (dom.dom instanceof HTMLElement) {
          dom = dom.dom;
        } else {
          if (!(dom instanceof HTMLElement)) {
            if (debug) {
              console.error("invailid dom exist --Suzaku.bindMobileClick", dom);
            }
            return;
          }
        }
        dom.ontouchend = function(evt) {
          dom.onmouseup = null;
          return callback.call(this, evt);
        };
        return dom.onmouseup = function(evt) {
          dom.ontouchend = null;
          return callback.call(this, evt);
        };
      }
    },
    setLocalStorage: function(obj) {
      var item, name, _results;
      _results = [];
      for (name in obj) {
        item = obj[name];
        _results.push(window.localStorage[name] = item);
      }
      return _results;
    },
    free: function() {
      var i, index, item, name, target, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = arguments.length; _i < _len; _i++) {
        target = arguments[_i];
        if (!target) {
          continue;
        }
        if (target instanceof Array) {
          _results.push((function() {
            var _j, _len1, _results1;
            _results1 = [];
            for (index = _j = 0, _len1 = target.length; _j < _len1; index = ++_j) {
              i = target[index];
              _results1.push(target[index] = null);
            }
            return _results1;
          })());
        } else if (typeof target === "object") {
          _results.push((function() {
            var _results1;
            _results1 = [];
            for (name in target) {
              item = target[name];
              _results1.push(delete target[name]);
            }
            return _results1;
          })());
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    },
    clone: function(target, deepClone) {
      var index, item, name, newArr, newObj, _i, _len;
      if (deepClone == null) {
        deepClone = false;
      }
      if (target instanceof Array) {
        newArr = [];
        for (index = _i = 0, _len = target.length; _i < _len; index = ++_i) {
          item = target[index];
          newArr[index] = deepClone ? Utils.clone(item, true) : item;
        }
        return newArr;
      }
      if (typeof target === 'object') {
        newObj = {};
        for (name in target) {
          item = target[name];
          newObj[name] = deepClone ? Utils.clone(item, true) : item;
        }
        return newObj;
      }
      if (target) {

      }
    },
    compare: function(a, b) {
      if (a === b) {
        return true;
      }
      if (parseInt(a) === parseInt(b)) {
        return true;
      }
      if (Math.abs(parseFloat(a) - parseFloat(b)) < 0.0001) {
        return true;
      }
      return false;
    },
    generateId: function(source) {
      if (typeof source !== "object") {
        return console.log("type of source need to be Object --Suzaku.generateId");
      }
      if (!source.__idCounter) {
        source.__idCounter = 0;
      }
      source.__idCounter += 1;
      return source.__idCounter;
    },
    removeItemByIndex: function(source, index) {
      if (index < 0 || index > (source.length - 1)) {
        return console.error("invailid index:" + index + " for source:", source);
      }
      return source.splice(index, 1);
    },
    removeItem: function(source, target, value) {
      var index, item, name, _i, _len, _results, _results1;
      if (source instanceof Array) {
        _results = [];
        for (index = _i = 0, _len = source.length; _i < _len; index = ++_i) {
          item = source[index];
          if (item === target) {
            _results.push(Utils.removeItemByIndex(source, index));
          }
        }
        return _results;
      } else {
        _results1 = [];
        for (name in source) {
          item = source[name];
          if (target === item || (typeof target === "string" && item[target] === value)) {
            _results1.push(delete source[name]);
          } else {
            _results1.push(void 0);
          }
        }
        return _results1;
      }
    },
    findItem: function(source, key, value) {
      var found, item, keyname, keyvalue, name, target;
      if (typeof key === 'string' && typeof value !== 'undefined') {
        target = {};
        target[key] = value;
      } else {
        target = key;
      }
      for (name in source) {
        item = source[name];
        if (Utils.compare(item, target) === true) {
          return true;
        }
        if (typeof target === "object") {
          found = true;
          for (keyname in target) {
            keyvalue = target[keyname];
            if (Utils.compare(item[keyname], keyvalue)) {
              continue;
            } else {
              found = false;
              break;
            }
          }
          if (found) {
            return item;
          }
        }
      }
      return false;
    },
    sliceNumber: function(number, afterDotNumber, intToFloat) {
      var dotIndex, floatNumber, index, intNumber, s, snumber, _i;
      if (afterDotNumber == null) {
        afterDotNumber = 2;
      }
      if (intToFloat == null) {
        intToFloat = false;
      }
      if (isNaN(number)) {
        console.warn("NaN is not Number --Suzaku sliceNumber");
        return 0;
      }
      afterDotNumber = parseInt(afterDotNumber);
      floatNumber = parseFloat(number);
      intNumber = parseInt(number);
      if (!floatNumber && intNumber !== 0) {
        return console.error("argument:" + number + " is not number --Suzaku.sliceNumber");
      }
      snumber = number.toString();
      dotIndex = snumber.indexOf('.');
      if (dotIndex < 0) {
        if (intToFloat) {
          s = '';
          for (index = _i = 1; 1 <= afterDotNumber ? _i <= afterDotNumber : _i >= afterDotNumber; index = 1 <= afterDotNumber ? ++_i : --_i) {
            s += '0';
          }
          return "" + number + "." + s;
        } else {
          return number;
        }
      } else {
        return snumber.slice(0, dotIndex + afterDotNumber + 1);
      }
    },
    parseTime: function(time, form, returnArr) {
      var arr, index, keys, value, _i, _len;
      if (!form) {
        form = "Y年M月D日h点m分";
      }
      keys = ["Y", "M", "D", "d", "h", "m", "s"];
      arr = form.split('');
      time = new Date(time);
      for (index = _i = 0, _len = arr.length; _i < _len; index = ++_i) {
        value = arr[index];
        switch (value) {
          case "Y":
            arr[index] = time.getFullYear();
            break;
          case "M":
            arr[index] = time.getMonth() + 1;
            break;
          case "D":
            arr[index] = time.getDate();
            break;
          case "d":
            switch (parseInt(time.getDay())) {
              case 1:
                arr[index] = "一";
                break;
              case 2:
                arr[index] = "二";
                break;
              case 3:
                arr[index] = "三";
                break;
              case 4:
                arr[index] = "四";
                break;
              case 5:
                arr[index] = "五";
                break;
              case 6:
                arr[index] = "六";
                break;
              case 0:
                arr[index] = "日";
            }
            break;
          case "h":
            arr[index] = time.getHours();
            break;
          case "m":
            arr[index] = time.getMinutes();
            break;
          case "s":
            arr[index] = time.getSeconds();
            break;
          default:
            continue;
        }
      }
      if (returnArr) {
        return arr;
      } else {
        return arr.join('');
      }
    }
  };

  window.Suzaku.Key = {
    0: 48,
    1: 49,
    2: 50,
    3: 51,
    4: 52,
    5: 53,
    6: 54,
    7: 55,
    8: 56,
    9: 57,
    a: 65,
    b: 66,
    c: 67,
    d: 68,
    e: 69,
    f: 70,
    g: 71,
    h: 72,
    i: 73,
    j: 74,
    k: 75,
    l: 76,
    m: 77,
    n: 78,
    o: 79,
    p: 80,
    q: 81,
    r: 82,
    s: 83,
    t: 84,
    u: 85,
    v: 86,
    w: 87,
    x: 88,
    y: 89,
    z: 90,
    space: 32,
    shift: 16,
    ctrl: 17,
    alt: 18,
    left: 37,
    right: 39,
    down: 40,
    up: 38,
    enter: 13,
    backspace: 8,
    escape: 27,
    del: 46,
    esc: 27,
    pageup: 33,
    pagedown: 34,
    tab: 9
  };

  window.Suzaku.Mouse = {
    left: 0,
    middle: 1,
    right: 2
  };

}).call(this);
