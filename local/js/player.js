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
      backpack: [],
      storageItem: [],
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
      this.initData;
      this.backpack = [];
      this.storage = [];
      for (name in this.data) {
        this[name] = this.data[name];
      }
    }

    Player.prototype.initData = function() {
      this.initThingsFrom("backpack", this.data.assert.backpack);
      return this.initThingsFrom("storage", this.data.assert.storage);
    };

    Player.prototype.initThingsFrom = function(originType, data) {
      var origin, target, _i, _len, _results;
      switch (originType) {
        case "backpack":
          origin = this.data.assert.backpack;
          target = this.backpack;
          break;
        case "storage":
          origin = this.data.assert.storage;
          target = this.storage;
      }
      _results = [];
      for (_i = 0, _len = origin.length; _i < _len; _i++) {
        data = origin[_i];
        switch (data.type) {
          case "item":
            _results.push(this.getItem(target, data));
            break;
          case "supplies":
            _results.push(this.getSupplies(target, data));
            break;
          case "material":
            _results.push(this.getMaterial(target, data));
            break;
          default:
            _results.push(void 0);
        }
      }
      return _results;
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
      return console.log(this);
    };

    Player.prototype.getSupplies = function(target, dataObj) {
      if (target == null) {
        target = "backpack";
      }
    };

    Player.prototype.getMaterial = function(target, dataObj) {
      if (target == null) {
        target = "backpack";
      }
    };

    Player.prototype.getEquipment = function() {};

    Player.prototype.checkFreeSpace = function(target, things) {
      return true;
    };

    Player.prototype.saveData = function() {};

    return Player;

  })();

}).call(this);
