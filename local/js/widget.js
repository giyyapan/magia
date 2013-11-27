// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.PopupBox = (function(_super) {
    __extends(PopupBox, _super);

    function PopupBox(title, content) {
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
    }

    PopupBox.prototype.show = function() {
      this.appendTo(this.UILayer);
      this.J.fadeIn("fast");
      this.box.J.show();
      return this.box.J.addClass("animate-popup");
    };

    PopupBox.prototype.close = function() {
      var self;
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
      if (item.playerSupplies) {
        this.UI['remain-count-hint'].J.show();
        this.UI['remain-count'].innerHTML = "" + item.playerSupplies.remainCount + "/5";
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

    return ItemDetailsBox;

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
