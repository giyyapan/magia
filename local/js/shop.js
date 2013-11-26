// Generated by CoffeeScript 1.6.3
(function() {
  var ShopMenu,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  ShopMenu = (function(_super) {
    __extends(ShopMenu, _super);

    function ShopMenu(shop) {
      this.shop = shop;
      ShopMenu.__super__.constructor.call(this, Res.tpls['shop-menu']);
      this.detailsBox = new ItemDetailsBox().appendTo(this.UI['right-section']);
      this.UI['welcome-traid'].onclick = function() {
        return shop.traid();
      };
      this.UI['welcome-conversation'].onclick = function() {
        return shop.conversation();
      };
      this.UI['welcome-exit'].onclick = function() {
        return shop.exit();
      };
      this.show();
    }

    ShopMenu.prototype.showWelcomOptions = function() {
      return this.UI['welcome-options'].J.fadeIn("fast");
    };

    return ShopMenu;

  })(Menu);

  window.Shop = (function(_super) {
    __extends(Shop, _super);

    function Shop(game, name) {
      Shop.__super__.constructor.call(this, game);
      this.db = game.db;
      this.originData = this.db.shops.get(name);
      this.relationship = this.game.player.relationships[this.originData.npc];
      this.bg = new Layer(Res.imgs[this.originData.bg]);
      this.drawQueueAdd(this.bg);
      this.menu = new ShopMenu(this);
      this.initWelcomDialog();
    }

    Shop.prototype.exit = function() {
      var _this = this;
      this.menu.J.fadeOut("fast");
      return this.dialogBox.display({
        text: this.originData.exitText,
        nostop: true
      }, function() {
        return _this.dialogBox.hide(function() {
          return _this.bg.fadeOut("fast", function() {
            return _this.game.switchStage("worldMap");
          });
        });
      });
    };

    Shop.prototype.conversation = function() {};

    Shop.prototype.traid = function() {};

    Shop.prototype.getDataByRelationship = function(from) {
      var data, found, required;
      found = null;
      for (required in from) {
        data = from[required];
        if (parseInt(required) <= this.relationship) {
          found = data;
        } else {
          break;
        }
      }
      return found;
    };

    Shop.prototype.initWelcomDialog = function() {
      var text,
        _this = this;
      this.dialogBox = new DialogBox();
      this.dialogBox.show();
      text = this.getDataByRelationship(this.originData.welcomeText);
      return this.dialogBox.display({
        text: text,
        speaker: this.originData.npcName,
        nostop: true
      }, function() {
        return _this.menu.showWelcomOptions();
      });
    };

    return Shop;

  })(Stage);

}).call(this);
