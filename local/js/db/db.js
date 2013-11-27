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
      this.rules = new SubDB("rules");
      this.monsters = new SubDB("sprites-monsters");
      this.spriteItems = new SubDB("sprites-items");
      this.characters = new SubDB("characters");
      for (name in ["AreasDB", "ThingsDB", "MissionsDB"]) {
        delete window[name];
      }
      this.initCharacters();
      this.initSprites();
      this.initRules();
    }

    Database.prototype.initRules = function() {
      return this.rules.data.reaction = ["fire:2,air:1->burn", "burn:3,fire:2,air:1->explode", "fire:1,earth:2->iron", "water:1,earth:1->muddy", "water:2,fire:1,air:1->fog", "cold:2,air:2->freeze", "freeze:2,water:2,air:2->snow", "life:2,earth:1->heal", "life:2,water:1->clean", "life:2,fire:1->brave", "iron:3,minus:2->corrosion", "life:3,spirit:2,air:2->boost", "minus:2,life:2->poison"];
    };

    Database.prototype.initCharacters = function() {
      return this.characters.data = {
        player: {
          name: "艾丽西亚",
          dialogPic: ""
        },
        cat: {
          description: "",
          name: "琪琪",
          dialogPic: ""
        },
        luna: {
          name: "露娜",
          description: "绯红魔法店的掌柜",
          dialogPic: ""
        },
        dirak: {
          name: "狄拉克",
          description: "武器店的老板",
          dialogPic: ""
        }
      };
    };

    Database.prototype.initSprites = function() {
      this.monsters.data = {
        qq: {
          name: "QQ",
          sprite: Res.sprites.qq,
          icon: null,
          statusValue: {
            hp: 1000,
            def: 30,
            spd: 30
          },
          skills: {
            attack: {
              damage: {
                normal: 30,
                water: 10
              }
            },
            waterball: {
              turn: 2,
              damage: {
                water: 100
              }
            }
          },
          anchor: "270,240",
          movements: {
            normal: "0,6",
            move: "7,15",
            attack: "16,23:4,6",
            cast: "0,6"
          },
          drop: {
            certain: ["bluerose"],
            random: null
          }
        }
      };
      return this.spriteItems.data = {
        waterball: {
          name: "水球术",
          movements: {
            normal: "",
            active: ""
          }
        }
      };
    };

    return Database;

  })(Suzaku.EventEmitter);

}).call(this);
