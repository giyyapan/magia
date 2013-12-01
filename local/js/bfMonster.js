// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.MonsterLifeBar = (function(_super) {
    __extends(MonsterLifeBar, _super);

    function MonsterLifeBar(monster) {
      var width;
      width = 150;
      MonsterLifeBar.__super__.constructor.call(this, 0, -130, 150, 10);
      this.monster = monster;
      this.value = this.monster.hp;
    }

    MonsterLifeBar.prototype.draw = function(context) {
      var percent;
      percent = this.value / this.monster.maxHp;
      Utils.drawRoundRect(context, -this.width / 2, -this.height / 2, parseInt(percent * this.width), this.height, 4, 0, 0, 4);
      if (percent > 0.75) {
        context.fillStyle = "green";
      } else if (percent > 0.3) {
        context.fillStyle = "orange";
      } else {
        context.fillStyle = "red";
      }
      context.fill();
      Utils.drawRoundRect(context, -this.width / 2, -this.height / 2, this.width, this.height, 4);
      context.strokeStyle = "white";
      context.lineWidth = 2;
      return context.stroke();
    };

    return MonsterLifeBar;

  })(Drawable);

  window.BattlefieldMonster = (function(_super) {
    __extends(BattlefieldMonster, _super);

    function BattlefieldMonster(battlefield, x, y, name) {
      var spriteOriginData,
        _this = this;
      console.log(name);
      this.bf = battlefield;
      this.db = this.bf.db;
      this.originData = this.db.monsters.get(name);
      spriteOriginData = this.db.sprites.get(this.originData.sprite);
      BattlefieldMonster.__super__.constructor.call(this, battlefield, x, y, spriteOriginData);
      if (this.originData.scale) {
        this.transform.scale = this.originData.scale;
      }
      this.name = this.originData.name;
      this.statusValue = this.originData.statusValue;
      this.maxHp = this.statusValue.hp;
      this.hp = this.maxHp;
      this.lifeBar = new MonsterLifeBar(this);
      this.drawQueueAddAfter(this.lifeBar);
      this.speedItem = battlefield.menu.addSpeedItem(this);
      this.speedItem.on("active", function() {
        _this.emit("act");
        return _this.attack(_this.bf.player);
      });
    }

    BattlefieldMonster.prototype.attack = function(target) {
      var defaultPos,
        _this = this;
      this.bf.paused = true;
      defaultPos = {
        x: this.x,
        y: this.y
      };
      this.useMovement("move", true);
      this.animateClock.setRate("fast");
      return this.animate({
        x: target.x + 150,
        y: target.y
      }, 800, function() {
        var listener;
        _this.animateClock.setRate("normal");
        _this.useMovement("attack");
        listener = _this.on("keyFrame", function(index, length) {
          return _this.attackFire(target, index, length);
        });
        return _this.once("endMove:attack", function() {
          _this.off("keyFrame", listener);
          _this.transform.scaleX = -1;
          _this.lifeBar.transform.scaleX = -1;
          _this.animateClock.setRate("fast");
          _this.useMovement("move", true);
          return _this.animate({
            x: defaultPos.x,
            y: defaultPos.y
          }, 800, function() {
            _this.animateClock.setRate("normal");
            _this.transform.scaleX = 1;
            _this.lifeBar.transform.scaleX = 1;
            _this.useMovement(_this.defaultMovement, true);
            return _this.bf.paused = false;
          });
        });
      });
    };

    BattlefieldMonster.prototype.attackFire = function(target, index, length) {
      var damage, name, realDamage, sound, value;
      sound = this.originData.attackSound || "qqHit";
      window.AudioManager.play(sound);
      damage = this.handleAttackDamage(this.originData.damage);
      realDamage = {};
      for (name in damage) {
        value = damage[name];
        realDamage[name] = value / length;
      }
      return target.onHurt(this, realDamage);
    };

    BattlefieldMonster.prototype.onHurt = function(from, damage) {
      BattlefieldMonster.__super__.onHurt.apply(this, arguments);
      if (this.hp <= 0) {
        this.lifeBar.animate({
          value: 0
        }, 100, "swing");
        this.die();
        return;
      }
      return this.lifeBar.animate({
        value: this.hp
      }, 100, "swing");
    };

    BattlefieldMonster.prototype.draw = function(context, tickDelay) {
      return BattlefieldMonster.__super__.draw.call(this, context, tickDelay);
    };

    BattlefieldMonster.prototype.die = function() {
      var _this = this;
      if (this.dead) {
        return;
      }
      this.dead = true;
      this.animateClock.paused = true;
      this.speedItem.remove();
      return this.fadeOut(1000, function() {
        var m, newArr, _i, _len, _ref;
        _this.bf.mainLayer.drawQueueRemove(_this);
        newArr = [];
        _ref = _this.bf.monsters;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          m = _ref[_i];
          if (m !== _this) {
            newArr.push(m);
          }
        }
        _this.bf.monsters = newArr;
        if (_this.bf.monsters.length === 0) {
          return _this.bf.win();
        }
      });
    };

    return BattlefieldMonster;

  })(BattlefieldSprite);

}).call(this);
