// Generated by CoffeeScript 1.6.2
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.Things = (function(_super) {
    __extends(Things, _super);

    function Things(name, data, type) {
      Things.__super__.constructor.call(this);
      this.originData = data;
      this.name = name;
      this.dspName = data.name;
      this.type = type;
      if (data.img) {
        this.img = Res.imgs[data.img];
      } else {
        this.img = null;
      }
    }

    Things.prototype.getDate = function() {
      return {
        name: this.name,
        type: this.type
      };
    };

    return Things;

  })(EventEmitter);

  window.PlayerItem = (function(_super) {
    __extends(PlayerItem, _super);

    function PlayerItem(db, name, number) {
      var arr, originData, t, _i, _len, _ref;

      originData = db.things.items.get(name);
      PlayerItem.__super__.constructor.call(this, name, originData, "item");
      this.number = number;
      this.traits = {};
      _ref = originData.traits;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        t = _ref[_i];
        arr = t.split(":");
        this.traits[arr[0]] = parseInt(arr[1]);
      }
    }

    PlayerItem.prototype.getData = function() {
      return {
        name: this.name,
        type: this.type,
        number: this.number
      };
    };

    return PlayerItem;

  })(Things);

  window.PlayerSupplies = (function(_super) {
    __extends(PlayerSupplies, _super);

    function PlayerSupplies(db, name, traitValue, remainCount) {
      var originData;

      console.log(db.things);
      originData = db.things.supplies.get(name);
      PlayerSupplies.__super__.constructor.call(this, name, originData, "supplies");
      this.remainCount = remainCount || 5;
      this.traitValue = traitValue;
      this.traitName = originData.traitName;
      this.traits = {};
      this.traits[originData.traitName] = this.traitValue;
    }

    PlayerSupplies.prototype.getData = function() {
      return {
        name: this.name,
        type: this.type,
        remainCount: this.remainCount,
        traitValue: this.traitValue
      };
    };

    return PlayerSupplies;

  })(Things);

  window.PlayerEquipment = (function(_super) {
    __extends(PlayerEquipment, _super);

    function PlayerEquipment(db, name) {
      var originData;

      originData = db.things.equipments.get(name);
      PlayerEquipment.__super__.constructor.call(this, name, originData, "equipment");
      this.statusValue = originData.statusValue;
    }

    PlayerEquipment.prototype.getData = function() {
      return PlayerEquipment.__super__.getData.apply(this, arguments);
    };

    return PlayerEquipment;

  })(Things);

  window.GatherItem = (function(_super) {
    __extends(GatherItem, _super);

    function GatherItem(name, data) {
      GatherItem.__super__.constructor.call(this, name, data, "item");
    }

    GatherItem.prototype.getGatherData = function() {
      return true;
    };

    GatherItem.prototype.tryGather = function(data) {
      return 1;
    };

    return GatherItem;

  })(Things);

}).call(this);
