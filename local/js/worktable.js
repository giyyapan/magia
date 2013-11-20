// Generated by CoffeeScript 1.6.3
(function() {
  var DetailsBox, ReactionBox, SourceItem, WorktableMenu,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  ReactionBox = (function(_super) {
    __extends(ReactionBox, _super);

    function ReactionBox(tpl, menu) {
      ReactionBox.__super__.constructor.call(this, tpl);
      this.menu = menu;
      this.worktable = menu.worktable;
      this.traitsItems = {};
    }

    ReactionBox.prototype.putInItem = function(playerItem) {
      var i, name, old, value, _ref, _results;
      _ref = playerItem.traits;
      _results = [];
      for (name in _ref) {
        value = _ref[name];
        if (!this.traitsItems[name]) {
          _results.push(this.traitsItems[name] = new TraitsItem(name, value).appendTo(this.UI['current-traits-list']));
        } else {
          i = this.traitsItems[name];
          old = i.traitsValue;
          _results.push(i.changeValue(parseInt(value * value / (old + value) + old)));
        }
      }
      return _results;
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
      SourceItem.__super__.constructor.call(this, tpl);
      this.originData = playerItem.originData;
      this.playerItem = playerItem;
      console.log(this);
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

  })(Widget);

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