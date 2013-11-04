// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.Database = (function(_super) {
    __extends(Database, _super);

    function Database() {
      this.areas = {};
      this.towns = {};
      this.things = {
        items: {},
        materials: {},
        supplies: {}
      };
      this.rules = {
        reaction: [],
        combination: []
      };
      this.tasks = null;
      this.storys = null;
      this.initAreas();
      this.initThings();
      this.initRules();
    }

    Database.prototype.initAreas = function() {
      var s;
      s = Utils.getSize();
      return this.areas.forest = {
        name: "森林",
        x: 0,
        y: 0,
        places: {
          entry: {
            bg: ["forest1"],
            resPoints: ["1,1", "20,20", "30,30", "50,50"],
            movePoints: ["exit", "west", "east"]
          },
          east: {
            bg: "forest2",
            resPoints: ["1,1", "20,80"],
            movePoints: ["entry"]
          },
          west: {
            bg: "forest3",
            resPoints: ["1,1", "20,80"],
            movePoints: ["entry"]
          }
        }
      };
    };

    Database.prototype.initThings = function() {
      this.things.qualityLevel = [30, 100, 300, 600, 1000, 2000];
      this.things.items = {
        scree: {
          name: "小石子",
          img: Res.imgs.item,
          description: "随处可见的石头，但是要采集的话还是得去森林吧",
          traits: ["earth:10"],
          gather: ["forest entry.1,west.2,east.1"],
          gatherRequire: null
        },
        flint: {
          name: "燧石",
          description: "可以打火的石头，能够感受到微弱的火属性魔力",
          traits: ["fire:10", "earth:5"],
          gather: ["forest entry.2,entry.3"]
        },
        lakeWater: {
          name: "湖水",
          description: "清澈的湖水，含有少量净化所需的元素",
          traits: ["water:15", "clear:3"],
          gather: ["forest entry.3"]
        },
        blueRose: {
          name: "蓝玫瑰",
          description: "蓝色的玫瑰，在森林里的背光面会长。得小心它的刺",
          traits: ["water:8", "life:8"],
          gather: ["forest entry.1"]
        },
        herbs: {
          name: "药草",
          description: "有治疗效果的药草，很多药物里都有它的成分",
          traits: ["life:16"],
          gather: ["forest entry.1"]
        },
        mouseTailHerbs: {
          name: "鼠尾草",
          description: "长在路边很常见的一种小草，为什么叫鼠尾草而不叫狗尾草呢？这还真是奇怪啊，据说晚上会有闪光的鼠尾草出现…",
          traits: ["life:5", "earth:20"],
          gather: ["forest entry.1"]
        },
        caveMashroom: {
          name: "洞穴菇",
          description: "潮湿的山洞里面才会长的蘑菇，随便吃掉的话会中毒",
          traits: ["poinson:8", "life:5"],
          arttribute: ["plants"],
          gather: ["forest entry.1"]
        }
      };
      this.things.supplies = {
        healPotion: {
          name: "治疗药剂",
          description: "有治疗效果的药剂",
          img: null
        },
        firePotion: {
          name: "火焰药剂",
          img: null
        }
      };
      return this.things.materials = {
        magicLiquid: {
          name: "魔法溶液"
        },
        magicPowder: {
          name: "魔法粉尘"
        }
      };
    };

    Database.prototype.initRules = function() {
      return this.rules.reaction = {
        from: ["fire:5"],
        to: "",
        cond: []
      };
    };

    return Database;

  })(Suzaku.EventEmitter);

}).call(this);
