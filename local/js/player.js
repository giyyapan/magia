// Generated by CoffeeScript 1.6.3
(function() {
  var playerData,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  playerData = {
    name: "Nola",
    lastStage: "home",
    money: 4000,
    energy: 50,
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
      dirak: 0
    },
    storage: [],
    equipments: [],
    currentEquipments: {
      hat: "bigginerHat",
      weapon: "begginerStaff",
      clothes: "bigginerRobe",
      shose: "bigginerShose",
      other: null
    },
    basicStatusValue: {
      hp: 300,
      mp: 300,
      atk: 20,
      normalDef: 30,
      fireDef: 0,
      waterDef: 0,
      earthDef: 0,
      airDef: 0,
      spiritDef: 0,
      minusDef: 0,
      luk: 0,
      spd: 8
    }
  };

  window.Player = (function(_super) {
    __extends(Player, _super);

    function Player(db) {
      Player.__super__.constructor.call(this, null);
      this.db = db;
      this.energy = 50;
      if (!this.loadData()) {
        this.newData();
      }
    }

    Player.prototype.loadData = function() {
      var data, dataKey;
      dataKey = Utils.localData("get", "dataKey");
      data = Utils.localData("get", "playerData");
      console.log("load data", data);
      if (!data || Utils.getKey(JSON.stringify(data)) !== parseInt(dataKey)) {
        return false;
      }
      this.data = data;
      this.initData();
      return true;
    };

    Player.prototype.newData = function() {
      this.data = playerData;
      console.log("new data", this.data);
      this.initData();
      return true;
    };

    Player.prototype.initData = function() {
      var equipmentName, name, part, _i, _j, _len, _len1, _ref, _ref1;
      this.money = this.data.money;
      this.energy = this.data.energy;
      this.relationships = this.data.relationships;
      this.lastStage = this.data.lastStage;
      this.storys = this.data.storys;
      this.missions = this.data.missions;
      this.equipments = [];
      _ref = this.data.equipments;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        name = _ref[_i];
        this.equipments.push(new PlayerEquipment(this.db, name));
      }
      this.currentEquipments = {};
      _ref1 = this.data.currentEquipments;
      for (equipmentName = _j = 0, _len1 = _ref1.length; _j < _len1; equipmentName = ++_j) {
        part = _ref1[equipmentName];
        this.currentEquipments[part] = new PlayerEquipment(equipmentName);
      }
      this.backpack = [];
      this.storage = [];
      this.initThingsFrom("backpack");
      this.initThingsFrom("storage");
      return this.updateStatusValue();
    };

    Player.prototype.updateStatusValue = function() {
      var equip, name, part, value, _i, _len, _ref, _ref1, _results;
      this.basicStatusValue = this.data.basicStatusValue;
      this.statusValue = {};
      _ref = this.basicStatusValue;
      for (name in _ref) {
        value = _ref[name];
        this.statusValue[name] = value;
      }
      _ref1 = this.currentEquipments;
      _results = [];
      for (equip = _i = 0, _len = _ref1.length; _i < _len; equip = ++_i) {
        part = _ref1[equip];
        _results.push((function() {
          var _results1;
          _results1 = [];
          for (name in this.statusValue) {
            if (equip.statusValue[name]) {
              _results1.push(this.statusValue[name] += equip.statusValue[name]);
            } else {
              _results1.push(void 0);
            }
          }
          return _results1;
        }).call(this));
      }
      return _results;
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

    Player.prototype.getItem = function(target, dataObj) {
      var item, name, number, theItem, _i, _len;
      if (target == null) {
        target = "backpack";
      }
      name = dataObj.name;
      number = dataObj.number;
      item = new PlayerItem(this.db, name, {
        number: number
      });
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

    Player.prototype.checkFreeSpace = function(target, things) {
      return true;
    };

    Player.prototype.saveData = function() {
      var backpack, currentEquipments, data, e, equip, equipments, part, storage, thing, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2, _ref3;
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
