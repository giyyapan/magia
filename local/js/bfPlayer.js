// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.BattlefieldPlayer = (function(_super) {
    __extends(BattlefieldPlayer, _super);

    function BattlefieldPlayer(battlefield, x, y, playerData) {
      this.db = battlefield.db;
      this.playerData = playerData;
      BattlefieldPlayer.__super__.constructor.call(this, battlefield, x, y, this.db.sprites.get("player"), playerData);
      this.castPositionX = 100;
      this.castPositionY = -100;
      console.log(this);
      this.animateClock.setRate(10);
      this.name = "player";
      this.bf = battlefield;
      this.lifeBar = new Widget(this.bf.menu.UI['life-bar']);
      this.lifeBar.UI['life-text'].J.text("" + (parseInt(this.hp)) + "/" + this.realStatusValue.hp);
    }

    BattlefieldPlayer.prototype.act = function() {
      BattlefieldPlayer.__super__.act.apply(this, arguments);
      this.bf.camera.lookAt({
        x: this.x + 100,
        y: this.y - 150
      }, 400, 1.7);
      return this.bf.menu.showActionBtns();
    };

    BattlefieldPlayer.prototype.attack = function(target) {
      var defaultPos, listener,
        _this = this;
      this.z = 10;
      this.bf.mainLayer.sortDrawQueue();
      this.bf.setView("default");
      defaultPos = {
        x: this.x,
        y: this.y
      };
      this.animateClock.setRate(10);
      this.useMovement("attack");
      listener = this.on("keyFrame", function(index, length) {
        return _this.attackFire(target);
      });
      return this.once("endMove:attack", function() {
        _this.off("keyFrame", listener);
        _this.z = -1;
        _this.bf.mainLayer.sortDrawQueue();
        return _this.useMovement(_this.defaultMovement, true);
      });
    };

    BattlefieldPlayer.prototype.attackFire = function(target) {
      var damage, effect, statusValue,
        _this = this;
      statusValue = this.realStatusValue;
      new BlendLayer(this, "rgba(79, 175, 212, 0.81)", "flash", 150);
      damage = {
        normal: statusValue.atk
      };
      this.handleAttackDamage(damage);
      window.AudioManager.play("playerCast");
      effect = new BfEffectSprite(this.bf, this.db.sprites.get("energyBall"), this, target);
      return effect.on("active", function() {
        target.onHurt(_this, damage);
        return _this.bf.paused = false;
      });
    };

    BattlefieldPlayer.prototype.defense = function() {
      var bl,
        _this = this;
      this.isDefensed = true;
      bl = new BlendLayer(this, "rgba(238, 215, 167, 0.4)");
      this.speedItem.speedGage += 30;
      this.bf.setView("normal");
      this.once("act", function() {
        _this.isDefensed = false;
        return _this.drawQueueRemove(bl);
      });
      return this.bf.paused = false;
    };

    BattlefieldPlayer.prototype.useSpell = function(type, sourceSupplies, target) {
      var _this = this;
      console.log("cast spell to ", target);
      this.bf.setView("normal");
      this.useMovement("attack");
      this.once("keyFrame", function() {
        window.AudioManager.play("playerCast");
        return BattlefieldPlayer.__super__.useSpell.call(_this, type, sourceSupplies, target);
      });
      sourceSupplies.remainCount -= 1;
      if (sourceSupplies.remainCount < 0) {
        return this.playerData.removeThing(sourceSupplies);
      }
    };

    BattlefieldPlayer.prototype.addFlipOverEffect = function(effect) {};

    BattlefieldPlayer.prototype.onBuff = function(effect) {};

    BattlefieldPlayer.prototype.onHeal = function(from, value) {
      BattlefieldPlayer.__super__.onHeal.apply(this, arguments);
      if (this.hp > this.realStatusValue.hp) {
        this.hp = this.realStatusValue.hp;
      }
      return this.updateLifeBar("heal");
    };

    BattlefieldPlayer.prototype.onHurt = function(from, damage) {
      BattlefieldPlayer.__super__.onHurt.apply(this, arguments);
      if (this.hp <= 1 && this.bf.data.nolose) {
        this.hp = 1;
      }
      if (this.hp <= 0) {
        this.hp = 0;
        this.updateLifeBar();
        return this.die();
      } else {
        return this.updateLifeBar();
      }
    };

    BattlefieldPlayer.prototype.updateLifeBar = function(type) {
      var J,
        _this = this;
      if (type == null) {
        type = "damage";
      }
      J = this.lifeBar.UI['life-inner'].J;
      if (type === "damage") {
        J.addClass("damage");
        this.setCallback(100, function() {
          return J.removeClass("damage");
        });
      }
      J.css("width", "" + (parseInt(this.hp / this.realStatusValue.hp * 100)) + "%");
      return this.lifeBar.UI['life-text'].J.text("" + (parseInt(this.hp)) + "/" + this.realStatusValue.hp);
    };

    BattlefieldPlayer.prototype.draw = function(context, tickDelay) {
      return BattlefieldPlayer.__super__.draw.call(this, context, tickDelay);
    };

    BattlefieldPlayer.prototype.die = function() {
      BattlefieldPlayer.__super__.die.apply(this, arguments);
      if (this.dead) {
        return;
      }
      this.dead = true;
      return this.bf.lose();
    };

    return BattlefieldPlayer;

  })(BattlefieldSprite);

}).call(this);
