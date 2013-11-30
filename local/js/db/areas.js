// Generated by CoffeeScript 1.6.2
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.AreasDB = (function(_super) {
    __extends(AreasDB, _super);

    function AreasDB() {
      var s;

      AreasDB.__super__.constructor.call(this, "areas");
      s = Utils.getSize();
      this.data = {
        forest: {
          name: "雾之森",
          costEnergy: 5,
          description: "常年被薄雾覆盖的森林，拥有丰富的药材资源和被此吸引的魔兽。林中的湖面下，似乎能看到微弱的光芒……",
          summaryImg: "summaryForest",
          dangerLevel: '低',
          summaryBg: 'forestEntry',
          x: 0,
          y: 0,
          battlefieldBg: {
            bfForestMain: {
              z: 1000,
              anchor: {
                x: 150,
                y: 0
              },
              main: true
            },
            bfForestFloat: {
              z: 1,
              fixToBottom: true
            }
          },
          places: {
            entry: {
              defaultX: 300,
              name: "森林外围",
              bg: {
                forestEntry: {
                  z: 1000
                }
              },
              floatBg: {
                forestEntryFloat1: {
                  z: 600,
                  y: -50
                },
                forestEntryFloat2: {
                  z: 1,
                  x: 300,
                  fixToBottom: true
                }
              },
              resPoints: ["0,80", "400,500", "800,300", "1000,300"],
              resources: ["earthLow", "earthLow,fireLow", "fireLow", "lifeLow", "earthLow"],
              monsters: {
                certain: ['1:pig,qq,pig'],
                random: ['2:qq', '3:qq']
              },
              movePoints: ["exit:345,585", "lake:959,355"]
            },
            lake: {
              name: "湖",
              bg: {
                forestLake: {
                  z: 1000
                }
              },
              floatBg: {
                forestEntryFloat2: {
                  z: 1,
                  x: 300,
                  fixToBottom: true
                }
              },
              resPoints: ["1,1", "20,80"],
              movePoints: ["entry:684,600"]
            }
          }
        },
        snowmountain: {
          name: "雪域",
          costEnergy: 10,
          description: "终年积雪的北地。风雪呼啸的冰原上，有着比温暖的南方更为热烈的生命——那个洞窟，传来了声音。",
          summaryImg: 'summarySnow',
          dangerLevel: "中",
          summaryBg: 'snowmountainEntryBg',
          x: 0,
          y: 0,
          battlefieldBg: {
            bfSnownmountain: {
              z: 1000,
              anchor: {
                x: 150,
                y: 0
              },
              main: true
            }
          },
          places: {
            entry: {
              name: "大冰原",
              bg: {
                snowmountainEntryMain: {
                  z: 1000
                },
                snowmountainEntryBg: {
                  z: 10000
                }
              },
              floatBg: {
                snowmountainEntryFloat: {
                  z: 300,
                  x: 200,
                  fixToBottom: true
                }
              },
              resPoints: ["0,80", "400,500", "800,300", "1000,300"],
              resources: ["iceLow", "iceLow", "iceLow", "iceLow", "iceLow"],
              monsters: {
                certain: ['1:qq,qq,qq'],
                random: ['2:qq', '3:qq']
              },
              movePoints: ["exit:180,480", "middle:1850,560"]
            },
            middle: {
              name: "雪谷",
              bg: {
                snowmountainMiddle: {
                  z: 1000
                }
              },
              resPoints: ["1,1", "20,80"],
              movePoints: ["entry:30,50", "cave:430,510"]
            },
            cave: {
              name: "蓝晶洞穴",
              bg: {
                snowmountainCave: {
                  z: 1000
                }
              },
              floatBg: {
                snowmountainCaveFloat: {
                  z: 400,
                  x: 300,
                  fixToBottom: true
                }
              },
              resPoints: ["1,1", "20,80"],
              movePoints: ["middle:720,120"]
            }
          }
        },
        home: {
          name: "魔女宅",
          description: '传说中的魔女——艾丽西亚的祖母留下的大房子。有宽敞的客厅和完善的工作设施，在这个地方应该可以尽情施展自己的才能了吧！',
          costEnergy: 0,
          dangerLevel: '安全',
          summaryImg: 'summaryHome',
          summaryBg: ''
        },
        magicItemShop: {
          name: '绯红魔法店',
          description: '这儿没什么好东西而且都很贵，不过附近好像也就只有这个地方愿意收购魔法物品了...真是太惨了',
          costEnergy: 0,
          summaryImg: 'summaryShop',
          dangerLevel: '安全',
          summaryBg: ''
        },
        equipmentShop: {
          name: '奇迹裁缝',
          description: '出售魔法师用的服装和法杖',
          costEnergy: 0,
          summaryImg: 'summaryShop',
          dangerLevel: '安全',
          summaryBg: ''
        },
        guild: {
          name: '冒险者协会',
          description: '冒险者协会在这个城镇的分会，附件的人都会来这里提交委托',
          costEnergy: 0,
          summaryImg: 'summaryShop',
          dangerLevel: '安全',
          summaryBg: ''
        }
      };
    }

    return AreasDB;

  })(SubDB);

}).call(this);
