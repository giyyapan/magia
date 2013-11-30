// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.Imgs = {
    summaryForest: 'worldMap/map-summary-forest.jpg',
    summarySnow: 'worldMap/map-summary-snowmountain.jpg',
    summaryHome: 'worldMap/map-summary-home.jpg',
    summaryShop: 'worldMap/map-summary-shop.jpg',
    forestEntry: 'forest-entry.jpg',
    forestEntryFloat1: 'forest-entry-float.png',
    forestEntryFloat2: 'forest-entry-float2.png',
    forestLake: 'forest-lake.jpg',
    snowmountainEntryBg: 'snowmountain-entry-bg.jpg',
    snowmountainEntryMain: 'snowmountain-entry-main.png',
    snowmountainEntryFloat: 'snowmountain-entry-float.png',
    snowmountainMiddle: 'snowmountain-middle.jpg',
    snowmountainCave: 'snowmountain-cave.jpg',
    snowmountainCaveFloat: 'snowmountain-cave-float.png',
    startBg: "start-bg.jpg",
    startBgLight: "start-bg-light.jpg",
    bfForestMain: 'bf-forest-main.jpg',
    bfForestFloat: 'bf-forest-float.png',
    bfSnowmountain: 'bf-snowmountain.jpg',
    playerDialog: 'characters/player-dialog.png',
    catDialog: 'characters/cat-dialog.png',
    lunaDialog: 'characters/luna-dialog.png',
    lilithDialog: 'characters/lilith-dialog.png',
    dirakDialog: 'characters/dirak-dialog.png',
    layer1: 'layer1.png',
    layer2: 'layer2.png',
    layer3: 'layer3.png',
    layer4: 'layer4.png',
    layer5: 'layer5.png',
    layer6: 'layer6.png',
    magicShopBg: 'magic-shop-bg.jpg',
    equipShopBg: 'equip-shop-bg.jpg',
    guildBg: 'guild-bg.jpg',
    homeDownMain: 'home-down-main.jpg',
    homeDownFloat: "home-down-float.png",
    homeUp: 'home_up.jpg',
    dialogContinueHint: 'menu/dialog-continue-hint.png',
    dialogBg: 'menu/dialog-bg.png',
    item_earthLow: 'things/earthLow.jpg',
    item_earthMid: 'things/earthMid.jpg',
    item_earthHigh: 'things/earthHigh.jpg',
    item_fireLow: 'things/fireLow.jpg',
    item_fireMid: 'things/fireMid.jpg',
    item_fireHigh: 'things/fireHigh.jpg',
    item_waterLow: 'things/waterLow.jpg',
    item_waterHigh: 'things/waterHigh.jpg',
    item_airMid: 'things/airMid.jpg',
    item_iceLow: 'things/iceLow.jpg',
    item_iceMid: 'things/iceMid.jpg',
    item_iceHigh: 'things/iceHigh.jpg',
    item_lifeLow: 'things/lifeLow.jpg',
    item_lifeMid: 'things/lifeMid.jpg',
    item_minusLow: 'things/minusLow.jpg',
    item_minusMid: 'things/minusMid.jpg',
    item_spiritLow: 'things/spiritLow.jpg',
    item_spiritMid: 'things/spiritMid.jpg',
    item_timeLow: "things/timeLow.jpg",
    item_spaceLow: "things/spaceLow.jpg"
  };

  window.Sprites = {
    qq: "qq",
    pig: "pig"
  };

  window.Templates = ["start-menu", "home-menu", "world-map", "popup-box", "test-menu", "area-menu", "shop-menu", "guild-menu", "area-relative-menu", "thing-list-item", "backpack", "battlefield-menu", "worktable-menu", "item-details-box", "trait-item", "dialog-box", "mission-details-box", "story"];

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
        this.loadSprite(sprite);
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

    ResourceManager.prototype.loadSprite = function(sprite) {
      var i, self;
      self = this;
      i = new Image();
      console.log(this.spritePath);
      i.src = this.spritePath + sprite.mapSrc;
      i.dataSrc = this.spritePath + sprite.dataSrc;
      i.name = sprite.name;
      return i.addEventListener("load", function() {
        var img;
        img = this;
        return $.get(img.dataSrc, function(data) {
          self.loaded.sprites[img.name] = {
            map: img,
            data: data
          };
          return self._resOnload('sprite');
        });
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
