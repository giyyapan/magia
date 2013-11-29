// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.PopupBox = (function(_super) {
    __extends(PopupBox, _super);

    function PopupBox(title, content, acceptCallbcak) {
      var self;
      PopupBox.__super__.constructor.call(this, Res.tpls['popup-box']);
      this.box = this.UI.box;
      this.J.hide();
      this.box.J.hide();
      if (title) {
        this.UI.title.J.html(title);
      }
      if (content) {
        this.UI.content.J.html(content);
      }
      this.UILayer = $(GameConfig.UILayerId);
      self = this;
      this.UI['close'].onclick = function() {
        return self.close();
      };
      this.UI['accept'].onclick = function() {
        return self.accept();
      };
      if (acceptCallbcak) {
        this.on("accept", acceptCallbcak);
        this.show();
      }
    }

    PopupBox.prototype.setCloseText = function(t) {
      return this.UI.close.J.text(t);
    };

    PopupBox.prototype.setAcceptText = function(t) {
      return this.UI.accept.J.text(t);
    };

    PopupBox.prototype.show = function() {
      this.appendTo(this.UILayer);
      this.J.fadeIn("fast");
      this.box.J.show();
      return this.box.J.addClass("animate-popup");
    };

    PopupBox.prototype.close = function() {
      var self;
      this.emit("close");
      self = this;
      this.J.fadeOut("fast");
      return this.box.J.animate({
        top: "-=30px",
        opacity: 0
      }, "fast", function() {
        self.box.J.css("top", 0);
        self.box.J.removeClass("animate-popup");
        self.J.remove();
        return self = null;
      });
    };

    PopupBox.prototype.accept = function() {
      console.log(this, "accept");
      this.emit("accept");
      return this.close();
    };

    return PopupBox;

  })(Widget);

  window.MsgBox = (function(_super) {
    __extends(MsgBox, _super);

    function MsgBox(title, content, autoRemove) {
      var _this = this;
      if (autoRemove == null) {
        autoRemove = false;
      }
      MsgBox.__super__.constructor.apply(this, arguments);
      if (autoRemove) {
        if (autoRemove === true) {
          autoRemove = 1000;
        }
        this.UI.footer.J.hide();
        window.setTimeout((function() {
          return _this.close();
        }), autoRemove);
      } else {
        this.UI.accept.J.hide();
      }
      this.show();
    }

    return MsgBox;

  })(PopupBox);

  window.TraitItem = (function(_super) {
    __extends(TraitItem, _super);

    function TraitItem(name, value) {
      TraitItem.__super__.constructor.call(this, Res.tpls['trait-item']);
      this.traitName = name;
      this.traitValue = value;
      this.lv = 1;
      this.UI.name.J.text(Dict.TraitName[this.traitName]);
      this.UI.name.J.addClass(this.traitName);
      this.changeValue(this.traitValue);
    }

    TraitItem.prototype.changeValue = function(value) {
      var activeDom, index, levelData, v, width, _i, _len;
      this.traitValue = value;
      levelData = Dict.QualityLevel;
      for (index = _i = 0, _len = levelData.length; _i < _len; index = ++_i) {
        v = levelData[index];
        if (value < v) {
          break;
        }
      }
      this.lv = parseInt(index + 1);
      this.UI['trait-holder'].J.removeClass("lv1", "lv2", "lv3", "lv4", "lv5", "lv6");
      this.UI['trait-holder'].J.addClass("lv" + this.lv);
      this.J.find(".lv").removeClass("active");
      this.J.find(".filled").css("width", "100%");
      activeDom = this.UI["lv" + this.lv];
      activeDom.J.addClass("active");
      width = (value - (levelData[index - 1] || 0)) / (levelData[index] - (levelData[index - 1] || 0)) * 100;
      activeDom.J.find(".filled").css("width", "" + (parseInt(width)) + "%");
      this.UI.cursor.J.appendTo(activeDom);
      return this.UI.cursor.J.animate({
        left: "" + (parseInt(width) - 1) + "%"
      }, 10);
    };

    return TraitItem;

  })(Widget);

  window.ItemDetailsBox = (function(_super) {
    __extends(ItemDetailsBox, _super);

    function ItemDetailsBox(tpl) {
      ItemDetailsBox.__super__.constructor.call(this, Res.tpls['item-details-box']);
      this.currentItem = null;
    }

    ItemDetailsBox.prototype.showItemDetails = function(item) {
      var t;
      if (item.playerSupplies) {
        this.UI['remain-count-hint'].J.show();
        t = "" + item.playerSupplies.remainCount + "/" + item.playerSupplies.maxRemainCount;
        this.UI['remain-count'].J.text(t);
      } else {
        this.UI['remain-count-hint'].J.hide();
      }
      this.UI['content'].J.hide();
      if (this.currentItem) {
        this.currentItem.J.removeClass("selected");
      }
      this.currentItem = item;
      item.J.addClass("selected");
      this.UI.name.J.text(item.originData.name);
      if (item.originData.img) {
        this.UI.img.src = item.originData.img.src;
      }
      this.UI.description.J.text(item.originData.description);
      this.initTraits(item.playerItem);
      this.initTraits(item.playerSupplies);
      this.J.fadeIn("fast");
      return this.UI['content'].J.fadeIn(100);
    };

    ItemDetailsBox.prototype.initTraits = function(thingData) {
      var name, value, _ref, _results;
      if (!thingData || !thingData.traits) {
        return;
      }
      this.UI['traits-list'].J.html("");
      _ref = thingData.traits;
      _results = [];
      for (name in _ref) {
        value = _ref[name];
        _results.push(new TraitItem(name, value).appendTo(this.UI['traits-list']));
      }
      return _results;
    };

    ItemDetailsBox.prototype.hide = function() {
      this.J.fadeOut("fast");
      return this.currentItem.J.removeClass("selected");
    };

    return ItemDetailsBox;

  })(Widget);

  window.MissionDetailsBox = (function(_super) {
    __extends(MissionDetailsBox, _super);

    function MissionDetailsBox(game) {
      var _this = this;
      MissionDetailsBox.__super__.constructor.call(this, Res.tpls['mission-details-box']);
      this.game = game;
      this.UI['active-btn'].onclick = function() {
        return _this.emit("activeMission", _this.currentWidget.mission, _this.currentWidget);
      };
    }

    MissionDetailsBox.prototype.setBtnText = function(text) {
      if (!text) {
        this.UI['active-btn'].J.fadeOut("fast");
      }
      return this.UI['active-btn'].J.text(text);
    };

    MissionDetailsBox.prototype.hide = function(callback) {
      return this.J.fadeOut("fast", callback);
    };

    MissionDetailsBox.prototype.updateStatusText = function() {
      var text;
      text = "";
      switch (this.currentWidget.mission.status) {
        case "current":
          text = "进行中";
          break;
        case "finished":
          text = "已结束";
          break;
        case "avail":
          text = "可接受";
          break;
        case "disable":
          text = "条件不足";
          break;
        default:
          console.error("invailid status", this.currentWidget.mission);
      }
      return this.UI.status.J.text(text);
    };

    MissionDetailsBox.prototype.initMissionData = function(mission) {
      var character, data, dspName, finished, index, monster, monsterName, name, rewardText, sum, thing, value, _ref, _ref1, _results;
      this.UI.title.J.text(mission.dspName);
      this.UI.description.J.text(mission.data.description.replace(/\|/g, "</br>"));
      this.UI['details-content-list'].J.html("");
      data = mission.data;
      if (data.from) {
        character = this.game.db.characters.get(data.from);
        console.log(data.from, this.game.db.characters.get(data.from));
        this.addContentListItem("委托人", character.name);
      }
      rewardText = "";
      _ref = data.reward;
      for (name in _ref) {
        value = _ref[name];
        switch (name) {
          case "money":
            rewardText += "" + value + "G ";
        }
      }
      this.addContentListItem("奖励", rewardText);
      if (data.requests.text) {
        return this.addContentListItem("要求", data.requests.text);
      } else {
        this.addContentListItem("要求");
        _ref1 = data.requests;
        _results = [];
        for (name in _ref1) {
          value = _ref1[name];
          switch (name) {
            case "kill":
              _results.push((function() {
                var _i, _len, _ref2, _results1;
                _ref2 = value.split(",");
                _results1 = [];
                for (index = _i = 0, _len = _ref2.length; _i < _len; index = ++_i) {
                  monster = _ref2[index];
                  sum = monster.split('*')[1] || 1;
                  monsterName = monster.split("*")[0];
                  dspName = this.game.db.monsters.get(monsterName).name;
                  finished = sum - mission.incompletedRequests.kill[monsterName];
                  _results1.push(this.addContentListItem(null, "打败" + sum + "只" + dspName + " " + finished + "/" + sum));
                }
                return _results1;
              }).call(this));
              break;
            case "visit":
              console.log(value);
              dspName = this.game.db.areas.get(value).name;
              console.log(mission, mission.incompletedRequests);
              if (mission.incompletedRequests.visit[value]) {
                _results.push(this.addContentListItem(null, "去往 " + dspName, false));
              } else {
                _results.push(this.addContentListItem(null, "去往 " + dspName, true));
              }
              break;
            case "get":
              _results.push((function() {
                var _i, _len, _ref2, _results1;
                _ref2 = value.split(",");
                _results1 = [];
                for (index = _i = 0, _len = _ref2.length; _i < _len; index = ++_i) {
                  thing = _ref2[index];
                  console.log(this.game.db.things.get(thing));
                  dspName = this.game.db.things.get(thing).name;
                  if (mission.incompletedRequests.get[thing]) {
                    _results1.push(this.addContentListItem(null, "获得 " + dspName, false));
                  } else {
                    _results1.push(this.addContentListItem(null, "获得 " + dspName, true));
                  }
                }
                return _results1;
              }).call(this));
              break;
            default:
              _results.push(void 0);
          }
        }
        return _results;
      }
    };

    MissionDetailsBox.prototype.addContentListItem = function(type, content, completedMark) {
      var tpl, w;
      if (completedMark == null) {
        completedMark = false;
      }
      tpl = this.UI['content-list-item-tpl'].innerHTML;
      w = new Widget(tpl);
      if (type) {
        w.UI.type.J.text(type);
      }
      if (content) {
        w.UI.content.J.text(content);
      }
      if (!completedMark) {
        w.UI.completed.J.hide();
      }
      return w.appendTo(this.UI['details-content-list']);
    };

    MissionDetailsBox.prototype.showMissionDetails = function(widget, callback) {
      var mission,
        _this = this;
      console.log("show mission");
      if (this.currentWidget) {
        this.currentWidget.J.removeClass("selected");
      }
      this.currentWidget = widget;
      mission = widget.missionData;
      this.updateStatusText();
      this.initMissionData(mission);
      switch (mission.status) {
        case "current":
          if (mission.checkComplete()) {
            this.setBtnText("完成");
            this.UI['active-btn'].onclick = function() {
              mission.complete();
              _this.emit("activeMission", mission);
              return _this.hide(callback);
            };
          } else {
            this.setBtnText("关闭");
            this.UI['active-btn'].onclick = function() {
              return _this.hide(callback);
            };
          }
          break;
        case "avail":
          this.setBtnText("接受");
          this.UI['active-btn'].onclick = function() {
            mission.start();
            _this.emit("activeMission", mission);
            return _this.hide(callback);
          };
          break;
        case "finished":
          this.setBtnText("关闭");
          this.UI['active-btn'].onclick = function() {
            return _this.hide(callback);
          };
      }
      return this.J.fadeIn("fast");
    };

    return MissionDetailsBox;

  })(Widget);

  window.ListItem = (function(_super) {
    __extends(ListItem, _super);

    function ListItem(tpl, playerThing) {
      var _this = this;
      ListItem.__super__.constructor.call(this, tpl);
      if (!playerThing) {
        return;
      }
      this.name = playerThing.name;
      this.dspName = playerThing.dspName;
      this.originData = playerThing.originData;
      this.playerThing = playerThing;
      this.type = playerThing.type;
      switch (playerThing.type) {
        case "item":
          this.playerItem = playerThing;
          break;
        case "supplies":
          this.playerSupplies = playerThing;
          break;
        case "equipment":
          this.playerEquipment = playerThing;
          break;
        default:
          console.error("invailid type", playerThing.type);
      }
      this.dom.onclick = function() {
        if (_this.active) {
          return _this.active();
        }
      };
    }

    ListItem.prototype.active = null;

    return ListItem;

  })(Widget);

}).call(this);
