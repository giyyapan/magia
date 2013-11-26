// Generated by CoffeeScript 1.6.2
(function() {
  var MapPoint, popBig,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  popBig = (function(_super) {
    __extends(popBig, _super);

    function popBig(tpl, data, game, name) {
      var _this = this;

      popBig.__super__.constructor.call(this, tpl);
      window.heheGame = game;
      this.game = game;
      this.UI['title'].innerHTML = data.name;
      this.UI['description'].innerHTML = data.description;
      this.UI['danger-level'].innerHTML = data.dangerLevel;
      this.costEnergy = this.UI['cost-energy'];
      this.costEnergy.innerHTML = data.costEnergy;
      this.dom.onclick = function() {
        return _this.css3Animate("animate-popout", 400, function() {
          return _this.remove();
        });
      };
      this.UI['popBig'].onclick = function(evt) {
        return evt.stopPropagation();
      };
      this.UI['enter-btn'].onclick = function() {
        var nowEnergy;

        switch (name) {
          case "home":
            return _this.game.switchStage("home");
          case "shop":
            return _this.game.switchStage("shop");
          default:
            nowEnergy = _this.game.player.energy;
            if (nowEnergy < data.costEnergy) {
              _this.css3Animate.call(_this.costEnergy, "animate-warning", 550);
              return _this.costEnergy.innerHTML = "" + data.costEnergy + "(您的体力不足！！)";
            } else {
              _this.game.switchStage("area", name);
              _this.game.player.energy -= data.costEnergy;
              return _this.game.player.saveData();
            }
        }
      };
    }

    return popBig;

  })(Widget);

  MapPoint = (function(_super) {
    __extends(MapPoint, _super);

    function MapPoint(tpl, data, menu, game, name) {
      var _this = this;

      MapPoint.__super__.constructor.call(this, tpl);
      this.menu = menu;
      this.UI["map-summary-name"].innerHTML = data.name;
      this.UI["map-summary-pic"].J.css("background", "url(" + Res.imgs[data.summaryImg].src + ")");
      this.dom.onclick = function() {
        var myPopBig;

        myPopBig = new popBig(_this.menu.UI['map-popBig-tpl'].innerHTML, data, game, name);
        return myPopBig.appendTo(_this.menu);
      };
    }

    return MapPoint;

  })(Widget);

  window.WorldMap = (function(_super) {
    __extends(WorldMap, _super);

    function WorldMap(game) {
      var data, img, imgName, map, myDate, name, newItem, nowDay, nowEnergy, nowHours, nowMon, _i, _len, _ref;

      WorldMap.__super__.constructor.call(this);
      this.game = game;
      map = new Layer();
      this.player = this.game.player;
      this.db = this.game.db;
      this.menu = new Menu(Res.tpls['world-map']);
      this.menu.show();
      this.drawQueueAddAfter(map, this.menu);
      nowEnergy = this.player.energy;
      myDate = new Date();
      nowMon = myDate.getMonth();
      nowDay = myDate.getDate();
      nowHours = myDate.getHours();
      this.menu.UI["energy"].innerHTML = "体力:" + nowEnergy;
      this.menu.UI["time"].innerHTML = "" + (nowMon + 1) + " 月 " + nowDay + " 日";
      if (nowHours > 0 && nowHours < 20) {
        this.menu.UI["day-night"].innerHTML = "昼";
      } else {
        this.menu.UI["day-night"].innerHTML = "夜";
      }
      _ref = ["home", "shop", "forest", "snowmountain"];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        name = _ref[_i];
        data = this.db.areas.get(name);
        imgName = data.summaryImg;
        img = window.Res.imgs[imgName];
        newItem = new MapPoint(this.menu.UI['map-point-tpl'].innerHTML, data, this.menu, game, name);
        newItem.appendTo(this.menu.UI['map-summary-holder']);
      }
    }

    return WorldMap;

  })(Stage);

}).call(this);
