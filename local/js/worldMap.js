// Generated by CoffeeScript 1.6.2
(function() {
  var MapPoint,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  MapPoint = (function(_super) {
    __extends(MapPoint, _super);

    function MapPoint(tpl, data) {
      MapPoint.__super__.constructor.call(this, tpl);
      this.UI["map-summary-name"].innerHTML = data.name;
    }

    return MapPoint;

  })(Widget);

  window.WorldMap = (function(_super) {
    __extends(WorldMap, _super);

    function WorldMap(game) {
      var data, forestData, img, imgName, map, name, newItem, _i, _len, _ref;

      WorldMap.__super__.constructor.call(this);
      this.game = game;
      map = new Layer();
      this.player = this.game.player;
      this.db = this.game.db;
      forestData = this.db.areas.get("forest");
      forestData.description;
      this.menu = new Menu(Res.tpls['world-map']);
      _ref = ["forest", "snowmountain"];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        name = _ref[_i];
        data = this.db.areas.get(name);
        imgName = data.summaryImg;
        img = window.Res.imgs[imgName];
        console.log(this.UI);
        newItem = new MapPoint(this.menu.UI['map-point-tpl'].innerHTML, data);
        newItem.appendTo(this.menu.UI['map-summary-holder']);
      }
      map.setImg(Res.imgs.worldMap);
      console.log(this.menu);
      this.menu.show();
      this.drawQueueAddAfter(map, this.menu);
      this.menu.UI.home.onclick = function() {
        return game.switchStage("home");
      };
      this.menu.UI.town.onclick = function() {
        return game.switchStage("town");
      };
      this.menu.UI.forest.onclick = function() {
        return game.switchStage("area", "forest");
      };
      this.menu.UI.snowmountain.onclick = function() {
        return game.switchStage("area", "snowmountain");
      };
    }

    return WorldMap;

  })(Stage);

}).call(this);
