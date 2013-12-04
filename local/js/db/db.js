// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.SubDB = (function(_super) {
    __extends(SubDB, _super);

    function SubDB(name) {
      this.dbName = name;
      this.data = {};
    }

    SubDB.prototype.getAll = function() {
      return this.data;
    };

    SubDB.prototype.get = function(name) {
      if (typeof this.data[name] === "undefined") {
        return console.warn("Cannot find data name : " + name + " in database " + this.dbName);
      } else {
        return this.data[name];
      }
    };

    return SubDB;

  })(Suzaku.EventEmitter);

  window.Database = (function(_super) {
    __extends(Database, _super);

    function Database() {
      var name;
      this.areas = new AreasDB();
      this.things = new ThingsDB();
      this.shops = new ShopsDB();
      this.missions = new MissionsDB();
      this.sprites = new SpritesDB();
      this.monsters = new MonstersDB();
      this.rules = new SubDB("rules");
      this.characters = new SubDB("characters");
      for (name in ["AreasDB", "ThingsDB", "MissionsDB", "ShopsDB"]) {
        delete window[name];
      }
      this.initCharacters();
      this.initRules();
    }

    Database.prototype.initRules = function() {
      var arr;
      this.rules.data.reaction = ["fire:2,air:1->burn", "burn:2,fire:2,air:1->explode", "fire:1,earth:2->iron", "water:1,earth:1->muddy", "water:2,fire:1,air:1->fog", "ice:2,water:2,air:2->snow", "life:1,earth:1->heal", "life:2,fire:1->brave", "iron:3,minus:1->corrosion", "life:2,spirit:2,air:2->boost", "minus:1,life:2->poison", "spirit:2,poison:2->stun"];
      arr = Utils.clone(Dict.QualityLevel);
      this.rules.data.qualityLevel = arr;
      return this.rules.data.traitLevel = {
        1: "life,fire,wind,air,earth,ice",
        2: "heal,minus,spirit,poison,clear,fog,iron,traitTime,space",
        3: "explode,burn,freeze,corrosion,boost,snow,stun"
      };
    };

    Database.prototype.initCharacters = function() {
      return this.characters.data = {
        nobody: {
          name: "",
          dialogPic: ""
        },
        player: {
          name: "艾丽西亚",
          dialogPic: "playerDialog"
        },
        cat: {
          name: "奇奇",
          dialogPic: "catDialog"
        },
        luna: {
          name: "露娜",
          description: "绯红魔法店的掌柜",
          dialogPic: "lunaDialog"
        },
        nataria: {
          name: "娜塔莉娅",
          description: "奇迹裁缝的掌柜",
          dialogPic: "natariDialog"
        },
        dirak: {
          name: "狄拉克",
          description: "冒险者公会的管理员",
          dialogPic: "dirakDialog"
        }
      };
    };

    return Database;

  })(Suzaku.EventEmitter);

}).call(this);
