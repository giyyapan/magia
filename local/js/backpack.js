// Generated by CoffeeScript 1.6.2
(function() {
  var DetailsBox, ThingListItem,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  ThingListItem = (function(_super) {
    __extends(ThingListItem, _super);

    function ThingListItem(playerThing) {
      var originData,
        _this = this;

      console.log(playerThing);
      ThingListItem.__super__.constructor.call(this, Res.tpls['thing-list-item']);
      originData = playerThing.originData;
      if (originData.img) {
        this.UI.img.src = originData.img.src;
      }
      this.UI.name.J.text(originData.name);
      if (playerThing.number) {
        this.UI.quatity.J.text(playerThing.number);
      }
      this.originData = originData;
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
          console.error("invailid playerThing type:" + playerThing.type);
      }
      this.dom.onclick = function() {
        return _this.emit("select");
      };
    }

    return ThingListItem;

  })(Widget);

  DetailsBox = (function(_super) {
    __extends(DetailsBox, _super);

    function DetailsBox(backpack) {
      DetailsBox.__super__.constructor.apply(this, arguments);
      this.dom.id = "item-details-box";
      this.bp = backpack;
      this.UI['cancel-btn'].J.hide();
    }

    return DetailsBox;

  })(ItemDetailsBox);

  window.Backpack = (function(_super) {
    __extends(Backpack, _super);

    function Backpack(game, type) {
      Backpack.__super__.constructor.call(this, Res.tpls["backpack"]);
      this.J.hide();
      this.player = game.player;
      this.detailsBox = new DetailsBox(this).appendTo(this.UI['item-details-box-wrapper']);
      this.currentTabName = "item";
      this.initThings();
      this.items = null;
      this.supplies = null;
      this.materials = null;
      this.equipments = null;
      this.initButtons();
    }

    Backpack.prototype.initButtons = function() {
      var self,
        _this = this;

      self = this;
      this.UI['exit-btn'].onclick = function() {
        return _this.emit("close");
      };
      return this.UI['type-switch'].J.find(".tab").on("click", function() {
        if (!$(this).attr("value")) {
          return;
        }
        return self.switchTab($(this).attr("value"));
      });
    };

    Backpack.prototype.initThings = function(type) {
      var source, tabName, thing, _i, _len, _ref;

      if (type == null) {
        type = "gatherArea";
      }
      this.freeThings();
      tabName = this.currentTabName;
      if (type === "gatherArea") {
        source = this.player.backpack;
      }
      _ref = this.player.backpack;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        thing = _ref[_i];
        console.log(thing);
        switch (thing.type) {
          case "item":
            this.items.push(thing);
            break;
          case "supplies":
            this.supplies.push(thing);
            break;
          case "material":
            this.materials.push(thing);
            break;
          case "equipment":
            this.equipments.push(thing);
        }
      }
      return this.switchTab(tabName);
    };

    Backpack.prototype.switchTab = function(tabName) {
      var arr, item, self, thing, _i, _len, _results;

      this.UI['item-list'].J.html("");
      this.detailsBox.J.fadeOut("fast");
      self = this;
      this.UI['type-switch'].J.find(".tab").removeClass("selected");
      switch (tabName) {
        case "item":
          arr = this.items;
          this.UI['item-tab'].J.addClass("selected");
          break;
        case "supplies":
          arr = this.supplies;
          this.UI['supplies-tab'].J.addClass("selected");
          break;
        case "equipment":
          arr = this.equipments;
          this.UI['equipments-tab'].J.addClass("selected");
          break;
        default:
          console.error("wrong type", tabName);
      }
      console.log(arr);
      if (!arr) {
        return;
      }
      _results = [];
      for (_i = 0, _len = arr.length; _i < _len; _i++) {
        thing = arr[_i];
        item = new ThingListItem(thing);
        item.appendTo(this.UI['item-list']);
        _results.push(item.on("select", function() {
          return self.selectThing(this);
        }));
      }
      return _results;
    };

    Backpack.prototype.selectThing = function(item) {
      this.J.find("thing-list-item").removeClass("selected");
      console.log(item);
      return this.detailsBox.showItemDetails(item);
    };

    Backpack.prototype.freeThings = function() {
      Utils.free(this.items, this.supplies, this.materials, this.equipments);
      this.items = [];
      this.supplies = [];
      this.materials = [];
      return this.equipments = [];
    };

    Backpack.prototype.show = function(callback) {
      this.init();
      this.initThings();
      this.UILayer.J.fadeIn("fast", callback);
      return this.J.slideDown("fast", function() {
        if (callback) {
          return callback();
        }
      });
    };

    Backpack.prototype.hide = function(callback) {
      Backpack.__super__.hide.call(this);
      return this.J.slideUp("fast", function() {
        if (callback) {
          return callback();
        }
      });
    };

    return Backpack;

  })(Menu);

}).call(this);
