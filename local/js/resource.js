// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.Imgs = {
    buttonCenter: 'button_center.png',
    item: 'item.png',
    forestEntry: 'forest-entry.jpg',
    forestEntryFloat: 'forest-entry-float.png',
    forestEntryFloat2: 'forest-entry-float2.png',
    forest2: 'forest2.jpg',
    forest3: 'forest3.jpg',
    bfForestMain: 'bf-forest-main.jpg',
    bfForestFloat: 'bf-forest-float.png',
    layer1: 'layer1.png',
    layer2: 'layer2.png',
    layer3: 'layer3.png',
    layer4: 'layer4.png',
    layer5: 'layer5.png',
    layer6: 'layer6.png',
    worldMap: 'map.gif',
    demonMap: 'demonMap.gif',
    elfMap: 'elfMap.gif',
    homeDown: 'home_down.jpg',
    homeUp: 'home_up.jpg'
  };

  window.Sprites = {
    test: "test"
  };

  window.Templates = ["start-menu", "home-1st-floor", "home-2nd-floor", "world-map", "popup-box", "test-menu", "area-menu", "area-relative-menu", "thing-list-item", "backpack", "battlefield-menu"];

  window.Css = [];

  window.ResourceManager = (function(_super) {
    __extends(ResourceManager, _super);

    function ResourceManager() {
      ResourceManager.__super__.constructor.call(this);
      this.imgs = [];
      this.sprites = [];
      this.sounds = [];
      this.templates = [];
      this.loadedNum = 0;
      this.totalResNum = null;
      this.loaded = {
        imgs: {},
        sounds: {},
        sprites: {},
        templates: {}
      };
      this.imgPath = "";
      this.spritePath = "";
      this.soundPath = "";
      this.tplPath = "";
    }

    ResourceManager.prototype.useImg = function(name, src) {
      return this.imgs.push({
        name: name,
        src: src
      });
    };

    ResourceManager.prototype.useSprite = function(name, src) {
      var dataSrc, mapSrc;
      mapSrc = "" + src + ".png";
      dataSrc = "" + src + ".json";
      return this.sprites.push({
        name: name,
        mapSrc: mapSrc,
        dataSrc: dataSrc
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
        if (window.GameConfig.debug) {
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
        case "sprite":
          return this.spritePath = path;
        case "template":
          return this.tplPath = path;
      }
    };

    ResourceManager.prototype.start = function(callback) {
      var ajaxManager, i, img, localDir, req, self, sprite, tplName, url, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2,
        _this = this;
      if (typeof callback === "function") {
        this.on("load", callback);
      }
      this.loadedNum = 0;
      this.totalResNum = this.imgs.length + this.sprites.length + this.sounds.length + this.templates.length;
      ajaxManager = new Suzaku.AjaxManager;
      self = this;
      _ref = this.imgs;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        img = _ref[_i];
        console.log(img);
        i = new Image();
        i.src = this.imgPath + img.src;
        i.name = img.name;
        i.addEventListener("load", function() {
          self.loaded.imgs[this.name] = this;
          return self._resOnload('img');
        });
      }
      _ref1 = this.sprites;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        sprite = _ref1[_j];
        i = new Image();
        console.log(this.spritePath);
        i.src = this.spritePath + sprite.mapSrc;
        i.dataSrc = this.spritePath + sprite.dataSrc;
        i.name = sprite.name;
        i.addEventListener("load", function() {
          img = this;
          return $.get(img.dataSrc, function(data) {
            console.log(data);
            self.loaded.sprites[img.name] = {
              map: img,
              data: data
            };
            return self._resOnload('sprite');
          });
        });
      }
      localDir = this.tplPath;
      _ref2 = this.templates;
      for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
        tplName = _ref2[_k];
        url = name.indexOf(".html") > -1 ? localDir + tplName : localDir + tplName + ".html";
        req = ajaxManager.addGetRequest(url, null, function(data, textStatus, req) {
          _this.loaded.templates[req.Suzaku_tplName] = data;
          return _this._resOnload('template');
        });
        req.Suzaku_tplName = tplName;
      }
      return ajaxManager.start(function() {
        if (GameConfig.debug) {
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
