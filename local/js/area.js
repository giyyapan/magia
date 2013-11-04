// Generated by CoffeeScript 1.6.3
(function() {
  var GatherResaultBox, Place,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Place = (function(_super) {
    __extends(Place, _super);

    function Place(area, db, name, data) {
      var index, item, moveTarget, p, self, _i, _j, _len, _len1, _ref, _ref1,
        _this = this;
      this.area = area;
      this.db = db;
      this.name = name;
      this.data = data;
      Place.__super__.constructor.call(this);
      this.bg = new Layer(Res.imgs[this.data.bg]);
      this.menu = new Menu(Res.tpls['area-menu']);
      this.menu.J.addClass(this.name);
      this.menu.UI.backpack.onclick = function() {
        return _this.emit("showBackpack");
      };
      this.menu.show();
      this.resPoints = [];
      this.drawQueueAddAfter(this.bg);
      this.initItems();
      self = this;
      _ref = this.data.resPoints;
      for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
        p = _ref[index];
        item = new Suzaku.Widget(this.menu.UI['res-point-tpl'].J.html());
        item.J.html("采集点" + (index + 1));
        item.dom.number = index + 1;
        item.J.addClass("gp" + (index + 1));
        item.appendTo(this.menu.UI['res-point-box']);
        item.dom.onclick = function() {
          return self.handleGatherResault(self.gatherItem(this.number));
        };
      }
      _ref1 = this.data.movePoints;
      for (index = _j = 0, _len1 = _ref1.length; _j < _len1; index = ++_j) {
        moveTarget = _ref1[index];
        item = new Suzaku.Widget(this.menu.UI['move-point-tpl'].innerHTML);
        item.J.html(moveTarget);
        item.dom.target = moveTarget;
        item.J.addClass("mp-" + moveTarget);
        item.appendTo(this.menu.UI['move-point-box']);
        item.dom.onclick = function() {
          return area.enterPlace(this.target);
        };
      }
    }

    Place.prototype.initItems = function() {
      var gatherData, i, index, item, itemData, name, _i, _len, _ref, _ref1;
      _ref = this.data.resPoints;
      for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
        i = _ref[index];
        this.resPoints.push([]);
      }
      _ref1 = this.db.things.items;
      for (name in _ref1) {
        itemData = _ref1[name];
        if (!itemData.gather) {
          continue;
        }
        item = new GatherItem(name, itemData);
        gatherData = item.getGatherDataByPlace(this.area.name, this.name);
        if (gatherData) {
          this.resPoints[gatherData.resPoint - 1].push(item);
        }
      }
      return console.log(this.resPoints);
    };

    Place.prototype.gatherItem = function(resPointNum) {
      var gatherNumber, index, item, items, res, _i, _len;
      index = resPointNum - 1;
      items = this.resPoints[index];
      res = [];
      if (items.length === 0) {
        return null;
      }
      for (_i = 0, _len = items.length; _i < _len; _i++) {
        item = items[_i];
        gatherNumber = item.tryGather();
        if (gatherNumber) {
          res.push({
            gatherItem: item,
            number: gatherNumber
          });
        }
      }
      return res;
    };

    Place.prototype.handleGatherResault = function(data) {
      var box;
      if (typeof data !== "string") {
        return this.emit("getItem", data);
      } else {
        box = new GatherResaultBox("什么也没有采集到");
        return box.show();
      }
    };

    return Place;

  })(Layer);

  GatherResaultBox = (function(_super) {
    __extends(GatherResaultBox, _super);

    function GatherResaultBox(data) {
      var itemResData, number, originData, w, _i, _len;
      GatherResaultBox.__super__.constructor.call(this);
      this.UI.title.J.text("采集结果");
      if (typeof data === "string") {
        this.UI.content.J.text(data);
      } else {
        this.UI.content.J.hide();
        this.UI['content-list'].J.show();
        for (_i = 0, _len = data.length; _i < _len; _i++) {
          itemResData = data[_i];
          originData = itemResData.gatherItem.originData;
          number = itemResData.number;
          console.log(itemResData);
          w = new ThingListWidget(originData, number);
          w.appendTo(this.UI['content-list']);
        }
      }
    }

    return GatherResaultBox;

  })(PopupBox);

  window.Area = (function(_super) {
    __extends(Area, _super);

    function Area(game, areaName) {
      Area.__super__.constructor.call(this, game);
      this.game = game;
      this.name = areaName;
      this.data = game.db.areas[areaName];
      this.backpackMenu = new Backpack(game, "gatherArea");
      this.enterPlace("entry");
    }

    Area.prototype.enterPlace = function(placeName) {
      var placeData,
        _this = this;
      if (placeName === "exit") {
        return this.game.switchStage("worldMap");
      }
      placeData = this.data.places[placeName];
      if (!placeData) {
        console.error("no place:" + placeName);
      }
      this.currentPlace = new Place(this, this.game.db, placeName, placeData);
      this.clearDrawQueue();
      this.drawQueueAddAfter(this.currentPlace);
      this.currentPlace.on("getItem", function(itemDataArr) {
        return _this.getItem(itemDataArr);
      });
      return this.currentPlace.on("showBackpack", function() {
        return _this.showBackpack();
      });
    };

    Area.prototype.showBackpack = function() {
      var self;
      console.log("show backpack");
      console.log(this.backpackMenu);
      self = this;
      this.backpackMenu.on("close", function() {
        var _this = this;
        self.currentPlace.onShow = true;
        return self.backpackMenu.hide(function() {
          return self.currentPlace.menu.show();
        });
      });
      return this.backpackMenu.show(function() {
        return self.currentPlace.onShow = false;
      });
    };

    Area.prototype.getItem = function(itemDataArr) {
      var box, data, name, number, originData, _i, _len;
      if (!this.game.player.checkFreeSpace("backpack", itemDataArr)) {
        return;
      }
      for (_i = 0, _len = itemDataArr.length; _i < _len; _i++) {
        data = itemDataArr[_i];
        name = data.gatherItem.name;
        originData = data.gatherItem.originData;
        number = data.number;
        this.game.player.getItem("backpack", {
          name: name,
          originData: originData,
          number: number
        });
      }
      box = new GatherResaultBox(itemDataArr);
      return box.show();
    };

    return Area;

  })(Stage);

}).call(this);
