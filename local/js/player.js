// Generated by CoffeeScript 1.6.3
(function() {
  var playerData;

  playerData = {
    name: "Nola",
    lastStage: "home",
    level: 1,
    assert: {
      money: 4000,
      gem: 300,
      backpack: [
        {
          name: "healPotion",
          traitValue: 300,
          type: "supplies"
        }, {
          name: "firePotion",
          traitValue: 300,
          type: "supplies"
        }, {
          name: "scree",
          number: 10,
          type: "item"
        }, {
          name: "lakeWater",
          number: 10,
          type: "item"
        }, {
          name: "herbs",
          number: 10,
          type: "item"
        }, {
          name: "caveMashroom",
          number: 10,
          type: "item"
        }
      ],
      storage: [],
      currentEquipment: {
        hat: null,
        clothes: null,
        belt: null,
        shose: null
      }
    },
    ability: {
      hp: 300,
      mp: 300,
      atk: 20,
      def: 30,
      spd: 8,
      luk: 10
    }
  };

  window.Player = (function() {
    function Player(data, db) {
      var name;
      this.db = db;
      this.data = data;
      if (!data) {
        this.data = playerData;
      }
      this.energy = 40;
      this.backpack = [];
      this.storage = [];
      this.initData();
      for (name in this.data) {
        this[name] = this.data[name];
      }
    }

    Player.prototype.initData = function() {
      this.initThingsFrom("backpack", this.data.assert.backpack);
      return this.initThingsFrom("storage", this.data.assert.storage);
    };

    Player.prototype.initThingsFrom = function(originType, data) {
      var origin, target, _i, _len;
      switch (originType) {
        case "backpack":
          origin = this.data.assert.backpack;
          target = this.backpack;
          break;
        case "storage":
          origin = this.data.assert.storage;
          target = this.storage;
      }
      for (_i = 0, _len = origin.length; _i < _len; _i++) {
        data = origin[_i];
        switch (data.type) {
          case "item":
            this.getItem(target, data);
            break;
          case "supplies":
            this.getSupplies(target, data);
        }
      }
      return console.log(this.backpack);
    };

    Player.prototype.removeThing = function(playerItem, from) {
      var arr, found, i, length, _i, _j, _len, _len1, _ref, _ref1;
      if (!from) {
        if (this.removeThing(playerItem, "backpack")) {
          return;
        }
        return this.removeThing(playerItem, "storage");
      }
      found = false;
      arr = [];
      switch (from) {
        case "backpack":
          length = this.backpack.length;
          _ref = this.backpack;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            i = _ref[_i];
            if (playerItem !== i) {
              arr.push(i);
            }
          }
          this.backpack = arr;
          return arr.length !== length;
        case "storage":
          length = this.storage.length;
          _ref1 = this.storage;
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            i = _ref1[_j];
            if (playerItem !== i) {
              arr.push(i);
            }
          }
          this.storage = arr;
          return arr.length !== length;
      }
    };

    Player.prototype.getItem = function(target, dataObj) {
      var item, name, number, originData, theItem, _i, _len;
      if (target == null) {
        target = "backpack";
      }
      name = dataObj.name;
      originData = dataObj.originData || this.db.things.items.get(name);
      number = dataObj.number;
      item = new PlayerItem(name, originData, number);
      switch (target) {
        case "backpack":
          target = this.backpack;
          break;
        case "storage":
          target = this.storage;
      }
      for (_i = 0, _len = target.length; _i < _len; _i++) {
        theItem = target[_i];
        if (theItem.type === "item" && theItem.name === item.name) {
          return theItem.number += 1;
        }
      }
      target.push(item);
      this.saveData();
      return console.log(this);
    };

    Player.prototype.getSupplies = function(target, data) {
      var name, originData, supplies, traitValue;
      if (target == null) {
        target = "backpack";
      }
      if (data instanceof PlayerSupplies) {
        supplies = data;
      } else {
        name = data.name;
        traitValue = data.traitValue;
        originData = this.db.things.supplies.get(data.name);
        supplies = new PlayerSupplies(name, originData, traitValue);
      }
      switch (target) {
        case "backpack":
          target = this.backpack;
          break;
        case "storage":
          target = this.storage;
      }
      target.push(supplies);
      this.saveData();
      return console.log(this);
    };

    Player.prototype.getEquipment = function() {};

    Player.prototype.checkFreeSpace = function(target, things) {
      return true;
    };

    Player.prototype.saveData = function() {};

    return Player;

  })();

}).call(this);
