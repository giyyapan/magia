// Generated by CoffeeScript 1.6.2
(function() {
  var DetailsBox, ReactionBox, ReactionBtn, ReactionConfirmBox, ReactionFinishBox, ReactionTraitItem, SourceItem, WorktableMenu,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  ReactionFinishBox = (function(_super) {
    __extends(ReactionFinishBox, _super);

    function ReactionFinishBox(reactionBox, db) {
      var hint, i, item, name, self, title, _ref;

      this.reactionBox = reactionBox;
      this.db = db;
      title = "装瓶";
      hint = "请选择要保留的属性</br><small>有一些中间属性无法被制作成药剂</small>";
      ReactionFinishBox.__super__.constructor.call(this, title, hint);
      this.UI['content-list'].J.show();
      this.UI['accept'].J.hide();
      this.dom.id = "reaction-finish-box";
      self = this;
      _ref = this.reactionBox.traitItems;
      for (name in _ref) {
        i = _ref[name];
        if (!this.db.things.supplies.get("" + i.traitName + "Potion")) {
          console.log("no supplies for trait : " + i.traitName);
          continue;
        }
        item = new TraitItem(i.traitName, i.traitValue);
        console.log("finish add trait", item);
        item.appendTo(this.UI['content-list']);
        item.dom.widget = item;
        item.dom.onclick = function() {
          return self.chooseTraitItem(this.widget);
        };
      }
      this.show();
    }

    ReactionFinishBox.prototype.chooseTraitItem = function(item) {
      var name, newSupplies;

      name = "" + item.traitName + "Potion";
      newSupplies = new PlayerSupplies(this.db, name, {
        traitValue: item.traitValue
      });
      this.emit("getNewSupplies", newSupplies);
      return this.close();
    };

    return ReactionFinishBox;

  })(PopupBox);

  ReactionTraitItem = (function(_super) {
    __extends(ReactionTraitItem, _super);

    function ReactionTraitItem() {
      ReactionTraitItem.__super__.constructor.apply(this, arguments);
      this.J.addClass("animate-popup");
    }

    return ReactionTraitItem;

  })(TraitItem);

  ReactionConfirmBox = (function(_super) {
    __extends(ReactionConfirmBox, _super);

    function ReactionConfirmBox(reaction) {
      var name, s, str, targetStr;

      ReactionConfirmBox.__super__.constructor.call(this, "合成新属性");
      str = "";
      for (name in reaction.from) {
        str += "<span class='trait-icon " + name + "'>" + Dict.TraitName[name] + "</span>";
      }
      targetStr = "<span class=trait-icon '" + name + "'>" + Dict.TraitName[reaction.to] + "</span>";
      s = "要将" + str + "转化成为" + targetStr + "吗？";
      this.UI.content.J.html(s);
      this.UI.close.J.text("取消");
      this.show();
    }

    return ReactionConfirmBox;

  })(PopupBox);

  ReactionBtn = (function(_super) {
    __extends(ReactionBtn, _super);

    function ReactionBtn(tpl, reaction, avail, reactionBox) {
      var index, name, span, value, _ref,
        _this = this;

      ReactionBtn.__super__.constructor.call(this, tpl);
      this.reactionBox = reactionBox;
      this.worktable = reactionBox.worktable;
      this.avail = avail;
      this.reaction = reaction;
      index = 0;
      _ref = reaction.from;
      for (name in _ref) {
        value = _ref[name];
        index += 1;
        span = this.UI["source" + index];
        span.J.addClass(name);
        span.J.text(Dict.TraitName[name].split("")[0]);
      }
      this.update(avail);
      this.J.removeClass("hide");
      this.J.addClass("animate-popup");
      this.dom.onclick = function() {
        if (!_this.avail) {
          return;
        }
        return _this.reactionBox.react(_this.reaction, function() {
          return _this.css3Animate("animate-popout", function() {
            return this.remove();
          });
        });
      };
    }

    ReactionBtn.prototype.remove = function() {
      var layer, scale;

      layer = this.worktable;
      scale = 0;
      return this.css3Animate("animate-popout", function() {
        var _this = this;

        return this.J.animate({
          width: 0,
          height: 0,
          margin: 0
        }, 200, function() {
          delete _this.reactionBox.reactionBtns[_this.reaction.to];
          return ReactionBtn.__super__.remove.apply(_this, arguments);
        });
      });
    };

    ReactionBtn.prototype.update = function(avail) {
      var span;

      this.avail = avail;
      if (this.avail) {
        span = this.UI.target;
        span.J.show();
        span.J.removeClass();
        span.J.addClass("target", this.reaction.to);
        span.J.text(Dict.TraitName[this.reaction.to].split("")[0]);
        this.UI["?"].J.hide();
        return this.J.addClass("avail");
      } else {
        this.J.removeClass("avail");
        this.UI.target.J.hide();
        return this.UI["?"].J.show();
      }
    };

    return ReactionBtn;

  })(Widget);

  ReactionBox = (function(_super) {
    __extends(ReactionBox, _super);

    function ReactionBox(tpl, menu) {
      var _this = this;

      ReactionBox.__super__.constructor.call(this, tpl);
      this.menu = menu;
      this.worktable = menu.worktable;
      this.traitItems = {};
      this.reactions = [];
      this.reactionBtns = {};
      this.initReactions();
      console.log(this.reactions);
      this.UI['finish'].onclick = function() {
        return _this.finishReaction();
      };
    }

    ReactionBox.prototype.finishReaction = function() {
      var box,
        _this = this;

      box = new ReactionFinishBox(this, this.worktable.game.db);
      return box.on("getNewSupplies", function(s) {
        var i, n, _ref;

        _ref = _this.traitItems;
        for (n in _ref) {
          i = _ref[n];
          i.remove();
        }
        _this.traitItems = {};
        new MsgBox("获得物品", "你获得了" + s.dspName + "！");
        return _this.worktable.game.player.getSupplies("backpack", s);
      });
    };

    ReactionBox.prototype.initReactions = function() {
      var fromTraitsArr, obj, r, t, trait, _i, _j, _len, _len1, _ref, _results;

      _ref = this.worktable.db.rules.get("reaction");
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        r = _ref[_i];
        fromTraitsArr = r.split("->")[0].split(",");
        obj = {
          from: {},
          fromTraitsCount: fromTraitsArr.length,
          to: r.split("->")[1]
        };
        for (_j = 0, _len1 = fromTraitsArr.length; _j < _len1; _j++) {
          trait = fromTraitsArr[_j];
          t = trait.split(":");
          obj.from[t[0]] = parseInt(t[1]);
        }
        _results.push(this.reactions.push(obj));
      }
      return _results;
    };

    ReactionBox.prototype.putInItem = function(playerItem) {
      var i, name, old, value, _ref;

      _ref = playerItem.traits;
      for (name in _ref) {
        value = _ref[name];
        if (!this.traitItems[name]) {
          this.traitItems[name] = new ReactionTraitItem(name, value).insertTo(this.UI['current-traits-list']);
        } else {
          i = this.traitItems[name];
          old = i.traitValue;
          console.log(i);
          i.changeValue(parseInt(value * value / (old + value) + old));
        }
      }
      return this.tryReaction();
    };

    ReactionBox.prototype.tryReaction = function() {
      var avail, lvValue, name, r, _i, _len, _ref, _ref1, _results;

      _ref = this.reactions;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        r = _ref[_i];
        avail = 0;
        _ref1 = r.from;
        for (name in _ref1) {
          lvValue = _ref1[name];
          if (!this.traitItems[name]) {
            avail = 0;
            break;
          }
          if (this.traitItems[name].lv >= lvValue) {
            if (avail === 0) {
              avail = 2;
            }
          } else {
            avail = 1;
          }
        }
        switch (avail) {
          case 0:
            continue;
          case 1:
            _results.push(this.addReactionBtn(r, false));
            break;
          case 2:
            _results.push(this.addReactionBtn(r, true));
            break;
          default:
            _results.push(void 0);
        }
      }
      return _results;
    };

    ReactionBox.prototype.addReactionBtn = function(r, avail) {
      var btn, tpl;

      console.log(r, avail);
      if (this.reactionBtns[r.to]) {
        return this.reactionBtns[r.to].update(avail);
      } else {
        tpl = this.UI["reaction-btn-tpl-" + r.fromTraitsCount].innerHTML;
        btn = new ReactionBtn(tpl, r, avail, this);
        btn.appendTo(this.UI['avail-reaction-list']);
        return this.reactionBtns[r.to] = btn;
      }
    };

    ReactionBox.prototype.react = function(reaction, callback) {
      var box, name, value,
        _this = this;

      console.log("react", reaction);
      value = 0;
      for (name in reaction.from) {
        value += parseInt(this.traitItems[name].traitValue);
      }
      box = new ReactionConfirmBox(reaction);
      return box.on("accept", function() {
        var newTraits;

        value = value / reaction.fromTraitsCount;
        if (callback) {
          callback();
        }
        newTraits = {};
        newTraits[reaction.to] = value;
        return _this.combineTraitItems(reaction, newTraits);
      });
    };

    ReactionBox.prototype.combineTraitItems = function(reaction, newTraits) {
      var i, index, items, name, self, targetTop, _i, _len;

      self = this;
      items = [];
      for (name in reaction.from) {
        items.push(this.traitItems[name]);
      }
      for (index = _i = 0, _len = items.length; _i < _len; index = ++_i) {
        i = items[index];
        targetTop = this.UI['traits-box'].offsetTop;
        i.dom.traitName = i.traitName;
        i.css3Animate("animate-popout", function() {
          var _this = this;

          return this.J.animate({
            height: 0,
            margin: 0
          }, 200, function() {
            _this.remove();
            return delete self.traitItems[_this.traitName];
          });
        });
      }
      return this.putInItem({
        traits: newTraits
      });
    };

    return ReactionBox;

  })(Widget);

  DetailsBox = (function(_super) {
    __extends(DetailsBox, _super);

    function DetailsBox(menu) {
      var _this = this;

      DetailsBox.__super__.constructor.apply(this, arguments);
      this.menu = menu;
      this.worktable = menu.worktable;
      this.locked = false;
      this.UI['use-btn'].J.html("添加");
      this.UI['use-btn'].onclick = function() {
        if (_this.locked) {
          return;
        }
        if (_this.currentItem) {
          return _this.worktable.putInItem(_this.currentItem);
        }
      };
      this.UI['header-flag'].J.remove();
      this.UI['cancel-btn'].onclick = function() {
        _this.menu.UI['source-list'].J.find("li").removeClass("selected");
        return _this.J.fadeOut(100);
      };
    }

    return DetailsBox;

  })(ItemDetailsBox);

  SourceItem = (function(_super) {
    __extends(SourceItem, _super);

    function SourceItem(tpl, menu, playerItem) {
      var _this = this;

      SourceItem.__super__.constructor.call(this, tpl, playerItem);
      this.playerItem = playerItem;
      if (this.UI.img) {
        this.UI.img.src = this.originData.img;
      }
      this.UI.name.J.text(this.originData.name);
      if (playerItem.number) {
        this.UI.number.J.text(playerItem.number);
      }
      this.dom.onclick = function(evt) {
        return menu.detailsBox.showItemDetails(_this);
      };
    }

    SourceItem.prototype.update = function() {
      if (this.playerItem.number) {
        return this.UI.number.J.text(this.playerItem.number);
      }
    };

    return SourceItem;

  })(ListItem);

  WorktableMenu = (function(_super) {
    __extends(WorktableMenu, _super);

    function WorktableMenu(tpl, worktable) {
      var _this = this;

      WorktableMenu.__super__.constructor.call(this, tpl);
      this.worktable = worktable;
      this.player = worktable.player;
      this.detailsBox = new DetailsBox(this);
      this.detailsBox.appendTo(this.UI['item-details-box-wrapper']);
      this.reactionBox = new ReactionBox(this.UI['reaction-box'], this);
      this.initItems();
      this.UI['exit-btn'].onclick = function() {
        return _this.worktable.close();
      };
    }

    WorktableMenu.prototype.initItems = function() {
      var i, _i, _j, _len, _len1, _ref, _ref1, _results;

      _ref = this.player.backpack;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        i = _ref[_i];
        if (i.type === "item") {
          this.addSourceItem(i);
        }
      }
      _ref1 = this.player.storage;
      _results = [];
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        i = _ref1[_j];
        if (i.type === "item") {
          _results.push(this.addSourceItem(i));
        }
      }
      return _results;
    };

    WorktableMenu.prototype.addSourceItem = function(item) {
      var w;

      w = new SourceItem(this.UI['source-item-tpl'].innerHTML, this, item);
      return w.appendTo(this.UI['source-list']);
    };

    return WorktableMenu;

  })(Menu);

  window.Worktable = (function(_super) {
    __extends(Worktable, _super);

    function Worktable(home) {
      Worktable.__super__.constructor.apply(this, arguments);
      this.home = home;
      this.game = home.game;
      this.db = this.game.db;
      this.player = this.game.player;
      this.floor = home.secondFloor;
      this.menu = new WorktableMenu(Res.tpls['worktable-menu'], this);
      this.menu.show();
    }

    Worktable.prototype.putInItem = function(item) {
      var _this = this;

      if (item.playerItem.number > 1) {
        item.playerItem.number -= 1;
        item.update();
      } else {
        this.player.removeThing(item.playerItem);
        this.menu.detailsBox.locked = true;
        this.menu.detailsBox.J.fadeOut("fast", function() {
          return _this.menu.detailsBox.locked = false;
        });
        item.J.slideUp(150, function() {
          return item.remove();
        });
      }
      return this.menu.reactionBox.putInItem(item.playerItem);
    };

    Worktable.prototype.close = function() {
      var _this = this;

      this.menu.hide();
      return this.fadeOut(150, function() {
        return _this.emit("close");
      });
    };

    return Worktable;

  })(Layer);

}).call(this);
