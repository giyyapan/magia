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
          drop: {
            certain: [],
            random: null
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
          drop: {
            certain: [],
            random: null
          }
        },
        slime: {
          name: "史莱姆",
          sprite: "slime",
          attackSound: "slimeHit",
          statusValue: {
            hp: 60,
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
          drop: {
            certain: ["bluerose"],
            random: null
          }
        }
      };
    };

    return MonstersDB;

  })(SubDB);

}).call(this);
