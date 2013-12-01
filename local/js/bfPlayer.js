// Generated by CoffeeScript 1.6.3
(function() {
  var PlayerAttackAffect,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  PlayerAttackAffect = (function(_super) {
    __extends(PlayerAttackAffect, _super);

    function PlayerAttackAffect(x, y) {
      PlayerAttackAffect.__super__.constructor.call(this, x, y);
      this.z = 999;
      this.radius = 25;
    }

    PlayerAttackAffect.prototype.draw = function(context) {
      context.fillStyle = "rgba(79, 175, 212, 0.75)";
      context.beginPath();
      context.arc(0, 0, this.radius, 0, Math.PI * 2, true);
      context.closePath();
      return context.fill();
    };

    return PlayerAttackAffect;

  })(Drawable);

  window.BattlefieldPlayer = (function(_super) {
    __extends(BattlefieldPlayer, _super);

    function BattlefieldPlayer(battlefield, x, y, playerData) {
      var name, value, _ref,
        _this = this;
      this.db = battlefield.db;
      BattlefieldPlayer.__super__.constructor.call(this, battlefield, x, y, this.db.sprites.get("player"));
      console.log(this);
      this.playerData = playerData;
      this.statusValue = playerData.statusValue;
      this.name = "player";
      _ref = playerData.statusValue;
      for (name in _ref) {
        value = _ref[name];
        this[name] = value;
      }
      this.hp = 30;
      this.bf = battlefield;
      this.lifeBar = new Widget(this.bf.menu.UI['life-bar']);
      this.lifeBar.UI['life-text'].J.text("" + (parseInt(this.hp)) + "/" + this.statusValue.hp);
      this.speedItem = battlefield.menu.addSpeedItem(this);
      this.speedItem.on("active", function() {
        return _this.act();
      });
    }

    BattlefieldPlayer.prototype.act = function() {
      this.emit("act");
      this.bf.paused = true;
      this.bf.camera.lookAt({
        x: this.x + 100,
        y: this.y - 150
      }, 400, 1.7);
      return this.bf.menu.showActionBtns();
    };

    BattlefieldPlayer.prototype.attack = function(target) {
      var defaultPos, listener,
        _this = this;
      this.bf.paused = true;
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
      var blendLayer, damage, effect,
        _this = this;
      blendLayer = new BlendLayer(this, "rgba(79, 175, 212, 0.81)");
      blendLayer.flash(150, function() {
        return _this.drawQueueRemove(blendLayer);
      });
      damage = this.handleAttackDamage({
        normal: this.playerData.statusValue.atk
      });
      window.AudioManager.play("playerCast");
      effect = new PlayerAttackAffect(this.x + 100, this.y - 100);
      this.bf.mainLayer.drawQueueAdd(effect);
      return effect.animate({
        x: target.x,
        y: target.y
      }, 300, function() {
        effect.animate({
          "radius": 250,
          "transform.opacity": 0.2
        }, 150, function() {
          return _this.bf.mainLayer.drawQueueRemove(effect);
        });
        target.onHurt(_this, damage);
        return _this.bf.paused = false;
      });
    };

    BattlefieldPlayer.prototype.defense = function() {
      var bl,
        _this = this;
      this.isDefensed = true;
      bl = new BlendLayer(this, "rgba(238, 215, 167, 0.4)");
      this.once("act", function() {
        _this.isDefensed = false;
        return _this.drawQueueRemove(bl);
      });
      return this.bf.paused = false;
    };

    BattlefieldPlayer.prototype.castSpell = function(sourceItemWidget, target) {
      var callback,
        _this = this;
      console.log("cast spell to ", target);
      sourceItemWidget.playerSupplies.remainCount -= 1;
      if (sourceItemWidget.playerSupplies.remainCount < 0) {
        this.playerData.removeThing(playerSupplies);
      }
      callback = function() {
        _this.bf.setView("normal");
        return _this.bf.paused = false;
      };
      if (sourceItemWidget.type === "active") {
        switch (sourceItemWidget.effectData.type) {
          case "attack":
            target.onHurt(this, sourceItemWidget.effectData.damage);
            break;
          case "heal":
            target.onHeal(sourceItemWidget.effectData.heal);
            break;
          case "buff":
            target.onBuff(sourceItemWidget.effectData.buff);
        }
      } else {
        target.addFlipOverEffect(sourceItemWidget.effectData);
      }
      return callback();
    };

    BattlefieldPlayer.prototype.addFlipOverEffect = function(effect) {};

    BattlefieldPlayer.prototype.onBuff = function(effect) {};

    BattlefieldPlayer.prototype.onHeal = function(value) {
      this.hp += value;
      if (this.hp > this.statusValue.hp) {
        this.hp = this.statusValue.hp;
      }
      return this.updateLifeBar("heal");
    };

    BattlefieldPlayer.prototype.onHurt = function(from, damage) {
      var type, value;
      if (this.isDefensed) {
        for (type in damage) {
          value = damage[type];
          damage[type] = parseInt(value / 3);
        }
      }
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
      J.css("width", "" + (parseInt(this.hp / this.statusValue.hp * 100)) + "%");
      return this.lifeBar.UI['life-text'].J.text("" + (parseInt(this.hp)) + "/" + this.statusValue.hp);
    };

    BattlefieldPlayer.prototype.draw = function(context, tickDelay) {
      return BattlefieldPlayer.__super__.draw.call(this, context, tickDelay);
    };

    BattlefieldPlayer.prototype.die = function() {
      if (this.dead) {
        return;
      }
      this.dead = true;
      return this.bf.lose();
    };

    return BattlefieldPlayer;

  })(BattlefieldSprite);

}).call(this);
