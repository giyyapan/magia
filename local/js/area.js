// Generated by CoffeeScript 1.6.3
(function() {
  var GatherResaultBox, Place, ResPoint,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  ResPoint = (function(_super) {
    __extends(ResPoint, _super);

    function ResPoint(place, tpl, data, index) {
      var _this = this;
      ResPoint.__super__.constructor.call(this, tpl);
      this.place = place;
      this.data = data;
      this.index = index;
      this.number = index + 1;
      this.pointText = "采集点" + (index + 1);
      this.items = [];
      this.monsters = {
        certain: null,
        random: []
      };
      this.UI.name.J.text(this.pointText);
      this.dom.number = index + 1;
      this.J.addClass("gp" + (index + 1));
      this.J.css({
        position: "absolute",
        left: data.split(",")[0] + "px",
        top: data.split(",")[1] + "px"
      }, this.dom.onclick = function(evt) {
        evt.stopPropagation();
        return _this.emit("active", _this.active());
      });
    }

    ResPoint.prototype.initItems = function(resourcesData, db) {
      var gatherData, item, itemData, name, _i, _len, _ref, _results;
      if (!resourcesData[this.index]) {
        return;
      }
      _ref = resourcesData[this.index].split(",");
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        name = _ref[_i];
        itemData = db.things.items.get(name);
        console.log(itemData);
        item = new GatherItem(name, itemData);
        gatherData = item.getGatherData();
        _results.push(this.items.push(item));
      }
      return _results;
    };

    ResPoint.prototype.initMonsters = function(monstersData, db) {
      var mdata, _i, _j, _len, _len1, _ref, _ref1, _results;
      _ref = monstersData.random;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        mdata = _ref[_i];
        if (Utils.compare(mdata.split(":")[0], this.number)) {
          this.monsters.random.push(mdata.split(":")[1]);
        }
      }
      if (this.monsters.random.length > 0) {
        this.UI.name.J.text(this.pointText + "（可）");
      }
      _ref1 = monstersData.certain;
      _results = [];
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        mdata = _ref1[_j];
        if (Utils.compare(mdata.split(":")[0], this.number)) {
          this.monsters.certain = mdata.split(":")[1];
          _results.push(this.UI.name.J.text(this.pointText + "（必）"));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    ResPoint.prototype.handleEncounteringMonster = function() {
      var index, m, _i, _len, _ref,
        _this = this;
      if (this.monsters.certain) {
        this.place.once("battleWin", function() {
          return _this.monsters.certain = null;
        });
        return this.monsters.certain.split(",");
      }
      _ref = this.monsters.random;
      for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
        m = _ref[index];
        if (Math.random() < 0.3) {
          this.randomMonsterIndex = index;
          this.place.once("battleWin", function() {
            Utils.removeItemByIndex(_this.monsters.random, _this.randomMonsterIndex);
            return delete _this.randomMonsterIndex;
          });
          return m.split(",");
        }
      }
      return false;
    };

    ResPoint.prototype.active = function() {
      var gatherNumber, item, items, monsters, _i, _len, _ref;
      console.log("active");
      monsters = this.handleEncounteringMonster();
      if (monsters) {
        return {
          type: "monster",
          monsters: monsters
        };
      } else {
        items = [];
        _ref = this.items;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          item = _ref[_i];
          gatherNumber = item.tryGather();
          if (gatherNumber) {
            items.push({
              gatherItem: item,
              number: gatherNumber
            });
          }
        }
        return {
          type: "item",
          items: items
        };
      }
      return {
        type: "empty"
      };
    };

    return ResPoint;

  })(Suzaku.Widget);

  Place = (function(_super) {
    __extends(Place, _super);

    function Place(area, db, name, data) {
      var self;
      this.area = area;
      this.db = db;
      this.name = name;
      this.data = data;
      Place.__super__.constructor.call(this);
      this.camera = new Camera();
      if (this.data.defaultX) {
        this.camera.x = this.data.defaultX;
      }
      this.drawQueueAddAfter(this.camera);
      this.initBg();
      this.initMenu();
      this.resPoints = [];
      this.currentX = 0;
      self = this;
    }

    Place.prototype.tick = function() {
      var changed, s;
      s = Utils.getSize();
      if (Key.up) {
        if (Key.shift) {
          this.camera.scale += 0.03;
        }
      }
      if (Key.down) {
        if (Key.shift) {
          this.camera.scale -= 0.03;
        }
      }
      if (Key.right) {
        this.currentX += 15;
        changed = true;
      }
      if (Key.left) {
        this.currentX -= 15;
        changed = true;
      }
      if (this.currentX < 0) {
        this.currentX = 0;
      }
      if (this.currentX > this.mainBg.width - s.width) {
        this.currentX = this.mainBg.width - s.width;
      }
      if (changed) {
        return this.camera.x = this.camera.getOffsetPositionX(this.currentX, this.mainBg);
      }
    };

    Place.prototype.initBg = function() {
      var bg, data, imgName, initLayer, _ref, _ref1;
      initLayer = function(layer, detail) {
        var name, value, _results;
        _results = [];
        for (name in detail) {
          value = detail[name];
          if (name === "fixToBottom") {
            _results.push(layer.fixToBottom());
          } else {
            _results.push(layer[name] = value);
          }
        }
        return _results;
      };
      this.floatBgs = [];
      this.bgs = [];
      if (this.data.bg) {
        _ref = this.data.bg;
        for (imgName in _ref) {
          data = _ref[imgName];
          bg = new Layer().setImg(Res.imgs[imgName]);
          console.log(bg, data);
          initLayer(bg, data);
          this.bgs.push(bg);
          this.camera.render(bg);
        }
      }
      if (this.data.floatBg) {
        _ref1 = this.data.floatBg;
        for (imgName in _ref1) {
          data = _ref1[imgName];
          bg = new Layer().setImg(Res.imgs[imgName]);
          console.log(bg, data);
          initLayer(bg, data);
          this.floatBgs.push(bg);
          this.camera.render(bg);
        }
      }
      return this.mainBg = this.bgs[0];
    };

    Place.prototype.initMenu = function() {
      var index, moveCallback, moveTarget, p, s, _i, _j, _len, _len1, _ref, _ref1,
        _this = this;
      s = Utils.getSize();
      this.menu = new Menu(Res.tpls['area-menu']);
      this.menu.J.addClass(this.name);
      this.menu.UI.title.J.text(this.data.name);
      moveCallback = function() {
        var x;
        x = _this.currentX;
        delete _this.camera.lock;
        if (x === 0) {
          _this.menu.UI['move-left'].J.removeClass("autohide").fadeOut(200);
        } else {
          _this.menu.UI['move-left'].J.addClass("autohide").fadeIn(200);
        }
        if (x === (_this.mainBg.width - s.width)) {
          return _this.menu.UI['move-right'].J.removeClass("autohide").fadeOut(200);
        } else {
          return _this.menu.UI['move-right'].J.addClass("autohide").fadeIn(200);
        }
      };
      this.menu.UI['move-right'].onclick = function(evt) {
        var x;
        evt.stopPropagation();
        console.log("right");
        _this.camera.lock = true;
        _this.currentX += 400;
        if (_this.currentX > _this.mainBg.width - s.width) {
          _this.currentX = _this.mainBg.width - s.width;
        }
        x = _this.camera.getOffsetPositionX(_this.currentX, _this.mainBg);
        if (x > _this.mainBg.width) {
          x = _this.mainBg.width;
        }
        return _this.camera.animate({
          x: x
        }, "normal", function() {
          return moveCallback();
        });
      };
      this.menu.UI['move-left'].onclick = function(evt) {
        var x;
        evt.stopPropagation();
        console.log("left");
        _this.camera.lock = true;
        _this.currentX -= 400;
        if (_this.currentX < 0) {
          _this.currentX = 0;
        }
        x = _this.camera.getOffsetPositionX(_this.currentX, _this.mainBg);
        return _this.camera.animate({
          x: x
        }, "normal", function() {
          return moveCallback();
        });
      };
      this.menu.UI.backpack.onclick = function(evt) {
        evt.stopPropagation();
        return _this.emit("showBackpack");
      };
      this.menu.dom.onclick = function(evt) {
        return _this.searchPosition(evt.offsetX, evt.offsetY);
      };
      this.relativeMenu = new Menu(Res.tpls['area-relative-menu']);
      this.relativeMenu.J.addClass(this.name);
      this.relativeMenu.z = 1000;
      this.relativeMenu.UI['res-point-box'].J.hide();
      _ref = this.data.resPoints;
      for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
        p = _ref[index];
        this.addResPoint(p, index);
      }
      _ref1 = this.data.movePoints;
      for (index = _j = 0, _len1 = _ref1.length; _j < _len1; index = ++_j) {
        moveTarget = _ref1[index];
        this.addMovePoint(moveTarget, index);
      }
      this.menu.show();
      this.relativeMenu.appendTo(this.menu.UI['relative-wrapper']);
      return this.camera.render(this.relativeMenu);
    };

    Place.prototype.searchPosition = function(x, y) {
      var bg, cx, cy, dx, dy, hEdge, realH, realW, realX, realY, s, scale, wEdge, _i, _j, _len, _len1, _ref, _ref1,
        _this = this;
      s = Utils.getSize();
      scale = 1.3;
      if (!this.scaledIn) {
        if (this.camera.lock) {
          return;
        }
        this.camera.lock = true;
        this.scaledIn = true;
        this.lastCameraPosition = {
          x: this.camera.x,
          y: this.camera.y
        };
        realW = s.width / scale;
        realH = s.height / scale;
        dx = x - s.width / 2;
        dy = y - s.height / 2;
        wEdge = s.width / 2 - realW / 2;
        hEdge = s.height / 2 - realH / 2;
        if (dx < -wEdge) {
          dx = -wEdge;
        }
        if (dx > wEdge) {
          dx = wEdge;
        }
        if (dy < -hEdge) {
          dy = -hEdge;
        }
        if (dy > hEdge) {
          dy = hEdge;
        }
        realX = this.currentX + dx;
        realY = 0 + dy;
        cx = this.camera.getOffsetPositionX(realX, this.mainBg);
        cy = this.camera.getOffsetPositionY(realY, this.mainBg);
        _ref = this.floatBgs;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          bg = _ref[_i];
          bg.animate({
            "transform.opacity": 0
          }, "fast");
        }
        this.menu.J.find(".autohide").fadeOut("fast", function() {
          return _this.relativeMenu.UI['res-point-box'].J.fadeIn("fast");
        });
        return this.camera.animate({
          x: cx,
          y: cy,
          scale: scale
        }, "fast", function() {
          return _this.camera.lock = false;
        });
      } else {
        if (this.camera.lock) {
          return;
        }
        this.camera.lock = true;
        this.scaledIn = false;
        _ref1 = this.floatBgs;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          bg = _ref1[_j];
          bg.animate({
            "transform.opacity": 1
          }, "fast");
        }
        this.relativeMenu.UI['res-point-box'].J.fadeOut("fast", function() {
          return _this.menu.J.find(".autohide").fadeIn("fast");
        });
        return this.camera.animate({
          x: this.lastCameraPosition.x,
          y: this.lastCameraPosition.y,
          scale: 1
        }, "fast", function() {
          return _this.camera.lock = false;
        });
      }
    };

    Place.prototype.addResPoint = function(p, index) {
      var point, self;
      self = this;
      point = new ResPoint(this, this.relativeMenu.UI['res-point-tpl'].J.html(), p, index);
      point.appendTo(this.relativeMenu.UI['res-point-box']);
      point.on("active", function(res) {
        return self.handleResPointActive(res);
      });
      if (this.data.resources) {
        point.initItems(this.data.resources, this.db);
      }
      if (this.data.monsters) {
        return point.initMonsters(this.data.monsters, this.db);
      }
    };

    Place.prototype.addMovePoint = function(moveTarget, index) {
      var area, item;
      area = this.area;
      item = new Suzaku.Widget(this.relativeMenu.UI['move-point-tpl'].innerHTML);
      item.UI.target.J.text(moveTarget);
      item.dom.target = moveTarget;
      item.J.addClass("mp-" + moveTarget);
      item.appendTo(this.relativeMenu.UI['move-point-box']);
      return item.dom.onclick = function() {
        return area.enterPlace(this.target);
      };
    };

    Place.prototype.handleResPointActive = function(res) {
      var box;
      if (res.type === "item") {
        return this.emit("getItem", res.items);
      } else if (res.type === "monster") {
        return this.encounterMonster(res.monsters);
      } else if (res.type === "empty") {
        box = new GatherResaultBox("什么也没有采集到");
        return box.show();
      } else {
        if (GameConfig.debug) {
          return console.error("invailid res type of res point :" + res);
        }
      }
    };

    Place.prototype.encounterMonster = function(monsters) {
      console.log("encounter monsters:", monsters);
      return this.area.initBattlefield(monsters);
    };

    return Place;

  })(Layer);

  window.Area = (function(_super) {
    __extends(Area, _super);

    function Area(game, areaName) {
      Area.__super__.constructor.call(this, game);
      this.game = game;
      this.name = areaName;
      this.data = game.db.areas.get(areaName);
      this.backpackMenu = new Backpack(game, "gatherArea");
      this.enterPlace("entry");
      this.initBattlefield(["qq", "qq", "qq"]);
    }

    Area.prototype.initBattlefield = function(monsters) {
      var battlefield, data,
        _this = this;
      data = {
        monsters: monsters,
        bg: this.data.battlefieldBg
      };
      battlefield = new window.Battlefield(this.game, data);
      this.hide(function() {
        _this.game.currentStage = battlefield;
        return battlefield.show();
      });
      battlefield.on("win", function() {
        _this.show();
        _this.game.currentStage = _this;
        _this.emit("battleWin");
        _this.currentPlace.emit("battleWin");
        return _this.currentPlace.menu.show();
      });
      return battlefield.on("lose", function() {
        _this.show();
        _this.game.currentStage = _this;
        _this.emit("battleLose");
        _this.currentPlace.emit("battleLose");
        return _this.currentPlace.menu.show();
      });
    };

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

    Area.prototype.tick = function() {
      if (this.currentPlace.tick) {
        return this.currentPlace.tick();
      }
    };

    return Area;

  })(Stage);

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

}).call(this);
