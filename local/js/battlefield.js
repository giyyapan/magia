// Generated by CoffeeScript 1.6.3
(function() {
  var BattlefieldMenu, BattlefieldMonster, BattlefieldPlayer, ItemDetailsBox, MonsterLifeBar, SpeedItem, SpellSourceItem,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  SpeedItem = (function(_super) {
    __extends(SpeedItem, _super);

    function SpeedItem(tpl, originData) {
      SpeedItem.__super__.constructor.call(this, tpl);
      this.speedGage = 80;
      this.maxSpeed = 100;
      this.hp = 300;
      this.speed = originData.basicData.spd;
    }

    SpeedItem.prototype.tick = function(tickDelay) {
      this.speedGage += tickDelay / 1000 * this.speed;
      if (this.speedGage > this.maxSpeed) {
        this.setWidgetPosition(this.maxSpeed);
        this.speedGage -= this.maxSpeed;
        return this.emit("active");
      } else {
        return this.setWidgetPosition(this.speedGage);
      }
    };

    SpeedItem.prototype.setWidgetPosition = function(value) {
      return this.J.css("left", parseInt(value / this.maxSpeed * 100) + "%");
    };

    return SpeedItem;

  })(Widget);

  SpellSourceItem = (function(_super) {
    __extends(SpellSourceItem, _super);

    function SpellSourceItem(tpl, type, menu, data) {
      var _this = this;
      SpellSourceItem.__super__.constructor.call(this, tpl);
      this.type = type;
      this.originData = data.originData;
      this.effectData = this.originData[type];
      this.traitValue = data.traitValue;
      this.UI.img.src = this.originData.img;
      this.UI.name.J.text(this.originData.name);
      this.dom.onclick = function(evt) {
        return menu.detailsBox.showItemDetails(_this);
      };
    }

    return SpellSourceItem;

  })(Suzaku.Widget);

  ItemDetailsBox = (function(_super) {
    __extends(ItemDetailsBox, _super);

    function ItemDetailsBox(tpl, bf) {
      var _this = this;
      ItemDetailsBox.__super__.constructor.call(this, tpl);
      this.bf = bf;
      this.currentItem = null;
      this.UI['cancel-btn'].onclick = function() {
        _this.bf.menu.UI['spell-source-box'].J.find("li").removeClass("selected");
        return _this.J.fadeOut(100);
      };
    }

    ItemDetailsBox.prototype.showItemDetails = function(item) {
      var effectData, originData, t,
        _this = this;
      console.log("show item details", item);
      if (this.currentItem) {
        this.currentItem.J.removeClass("selected");
      }
      this.currentItem = item;
      item.J.addClass("selected");
      originData = item.originData;
      effectData = item.effectData;
      switch (item.type) {
        case "active":
          t = "激活效果:";
          break;
        case "defense":
          t = "结界效果:";
      }
      this.UI['rune-type'].J.text(t);
      this.UI.name.J.text(originData.name);
      if (originData.img) {
        this.UI.img.src = originData.img.src;
      }
      this.UI.description.J.text(item.effectData.description);
      this.initTrait();
      this.J.fadeIn("fast");
      return this.UI['use-btn'].onclick = function() {
        return _this.useItem(item);
      };
    };

    ItemDetailsBox.prototype.initTrait = function() {};

    ItemDetailsBox.prototype.useItem = function(sourceItem) {
      var menu,
        _this = this;
      menu = this.bf.menu;
      menu.UI['magic-menus'].J.fadeOut(150);
      if (sourceItem.type === "active") {
        switch (sourceItem.effectData.type) {
          case "attack" || "debuff":
            menu.hideActionBtns();
            return menu.showTargetSelect("magic", {
              cancel: function() {
                menu.showActionBtns();
                return menu.UI['magic-menus'].J.fadeIn(150);
              },
              success: function(target) {
                return _this.bf.player.castSpell(sourceItem, target);
              }
            });
          case "areaAttack":
            return this.bf.player.castSpell(sourceItem, this.bf.monsters);
          case "buff":
          case "heal":
            return this.bf.player.castSpell(sourceItem, this.bf.player);
          default:
            return console.error("invailid item active type" + sourceItem.effectData.type);
        }
      } else {
        return this.bf.player.castSpell(sourceItem, this.bf.player);
      }
    };

    return ItemDetailsBox;

  })(Widget);

  BattlefieldPlayer = (function(_super) {
    __extends(BattlefieldPlayer, _super);

    function BattlefieldPlayer(battlefield, x, y, playerData, originData) {
      var name, value, _ref,
        _this = this;
      BattlefieldPlayer.__super__.constructor.call(this, x, y, originData);
      this.playerData = playerData;
      this.basicData = originData.basicData;
      _ref = originData.basicData;
      for (name in _ref) {
        value = _ref[name];
        this[name] = value;
      }
      this.bf = battlefield;
      this.transform.scaleX = -1;
      this.lifeBar = new Widget(this.bf.menu.UI['life-bar']);
      this.lifeBar.UI['life-text'].J.text("" + (parseInt(this.hp)) + "/" + this.basicData.hp);
      this.speedItem = battlefield.menu.addSpeedItem(originData);
      this.speedItem.on("active", function() {
        return _this.act();
      });
    }

    BattlefieldPlayer.prototype.act = function() {
      this.bf.paused = true;
      this.bf.camera.lookAt(this, 400);
      return this.bf.menu.showActionBtns();
    };

    BattlefieldPlayer.prototype.tick = function(tickDelay) {
      if (!this.bf.paused) {
        return this.speedItem.tick(tickDelay);
      }
    };

    BattlefieldPlayer.prototype.attack = function(target) {
      var damage, defaultPos,
        _this = this;
      this.bf.paused = true;
      damage = this.originData.skills.attack.damage;
      this.bf.setView("default");
      defaultPos = {
        x: this.x,
        y: this.y
      };
      this.useMovement("move", true);
      this.animateClock.setRate("fast");
      return this.animate({
        x: target.x - 150,
        y: target.y
      }, 800, function() {
        var listener;
        _this.bf.camera.lookAt(target, 300, 2);
        _this.animateClock.setRate("normal");
        _this.useMovement("attack");
        listener = _this.on("keyFrame", function(index, length) {
          var name, realDamage, value;
          realDamage = {};
          for (name in damage) {
            value = damage[name];
            realDamage[name] = value / length;
          }
          realDamage.normal = 600;
          return target.onAttack(_this, realDamage);
        });
        return _this.once("endMove:attack", function() {
          _this.bf.setView("normal");
          _this.bf.camera.unfollow();
          _this.off("keyFrame", listener);
          _this.transform.scaleX = 1;
          _this.animateClock.setRate("fast");
          _this.useMovement("move", true);
          return _this.animate({
            x: defaultPos.x,
            y: defaultPos.y
          }, 800, function() {
            _this.animateClock.setRate("normal");
            _this.transform.scaleX = -1;
            _this.useMovement(_this.defaultMovement, true);
            return _this.bf.paused = false;
          });
        });
      });
    };

    BattlefieldPlayer.prototype.defense = function() {};

    BattlefieldPlayer.prototype.castSpell = function(sourceItem, target) {
      var callback,
        _this = this;
      console.log("cast spell to ", target);
      callback = function() {
        _this.bf.setView("normal");
        return _this.bf.paused = false;
      };
      if (sourceItem.type === "active") {
        switch (sourceItem.effectData.type) {
          case "attack":
            target.onAttack(this, sourceItem.effectData.damage);
            break;
          case "heal":
            target.onHeal(sourceItem.effectData.heal);
            break;
          case "buff":
            target.onBuff(sourceItem.effectData.buff);
        }
      } else {
        target.addFlipOverEffect(sourceItem.effectData);
      }
      return callback();
    };

    BattlefieldPlayer.prototype.addFlipOverEffect = function(effect) {};

    BattlefieldPlayer.prototype.onBuff = function(effect) {};

    BattlefieldPlayer.prototype.onHeal = function(value) {
      this.hp += value;
      if (this.hp > this.basicData.hp) {
        this.hp = this.basicData.hp;
      }
      return this.updateLifeBar("heal");
    };

    BattlefieldPlayer.prototype.onAttack = function(from, damage) {
      var type, value;
      this.bf.camera.shake("fast");
      for (type in damage) {
        value = damage[type];
        this.hp -= value;
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
      J.css("width", "" + (parseInt(this.hp / this.basicData.hp * 100)) + "%");
      return this.lifeBar.UI['life-text'].J.text("" + (parseInt(this.hp)) + "/" + this.basicData.hp);
    };

    BattlefieldPlayer.prototype.draw = function(context, tickDelay) {
      BattlefieldPlayer.__super__.draw.call(this, context, tickDelay);
      return context.fillRect(-10, -10, 20, 20);
    };

    BattlefieldPlayer.prototype.die = function() {
      if (this.dead) {
        return;
      }
      this.dead = true;
      return this.bf.lose();
    };

    return BattlefieldPlayer;

  })(Sprite);

  MonsterLifeBar = (function(_super) {
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

  BattlefieldMonster = (function(_super) {
    __extends(BattlefieldMonster, _super);

    function BattlefieldMonster(battlefield, x, y, originData) {
      var name, value, _ref,
        _this = this;
      BattlefieldMonster.__super__.constructor.call(this, x, y, originData);
      this.bf = battlefield;
      this.basicData = originData.basicData;
      this.originData = originData;
      _ref = originData.basicData;
      for (name in _ref) {
        value = _ref[name];
        this[name] = value;
      }
      this.maxHp = this.basicData.hp;
      this.lifeBar = new MonsterLifeBar(this);
      this.drawQueueAddAfter(this.lifeBar);
      this.speedItem = battlefield.menu.addSpeedItem(originData);
      this.speedItem.on("active", function() {
        return _this.attack(_this.bf.player);
      });
    }

    BattlefieldMonster.prototype.tick = function(tickDelay) {
      if (!this.bf.paused && !this.dead) {
        return this.speedItem.tick(tickDelay);
      }
    };

    BattlefieldMonster.prototype.attack = function(target) {
      var damage, defaultPos,
        _this = this;
      this.bf.paused = true;
      damage = this.originData.skills.attack.damage;
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
          var name, realDamage, value;
          realDamage = {};
          for (name in damage) {
            value = damage[name];
            realDamage[name] = value / length;
          }
          return target.onAttack(_this, realDamage);
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

    BattlefieldMonster.prototype.onAttack = function(from, damage) {
      var name, value;
      this.bf.camera.shake("fast");
      for (name in damage) {
        value = damage[name];
        this.hp -= value;
      }
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
      BattlefieldMonster.__super__.draw.call(this, context, tickDelay);
      return context.fillRect(-10, -10, 20, 20);
    };

    BattlefieldMonster.prototype.die = function() {
      var _this = this;
      if (this.dead) {
        return;
      }
      this.dead = true;
      this.animateClock.paused = true;
      console.log(this.speedItem);
      this.speedItem.remove();
      return this.fadeOut(1000, function() {
        var m, newArr, _i, _len, _ref;
        _this.bf.mainLayer.drawQueueRemove(_this);
        _this.draw = function() {
          return console.log("tick");
        };
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

  })(Sprite);

  BattlefieldMenu = (function(_super) {
    __extends(BattlefieldMenu, _super);

    function BattlefieldMenu(battlefield, tpl) {
      BattlefieldMenu.__super__.constructor.call(this, tpl);
      this.bf = battlefield;
      this.detailsBox = new ItemDetailsBox(this.UI['item-details-box'], this.bf);
      this.initBtns();
    }

    BattlefieldMenu.prototype.initBtns = function() {
      var stopPropagation,
        _this = this;
      this.UI['attack-btn'].onclick = function(evt) {
        return _this.handlePlayerAttack();
      };
      this.UI['defense-btn'].onclick = function(evt) {
        return _this.handlePlayerDefense();
      };
      this.UI['magic-btn'].onclick = function(evt) {
        return _this.handlePlayerMagic();
      };
      this.UI['escape-btn'].onclick = function(evt) {
        return _this.handlePlayerEscape();
      };
      this.UI['active-rune'].onclick = function(evt) {
        _this.UI['active-rune'].J.addClass("selected");
        return _this.showSpellSourceLayer("active");
      };
      this.UI['defense-rune'].onclick = function(evt) {
        _this.UI['defense-rune'].J.addClass("selected");
        return _this.showSpellSourceLayer("defense");
      };
      stopPropagation = function(evt) {
        return evt.stopPropagation();
      };
      this.UI['spell-select-box'].onclick = stopPropagation;
      this.UI['spell-source-box'].onclick = stopPropagation;
      return this.UI['item-details-box'].onclick = stopPropagation;
    };

    BattlefieldMenu.prototype.addSpeedItem = function(originData) {
      var item, tpl;
      tpl = this.UI['speed-item-tpl'].innerHTML;
      item = new SpeedItem(tpl, originData);
      item.appendTo(this.UI['speed-item-list']);
      return item;
    };

    BattlefieldMenu.prototype.showActionBtns = function(callback) {
      this.UI['action-btns'].J.addClass("show");
      this.UI['status-box'].J.addClass("show");
      if (callback) {
        return callback();
      }
    };

    BattlefieldMenu.prototype.hideActionBtns = function(callback) {
      this.UI['action-btns'].J.removeClass("show");
      this.UI['status-box'].J.removeClass("show");
      if (callback) {
        return callback();
      }
    };

    BattlefieldMenu.prototype.handlePlayerAttack = function() {
      var _this = this;
      console.log("attack clicked");
      this.hideActionBtns();
      this.bf.setView("default");
      return this.showTargetSelect("attack", {
        success: function(target) {
          return _this.bf.player.attack(target);
        },
        cancel: function(target) {
          return _this.bf.player.act();
        }
      });
    };

    BattlefieldMenu.prototype.showTargetSelect = function(type, callbacks) {
      var item, self, target, tpl, _i, _len, _ref, _results,
        _this = this;
      this.bf.setView("default");
      this.UI['target-select-box'].J.html('');
      this.UI['target-select-layer'].J.fadeIn(150);
      this.UI['target-select-layer'].onclick = function() {
        _this.UI['target-select-layer'].J.fadeOut(150);
        if (callbacks.cancel) {
          return callbacks.cancel();
        }
      };
      switch (type) {
        case "attack":
          tpl = this.UI['attack-target-btn-tpl'].innerHTML;
          break;
        case "magic":
          tpl = this.UI['magic-target-btn-tpl'].innerHTML;
      }
      self = this;
      _ref = this.bf.monsters;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        target = _ref[_i];
        item = new Widget(tpl);
        item.dom.target = target;
        item.J.css({
          top: "" + (target.y - 100) + "px",
          left: "" + (target.x - 200) + "px"
        });
        item.dom.onclick = function(evt) {
          evt.stopPropagation();
          self.UI['target-select-layer'].J.fadeOut(150);
          return callbacks.success(this.target);
        };
        _results.push(item.appendTo(this.UI['target-select-box']));
      }
      return _results;
    };

    BattlefieldMenu.prototype.handlePlayerDefense = function() {
      return console.log("defense clicked");
    };

    BattlefieldMenu.prototype.handlePlayerMagic = function() {
      var _this = this;
      this.UI['spell-source-layer'].J.hide();
      this.detailsBox.J.hide();
      this.UI['spell-select-layer'].J.hide();
      this.UI['spell-select-layer'].J.find("li").removeClass("selected");
      this.UI['magic-menus'].J.show();
      this.UI['spell-select-layer'].J.fadeIn(150);
      return this.UI['spell-select-layer'].dom.onclick = function() {
        return _this.UI['spell-select-layer'].J.fadeOut(150);
      };
    };

    BattlefieldMenu.prototype.handlePlayerEscape = function() {
      console.log("escape");
      return this.bf.lose();
    };

    BattlefieldMenu.prototype.showSpellSourceLayer = function(type) {
      var i, item, self, tpl, _i, _len, _ref,
        _this = this;
      switch (type) {
        case "active":
          this.UI["spell-source-type"].innerHTML = "激活符文";
          break;
        case "defense":
          this.UI["spell-source-type"].innerHTML = "结界符文";
          break;
        default:
          return console.error("invailid type:" + type);
      }
      self = this;
      tpl = this.UI['item-tpl'].innerHTML;
      console.log(tpl);
      this.UI['spell-source-list'].J.html("");
      _ref = this.bf.player.playerData.backpack;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        i = _ref[_i];
        if (!i.originData[type]) {
          continue;
        }
        item = new SpellSourceItem(tpl, type, this, i);
        item.appendTo(this.UI['spell-source-list']);
      }
      this.UI['spell-source-layer'].J.fadeIn(150);
      return this.UI['spell-source-layer'].dom.onclick = function() {
        _this.UI['spell-select-box'].J.find("li").removeClass("selected");
        return _this.UI['spell-source-layer'].J.fadeOut(150);
      };
    };

    return BattlefieldMenu;

  })(Menu);

  window.Battlefield = (function(_super) {
    __extends(Battlefield, _super);

    function Battlefield(game, data) {
      Battlefield.__super__.constructor.call(this, game);
      this.game = game;
      this.data = data;
      this.db = game.db;
      this.camera = new Camera();
      this.drawQueueAddAfter(this.camera);
      this.paused = false;
      this.initLayers();
      this.initSprites();
      this.setView("default");
    }

    Battlefield.prototype.initSprites = function() {
      var baseY, dx, dy, index, mdata, monster, name, s, startX, startY, x, y, _i, _len, _ref, _results;
      s = Utils.getSize();
      baseY = parseInt(s.height / 2 + 30);
      this.player = new BattlefieldPlayer(this, 300, baseY, this.game.player, this.db.monsters.get("qq"));
      this.mainLayer.drawQueueAddAfter(this.player);
      this.monsters = [];
      startX = 1000;
      dx = 50;
      dy = 100;
      startY = parseInt(baseY - (this.data.monsters.length - 1) * (dy * 0.5));
      _ref = this.data.monsters;
      _results = [];
      for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
        name = _ref[index];
        x = startX + index * dx;
        y = startY + index * dy;
        mdata = this.db.monsters.get(name);
        monster = new BattlefieldMonster(this, x, y, mdata);
        this.monsters.push(monster);
        _results.push(this.mainLayer.drawQueueAddAfter(monster));
      }
      return _results;
    };

    Battlefield.prototype.initLayers = function() {
      var bg, detail, img, imgName, name, value, _ref;
      this.bgs = [];
      this.mainLayer = null;
      _ref = this.data.bg;
      for (imgName in _ref) {
        detail = _ref[imgName];
        img = Res.imgs[imgName];
        bg = new Layer().setImg(img);
        for (name in detail) {
          value = detail[name];
          switch (name) {
            case "main":
              this.mainLayer = bg;
              break;
            case "fixToBottom":
              bg.fixToBottom();
              break;
            case "anchor":
              bg.setAnchor(value);
              break;
            default:
              bg[name] = value;
          }
        }
        this.camera.render(bg);
      }
      if (!this.mainLayer) {
        this.mainLayer = this.bgs[0];
      }
      this.camera.defaultReferenceZ = this.mainLayer.z;
      this.menu = new BattlefieldMenu(this, Res.tpls['battlefield-menu']);
      return this.drawQueueAddAfter(this.menu);
    };

    Battlefield.prototype.win = function() {
      this.emit("win");
      return console.log("win!!!");
    };

    Battlefield.prototype.lose = function() {
      this.emit("lose");
      return console.log("lose!!!");
    };

    Battlefield.prototype.show = function() {
      var _this = this;
      return Battlefield.__super__.show.call(this, function() {
        return _this.menu.show();
      });
    };

    Battlefield.prototype.tick = function(tickDelay) {
      var monster, _i, _len, _ref, _results;
      this.player.tick(tickDelay);
      _ref = this.monsters;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        monster = _ref[_i];
        _results.push(monster.tick(tickDelay));
      }
      return _results;
    };

    Battlefield.prototype.setView = function(name, callback) {
      switch (name) {
        case "default":
        case "normal":
          return this.camera.animate({
            x: 0,
            y: 0,
            scale: 1
          }, 200, callback);
      }
    };

    return Battlefield;

  })(Stage);

}).call(this);
