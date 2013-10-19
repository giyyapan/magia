(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.Imgs = {
    buttonCenter: 'button_center.png',
    map: 'map.gif',
    demonMap: 'demonMap.gif',
    elfMap: 'elfMap.gif'
  };

  window.ResourceManager = (function(_super) {

    __extends(ResourceManager, _super);

    function ResourceManager() {
      ResourceManager.__super__.constructor.call(this);
      this.imgs = [];
      this.sounds = [];
      this.templates = [];
      this.loadedNum = 0;
      this.totalResNum = null;
      this.loaded = {
        imgs: {},
        sounds: {},
        templates: {}
      };
      this.imgPath = "";
      this.soundPath = "";
      this.tplPath = "";
    }

    ResourceManager.prototype.useImg = function(name, src) {
      return this.imgs.push({
        name: name,
        src: src
      });
    };

    ResourceManager.prototype.useSound = function(sound) {
      return this.sounds.push(sound);
    };

    ResourceManager.prototype.useTemplate = function(template) {
      return this.templates.push(template);
    };

    ResourceManager.prototype.setPath = function(type, path) {
      var arr;
      if (typeof path !== "string") {
        if (gameConfig.debug) {
          return console.error("Illegal Path: " + path + " --ResManager");
        }
      }
      arr = path.split('');
      if (arr[arr.length - 1] !== "/") {
        arr.push("/");
      }
      path = arr.join('');
      switch (type) {
        case "img":
          return this.imgPath = path;
        case "sound":
          return this.soundPath = path;
        case "template":
          return this.tplPath = path;
      }
    };

    ResourceManager.prototype.start = function(callback) {
      var ajaxManager, i, img, localDir, req, tplName, url, _i, _j, _len, _len1, _ref, _ref1,
        _this = this;
      if (typeof callback === "function") {
        this.on("load", callback);
      }
      this.loadedNum = 0;
      this.totalResNum = this.imgs.length + this.sounds.length + this.templates.length;
      ajaxManager = new Suzaku.AjaxManager;
      _ref = this.imgs;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        img = _ref[_i];
        console.log(img);
        i = new Image();
        i.src = this.imgPath + img.src;
        i.addEventListener("load", function() {
          _this.loaded.imgs[img.name] = i;
          return _this._resOnload('img');
        });
      }
      localDir = this.tplPath;
      _ref1 = this.templates;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        tplName = _ref1[_j];
        url = name.indexOf(".html") > -1 ? localDir + tplName : localDir + tplName + ".html";
        req = ajaxManager.addGetRequest(url, null, function(data, textStatus, req) {
          _this.loaded.templates[req.Suzaku_tplName] = data;
          return _this._resOnload('template');
        });
        req.Suzaku_tplName = tplName;
      }
      return ajaxManager.start(function() {
        if (gameConfig.debug) {
          return console.log("template loaded");
        }
      });
    };

    ResourceManager.prototype._resOnload = function(type) {
      this.loadedNum += 1;
      this.emit("loadOne", this.totalResNum, this.loadedNum, type);
      if (this.loadedNum >= this.totalResNum) {
        return this.emit("load", this.loaded);
      }
    };

    return ResourceManager;

  })(Suzaku.EventEmitter);

}).call(this);
