// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.MonstersDB = (function(_super) {
    __extends(MonstersDB, _super);

    function MonstersDB() {
      MonstersDB.__super__.constructor.call(this, "monsters");
      this.init();
    }

    MonstersDB.prototype.init = function() {
      return this.data = {
        qq: {
          name: "企鹅",
          sprite: "qq",
          attackSound: "qqHit",
          statusValue: {
            hp: 100,
            def: 30,
            spd: 30
          },
          damage: {
            normal: 20
          },
          drop: {
            money: 20
          }
        },
        iceQQ: {
          name: "冰企鹅",
          sprite: "iceQQ",
          attackSound: "qqHit",
          statusValue: {
            hp: 150,
            def: 30,
            spd: 30
          },
          damage: {
            water: 30
          },
          drop: {
            money: 15
          }
        },
        iceQQKing: {
          name: "冰企鹅王",
          sprite: "iceQQ",
          attackSound: "qqHit",
          scale: 1.3,
          statusValue: {
            hp: 300,
            def: 30,
            spd: 30
          },
          damage: {
            water: 80
          },
          drop: {
            money: 80
          }
        },
        pig: {
          name: "布塔猪",
          sprite: "pig",
          attackSound: "pigHit",
          statusValue: {
            hp: 150,
            def: 30,
            spd: 30
          },
          damage: {
            normal: 15
          },
          drop: {
            money: 10
          }
        },
        pigKing: {
          name: "布塔猪王",
          sprite: "pigDark",
          scale: 1.2,
          attackSound: "pigHit",
          statusValue: {
            hp: 300,
            def: 30,
            spd: 30
          },
          damage: {
            normal: 30
          },
          drop: {
            money: 100
          }
        },
        slime: {
          name: "史莱姆",
          sprite: "slime",
          attackSound: "slimeHit",
          statusValue: {
            hp: 80,
            def: 30,
            spd: 30
          },
          damage: {
            normal: 10
          },
          drop: {
            money: 5
          }
        }
      };
    };

    return MonstersDB;

  })(SubDB);

}).call(this);
