// Generated by CoffeeScript 1.6.3
(function() {
  var playerData, testPlayerData,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  testPlayerData = {
    name: "艾丽西亚",
    lastStage: "home",
    money: 4000,
    energy: 50,
    backpack: [
      {
        name: "healPotion",
        traitValue: 100,
        type: "supplies"
      }, {
        name: "firePotion",
        traitValue: 130,
        type: "supplies"
      }, {
        name: "fogPotion",
        traitValue: 30,
        type: "supplies"
      }, {
        name: "corrosionPotion",
        traitValue: 100,
        type: "supplies"
      }, {
        name: "burnPotion",
        traitValue: 30,
        type: "supplies"
      }, {
        name: "ironPotion",
        traitValue: 30,
        type: "supplies"
      }, {
        name: "explodePotion",
        traitValue: 50,
        type: "supplies"
      }, {
        name: "muddyPotion",
        traitValue: 50,
        type: "supplies"
      }, {
        name: "bravePotion",
        traitValue: 50,
        type: "supplies"
      }, {
        name: "stunPotion",
        traitValue: 50,
        type: "supplies"
      }, {
        name: "icePotion",
        traitValue: 50,
        type: "supplies"
      }, {
        name: "earthPotion",
        traitValue: 50,
        type: "supplies"
      }, {
        name: "snowPotion",
        traitValue: 50,
        type: "supplies"
      }, {
        name: "earthLow",
        number: 10,
        type: "item"
      }, {
        name: "earthMid",
        number: 10,
        type: "item"
      }, {
        name: "lifeLow",
        number: 10,
        type: "item"
      }, {
        name: "iceLow",
        number: 10,
        type: "item"
      }, {
        name: "waterLow",
        number: 10,
        type: "item"
      }, {
        name: "fireLow",
        number: 10,
        type: "item"
      }, {
        name: "fireMid",
        number: 10,
        type: "item"
      }, {
        name: "minusLow",
        number: 10,
        type: "item"
      }, {
        name: "spiritLow",
        number: 10,
        type: "item"
      }, {
        name: "iceMid",
        number: 10,
        type: "item"
      }, {
        name: "iceHigh",
        number: 10,
        type: "item"
      }, {
        name: "timeLow",
        number: 10,
        type: "item"
      }, {
        name: "spaceLow",
        number: 10,
        type: "item"
      }
    ],
    unlockedAreas: {
      all: true
    },
    missions: {
      current: {},
      completed: {},
      finished: {
        theGuild: true
      }
    },
    storys: {
      current: null,
      completed: {}
    },
    relationships: {
      luna: 0,
      dirak: 0,
      nataria: 0
    },
    storage: [],
    equipments: [],
    currentEquipments: {
      hat: "hat1",
      weapon: "weapon1",
      robe: "robe1",
      shose: "shose1",
      other: null
    },
    basicStatusValue: {
      hp: 300,
      mp: 300,
      atk: 10,
      def: 0,
      fireDef: 0,
      iceDef: 0,
      inpactDef: 0,
      spiritDef: 0,
      minusDef: 0,
      accuracy: 95,
      resistance: 10,
      spd: 30
    }
  };

  playerData = {
    name: "艾丽西亚",
    lastStage: "home",
    money: 0,
    energy: 30,
    backpack: [],
    missions: {
      current: {},
      completed: {},
      finished: {}
    },
    storys: {
      current: null,
      completed: {}
    },
    relationships: {
      luna: 0,
      dirak: 0,
      nataria: 0
    },
    unlockedAreas: {},
    storage: [],
    equipments: [],
    currentEquipments: {
      hat: "hat1",
      weapon: "weapon1",
      robe: "robe1",
      shose: "shose1",
      other: null
    },
    basicStatusValue: {
      hp: 300,
      mp: 300,
      atk: 10,
      def: 0,
      fireDef: 0,
      iceDef: 0,
      inpactDef: 0,
      spiritDef: 0,
      minusDef: 0,
      accuracy: 80,
      miss: 5,
      spd: 30
    }
  };

  window.Player = (function(_super) {
    __extends(Player, _super);

    function Player(db) {
      var _this = this;
      Player.__super__.constructor.call(this, null);
      this.saveLock = true;
      this.db = db;
      if (!this.loadData()) {
        this.newData();
      }
      this.maxEnergy = 30;
      this.energy = this.maxEnergy;
      this.saveLock = false;
      window.fuckmylife = function() {
        return _this.newData(testPlayerData);
      };
      window.whothehellareyou = function() {
        return console.log(_this);
      };
    }

    Player.prototype.loadData = function() {
      var data, dataKey, err;
      dataKey = Utils.localData("get", "dataKey");
      data = Utils.localData("get", "playerData");
      console.log("load data", data);
      if (!data || Utils.getKey(JSON.stringify(data)) !== parseInt(dataKey)) {
        return false;
      }
      this.data = data;
      try {
        this.initData();
      } catch (_error) {
        err = _error;
        this.newData();
      }
      return true;
    };

    Player.prototype.newData = function(data) {
      this.data = data || playerData;
      console.log("new data", this.data);
      this.initData();
      return true;
    };

    Player.prototype.handleOldVersionData = function() {
      if (this.data.currentEquipments.hat === "bigginerHat") {
        this.data.currentEquipments = playerData.currentEquipments;
      }
      return this.data.basicStatusValue = playerData.basicStatusValue;
    };

    Player.prototype.initData = function() {
      var equipmentName, name, part, _i, _len, _ref, _ref1;
      this.handleOldVersionData();
      this.money = this.data.money;
      this.energy = this.data.energy;
      this.relationships = this.data.relationships;
      this.unlockedAreas = this.data.unlockedAreas;
      this.lastStage = this.data.lastStage;
      this.storys = this.data.storys;
      this.missions = this.data.missions;
      this.equipments = {};
      _ref = this.data.equipments;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        name = _ref[_i];
        this.equipments.push = new PlayerEquipment(this.db, name);
      }
      this.currentEquipments = {};
      _ref1 = this.data.currentEquipments;
      for (part in _ref1) {
        equipmentName = _ref1[part];
        if (!equipmentName) {
          continue;
        }
        this.currentEquipments[part] = new PlayerEquipment(this.db, equipmentName);
      }
      this.backpack = [];
      this.storage = [];
      this.initThingsFrom("backpack");
      this.initThingsFrom("storage");
      this.updateStatusValue();
      return this.hp = this.statusValue.hp;
    };

    Player.prototype.updateStatusValue = function() {
      var equip, name, part, value, _ref, _ref1;
      this.basicStatusValue = this.data.basicStatusValue;
      this.statusValue = {};
      _ref = this.basicStatusValue;
      for (name in _ref) {
        value = _ref[name];
        this.statusValue[name] = value;
      }
      _ref1 = this.currentEquipments;
      for (part in _ref1) {
        equip = _ref1[part];
        for (name in this.statusValue) {
          if (equip.statusValue[name]) {
            this.statusValue[name] += equip.statusValue[name];
          }
        }
      }
      return console.log("update status value", this.statusValue);
    };

    Player.prototype.initThingsFrom = function(originType) {
      var itemData, origin, target, _i, _len, _results;
      switch (originType) {
        case "backpack":
          origin = this.data.backpack;
          target = this.backpack;
          break;
        case "storage":
          origin = this.data.storage;
          target = this.storage;
      }
      _results = [];
      for (_i = 0, _len = origin.length; _i < _len; _i++) {
        itemData = origin[_i];
        switch (itemData.type) {
          case "item":
            _results.push(this.getItem(target, itemData));
            break;
          case "supplies":
            _results.push(this.getSupplies(target, itemData));
            break;
          default:
            _results.push(void 0);
        }
      }
      return _results;
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

    Player.prototype.hasThing = function(name) {
      var number, thing, _i, _j, _len, _len1, _ref, _ref1;
      number = 0;
      _ref = this.backpack;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        thing = _ref[_i];
        if (thing.name === name) {
          number += thing.number || 1;
        }
      }
      _ref1 = this.storage;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        thing = _ref1[_j];
        if (thing.name === name) {
          number += thing.number || 1;
        }
      }
      return number;
    };

    Player.prototype.getItem = function(target, dataObj) {
      var item, name, number, theItem, _i, _len;
      if (target == null) {
        target = "backpack";
      }
      if (dataObj instanceof PlayerItem) {
        item = dataObj;
      } else {
        name = dataObj.name;
        number = dataObj.number;
        item = new PlayerItem(this.db, name, {
          number: number
        });
      }
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
      this.emit("getThing", "item", item);
      return this.saveData();
    };

    Player.prototype.getSupplies = function(target, data) {
      var name, supplies;
      if (target == null) {
        target = "backpack";
      }
      if (data instanceof PlayerSupplies) {
        supplies = data;
      } else {
        name = data.name;
        supplies = new PlayerSupplies(this.db, name, data);
      }
      switch (target) {
        case "backpack":
          target = this.backpack;
          break;
        case "storage":
          target = this.storage;
      }
      target.push(supplies);
      this.emit("getThing", "supplies", supplies);
      return this.saveData();
    };

    Player.prototype.getEquipment = function() {
      return this.emit("getThing", "equipment", supplies);
    };

    Player.prototype.saveData = function() {
      var backpack, currentEquipments, data, e, equip, equipments, part, storage, thing, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2, _ref3;
      if (this.saveLock) {
        return;
      }
      backpack = [];
      _ref = this.backpack;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        thing = _ref[_i];
        backpack.push(thing.getData());
      }
      storage = [];
      _ref1 = this.storage;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        thing = _ref1[_j];
        storage.push(thing.getData());
      }
      equipments = [];
      _ref2 = this.equipments;
      for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
        e = _ref2[_k];
        equipments.push(e.getData());
      }
      currentEquipments = {};
      _ref3 = this.currentEquipments;
      for (part in _ref3) {
        equip = _ref3[part];
        currentEquipments[part] = equip.getData();
      }
      data = {
        lastStage: "home",
        money: this.money,
        energy: this.energy,
        statusValue: this.basicData,
        lastStage: this.lastStage,
        storys: this.storys,
        missions: this.missions,
        unlockedAreas: this.unlockedAreas,
        basicStatusValue: this.basicStatusValue,
        relationships: this.relationships,
        backpack: backpack,
        storage: storage,
        equipments: equipments,
        currentEquipments: currentEquipments
      };
      Utils.localData("save", "playerData", data);
      Utils.localData("save", "dataKey", Utils.getKey(JSON.stringify(data)));
      return true;
    };

    return Player;

  })(EventEmitter);

}).call(this);
